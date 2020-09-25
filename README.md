# fortune-mod Maintenance Version and Ongoing Development

[![Build Status](https://travis-ci.org/shlomif/fortune-mod.svg?branch=master)](https://travis-ci.org/shlomif/fortune-mod)

This GitHub repository maintains the sources for fortune-mod, a
version of
[the UNIX fortune command](https://en.wikipedia.org/wiki/Fortune_%28Unix%29).
`fortune` is a command-line utility which displays a random quotation from a
collection of quotes. This collection is read from the local [file system](https://en.wikipedia.org/wiki/File_system)
and does not require network access. A large collection of quotes is provided in
the download and installed by default, but more quote collections can be added
by the user.

The canonical repository for the time being is:
https://github.com/shlomif/fortune-mod . In the future, we may create a GitHub
organization for it and move the sources there.

For more information about it, you can contact
[Shlomi Fish](https://www.shlomifish.org/) .

## Installation

On Fedora and other rpm-based distributions:

```
sudo dnf install fortune-mod
```

On Arch Linux and derivatives:

```
sudo pacman -S fortune-mod
```

On Debian, and derivatives (e.g: Ubuntu, Linux Mint):

```
sudo apt install fortune-mod
```

(Warning: may be an old version.)

## Release Tarballs

Release tarballs can be found at [this directory](https://www.shlomifish.org/open-source/projects/fortune-mod/arcs/)
for now.

Based on [this reported bug](https://github.com/shlomif/fortune-mod/issues/10):

One can find the official release tarballs of fortune-mod as prepared by CPack
there. They have a proper containing directory. One can also download these tarballs
from the [GitHub releases page](https://github.com/shlomif/fortune-mod/releases)
but please do not use the auto generated “Source code (zip)” and “Source code (tar.gz)”
downloads which are both incomplete and have extra directories inside.

## Sample usage

```
$ fortune
Enthusiasm is one of the most important
ingredients a volunteer project runs on.
                -- Andreas Schuldei
$
```

## History

I believe fortune-mod was originally forked from the NetBSD version of
fortune, and ported to run on Linux systems. For some time it was maintained
at the currently offline redellipse-dot-net inside a
[GNU Arch](http://en.wikipedia.org/wiki/GNU_arch) (= an old and now mostly
unused version control system) repository, and version 1.99.1 was released as
a tarball.

This maintenance version was initiated by Shlomi Fish, who decided to maintain
it out of being a fan of the fortune command. It started by importing the
unpacked source of the fortune-mod-1.99.1.tar tarball from the Mageia Linux
.src.rpm into an empty git repository and continuing from there.

## What is the difference between fortune-mod and the "normal" fortune?

fortune-mod (= "fortune modified") was the name of a fork of the original
NetBSD fortune, which was done in order to port the code to Linux and apply some
other changes. If you are using a Linux distribution chances are that
the `fortune` executable's package **is** fortune-mod (although in the
case of Debian-and-derivatives it is likely very out-of-date as of September
2020).

# What was already done.

1. fortune-mod-1.99.1 was imported into the repository from the Mageia tarball
as the tag <code>fortune-mod-1.99.1</code>.

2. Converted the build system to [CMake](https://en.wikipedia.org/wiki/CMake) .

3. Converted the source files to UTF-8.

4. Added some tests.

5. Removed trailing whitespace.

6. Reformatted long (> 80 chars) lines.

7. Fixed some typos.

8. Added [Travis-CI](https://travis-ci.org/) testing.

9. Added valgrind tests and fixed some memory leaks.

10. Released fortune-mod-1.99.3, fortune-mod-1.99.4, v2.0.0 and up to
version 2.26.0

11. Fixed some C compiler warnings encountered with the GCC compiler flags of
[Shlomif_Common](https://bitbucket.org/shlomif/shlomif-cmake-modules/overview).

12. Added a build-time option to remove the “-o” (= “offensive”) flag, inspired
by a set of patches on the Fedora package.

13. Applied some downstream patches.

14. Fixed as many “clang -Weverything” warnings as possible.

15. lib-recode became maintained again at https://github.com/rrthomas/recode
(thanks to @rrthomas ) thus preventing a switch to something else.

16. Got the build and tests to pass on [AppVeyor/MS Windows](https://ci.appveyor.com/project/shlomif/fortune-mod)
(with some appreciated help).

17. Found and fixed some security issues:
    - Seems to affect some Linux distributions as well as FreeBSD and NetBSD.
        - Was already fixed in OpenBSD
    - https://bugs.mageia.org/show_bug.cgi?id=26567
    - https://advisories.mageia.org/MGASA-2020-0199.html
    - https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=246050
    - https://github.com/shlomif/fortune-mod/commit/fe182a25663261be6e632a2824f6fd653d1d8f45
    - https://github.com/shlomif/fortune-mod/commit/540c495f57e441b745038061a3cfa59e3a97bf33
    - https://github.com/shlomif/fortune-mod/commit/acd338098071bddfa1d21f87e1813727031428ea

18. Reformatted the C code using [clang-format](https://clang.llvm.org/docs/ClangFormat.html).

# What remains to be done.

1. See if there are any more downstream patches to apply.

2. Fix more typos (reports and pull-requests are welcome.)

3. Perhaps modernize the code a little.

4. Add more quotes / fortune cookies.

5. Prepare packages for the new releases for [downstream distributions/Operating Systems](https://pkgs.org/download/fortune-mod).

# Links

* [Shlomi Fish’s Fortune Cookie Files](https://www.shlomifish.org/humour/fortunes/) - on his site, containing links to many other collections of fortune cookies.
* [XML-Grammar-Fortune](https://web-cpan.shlomifish.org/modules/XML-Grammar-Fortune/) - an XML grammar for collections of quotes, allowing one to generate XHTML or plaintext.
* [Anvari.org’s web interface to fortune](http://www.anvari.org/fortune/) - with many collections.
