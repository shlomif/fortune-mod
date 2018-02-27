# fortune-mod Maintenance Version and Ongoing Development

[![Build Status](https://travis-ci.org/shlomif/fortune-mod.svg?branch=master)](https://travis-ci.org/shlomif/fortune-mod)

This GitHub repository maintains the sources for fortune-mod, a
version of
[the UNIX fortune command](http://en.wikipedia.org/wiki/Fortune_%28Unix%29).
`fortune` is a command-line utility which displays a random quotation from a
collection of quotes.

The canonical repository for the time being is:
https://github.com/shlomif/fortune-mod . In the future, we may create a GitHub
organization for it and move the sources there.

For more information about it, you can contact
[Shlomi Fish](http://www.shlomifish.org/) .

## Release Tarballs

Release tarballs can be found at [this directory](http://www.shlomifish.org/open-source/projects/fortune-mod/arcs/)
for now.

Reading from [this reported bug](https://github.com/shlomif/fortune-mod/issues/10):

One can find the official release tarballs of fortune-mod as prepared by CPack
there. They have a proper containing directory. Please don't use GitHub's tags
for that.

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

# What was already done.

1. fortune-mod-1.99.1 was imported into the repository from the Mageia tarball
as the tag <code>fortune-mod-1.99.1</code>.

2. Cleaned up the build process a little.

3. Converted the source files to UTF-8.

4. Added some tests.

5. Removed trailing whitespace.

6. Reformatted long (> 80 chars) lines.

7. Fixed some typos.

8. Added [Travis-CI](https://travis-ci.org/) support.

9. Converted the build system to [CMake](https://en.wikipedia.org/wiki/CMake) .

10. Added valgrind tests and fixed some memory leaks.

11. Released fortune-mod-1.99.3 and fortune-mod-1.99.4.

12. Fixed some C compiler warnings encountered with the GCC compiler flags of
[Shlomif_Common](https://bitbucket.org/shlomif/shlomif-cmake-modules/overview).

13. Added a build-time option to remove the “-o” (= “offensive”) flag, inspired
by a set of patches on the Fedora package.

14. Applied some downstream patches.

15. Released version 2.0.0.

16. Fixed as many “clang -Weverything” warnings as possible.

17. lib-recode became maintained again at https://github.com/rrthomas/recode
(thanks to @rrthomas ) thus preventing a switch to something else.

# What remains to be done.

1. See if there are any more downstream patches to apply.

2. Fix more typos (reports and pull-requests are welcome.)

3. Perhaps modernize the code a little.

# Links

* [Shlomi Fish’s Fortune Cookie Files](http://www.shlomifish.org/humour/fortunes/) - on his site, containing links to many other collections of fortune cookies.
* [XML-Grammar-Fortune](http://web-cpan.shlomifish.org/modules/XML-Grammar-Fortune/) - an XML grammar for collections of quotes, allowing one to generate XHTML or plaintext.
* [Anvari.org’s web interface to fortune](http://www.anvari.org/fortune/) - with
many collections.
