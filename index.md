# Binary packages for GCC snapshots

This page links to binary packages
built from recent [snapshots](https://gcc.gnu.org/snapshots.html)
of GCC's development trunk.
These builds are provided for testing purposes,
but are an experiment and might not get updated
and might even get taken down.

Only the C and C++ compilers are included, in a single large package.
I don't intend to split them up into smaller packages,
because the aim is just to provide a testable compiler.

## Reporting bugs

If you find bugs in GCC itself please report them to
[GCC Bugzilla](https://gcc.gnu.org/bugs)
but for problems with how these packages are built
please use the
[GitHub issues tracker](https://github.com/jwakely/pkg-gcc-latest/issues).

## Dynamic linking

You need to be aware that binaries created by this snapshot compiler
will not know how to find the `libstdc++.so.6` shared library by default.
This will result in errors complaining about `GLIBCXX_3.4.26` not being found.
This is because these packages install libraries to `/opt/gcc-latest/lib64`
and [`ld.so`](http://man7.org/linux/man-pages/man8/ld.so.8.html)
doesn't search in that directory by default.
This can be solved by using `LD_RUN_PATH` or `-Wl,-rpath` (when linking),
or `LD_LIBRARY_PATH` (when running the executables),
or by creating static binaries that don't use `libstdc++.so.6` at all.
See [Finding Dynamic or Shared Libraries](https://gcc.gnu.org/onlinedocs/libstdc++/manual/using_dynamic_or_shared.html#manual.intro.using.linkage.dynamic)
in the libstdc++ manual for more details.

## Packages

The latest snapshot is:

      GCC 9-20190310 Snapshot

      This snapshot has been generated from the GCC 9 SVN branch
      with the following options:
      svn://gcc.gnu.org/svn/gcc/trunk revision 269561

Packages for Fedora, RHEL, CentOS, and openSUSE
are built and hosted in the
[jwakely/gcc-latest COPR](https://copr.fedorainfracloud.org/coprs/jwakely/gcc-latest/).

A package for Ubuntu 16.04 is hosted on my personal site (until I set up Git Large File Storage on GitHub):

- [gcc-latest_9.0.1-20190310svn269561.deb](http://kayari.org/gcc-latest_9.0.1-20190310svn269561.deb)

## Source code

The sources for these packages can be found in the Subversion repository
(at the revision number above) or in the corresponding directory at
[https://gcc.gnu.org/pub/gcc/snapshots/](https://gcc.gnu.org/pub/gcc/snapshots/)

The script to create these packages
is on [GitHub](https://github.com/jwakely/pkg-gcc-latest)
(along with any patches applied to the upstream sources).