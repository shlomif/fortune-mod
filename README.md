# fortune-mod Maintenance Version and Ongoing Development

This GitHub repository maintains the sources for fortune-mod, a
version of
[the UNIX fortune command](http://en.wikipedia.org/wiki/Fortune_%28Unix%29)
to display a random quote from a collection of quotes, on the command line.

For more information about it you can contact
[Shlomi Fish](http://www.shlomifish.org/) .

# What was already done.

1. fortune-mod-1.99.1 was imported into the repository from the Mageia tarball
as the tag.

2. Cleaned up the build process a little.

3. Converted the source files to UTF-8.

4. Added a rudimentary "make check" target.

5. Removed trailing whitespace.

6. Reformatted long (> 80 chars) lines.

7. Fixed some typos.

8. Add [Travis-CI](https://travis-ci.org/) support.

# What remains to be done.

1. See if there are any downstream patches to apply.

2. Add valgrind tests.

3. Add other tests.

4. Release fortune-mod-1.99.2.

5. Fix more typos (reports/pull-requests are welcome.)

6. Consider converting the build system to
[CMake](https://en.wikipedia.org/wiki/CMake) or a different build system.

