#!/bin/sh
# Start a COPR build for a GCC snapshot

usage()
{
  echo "Usage: $0 <snapshot> <spec|srpm|rpm|deb>"
  echo 'The snapshot argument should be a version and date (e.g. 9-20190310)'
  echo 'or a symbolic name (e.g. LATEST-9).'
}

if [[ $1 == --help ]]
then
  usage
  exit 0
elif [[ $# != 2 ]]
then
  echo "$0: Incorrect number of arguments" >&2
  usage >&2
  exit 1
fi

set -e

echo "### Fetching information for GCC $1 snapshot"

url=https://gcc.gnu.org/pub/gcc/snapshots/$1

fetch_tarfile()
{
  w3m -dump $url/index.html > index.txt
  cat index.txt
  REV=`awk '/trunk revision/ { print $NF }' index.txt`
  tarfile=`awk '/^gcc-.*tar/ { print $1 }' index.txt`
  if ! test -f $tarfile
  then
    echo '### Downloading source tarball'
    curl -O $url/$tarfile
  fi
  curl --silent -O $url/sha512.sum
  sha512sum --quiet --ignore-missing -c sha512.sum
}

gen_spec()
{
  echo '### Generating RPM spec file'
  m4 -P -DVERSION=$BASE_VER -DPKGREL=1 -DSNAPINFO=${DATE}svn${REV} -DSOURCE_URL=https://gcc.gnu.org/pub/gcc/snapshots/${basename#gcc-}/$tarfile -DBASENAME=$basename gcc-latest.spec.m4 > gcc-latest.spec
}

build_srpm()
{
  echo '### Building SRPM'
  local chroot=fedora-rawhide-x86_64
  mock -r $chroot --buildsrpm --spec gcc-latest.spec --sources .
  srpm=$(ls -rt /var/lib/mock/$chroot/result/*.src.rpm | tail -1)
  echo "Built $srpm"
}

build_copr()
{
  echo '### Starting COPR build'
  copr build --nowait gcc-latest $srpm
}

fetch_tarfile $1
echo '### Extracting version from sources'
basename=${tarfile%.tar.*}
BASE_VER=`tar -Oxf $tarfile $basename/gcc/BASE-VER`
DATE=${basename##*-}

gen_deb()
{
  PKGNAME=gcc-latest_$BASE_VER-${DATE}svn${REV}
  mkdir context
  ln $tarfile context/$tarfile
  m4 -P -DVERSION=$BASE_VER -DSNAPINFO=${DATE}svn${REV}  control.m4 > context/control
  m4 -P -DPKGNAME=$PKGNAME -DTARFILE=$tarfile -DBASENAME=$basename Dockerfile.m4 > context/Dockerfile
  echo '### Initializing container'
  podman build -t image context
  podman create --name cont image
  podman cp cont:/tmp/$PKGNAME.deb .
  podman rm cont
  podman rmi image
  rm -r context
}

case $2 in
  spec | srpm | rpm)
    gen_spec
    ;;&
  srpm | rpm)
    build_srpm
    ;;&
  rpm)
    build_copr
    ;;
  deb)
    gen_deb
    ;;
esac
