#
# Makefile for fortune-mod
#

# Where does the fortune program go?
FORTDIR=$(prefix)/usr/games
# Where do the data files (fortunes, or cookies) go?
COOKIEDIR=$(prefix)/usr/share/games/fortunes
# Offensive ones?
OCOOKIEDIR=$(COOKIEDIR)/off
# The ones with html tags?
WCOOKIEDIR=$(COOKIEDIR)/html
# Where do local data files go?
LOCALDIR=$(prefix)/usr/local/share/games/fortunes
# Offensive ones?
LOCALODIR=$(LOCALDIR)/off
# With HTML tags?
LOCALWDIR=$(LOCALDIR)/html
# Where do strfile and unstr go?
BINDIR=$(prefix)/usr/bin
# What is the proper mode for strfile and unstr? 755= everyone, 700= root only
BINMODE=0755
#BINMODE=0700
# Where do the man pages for strfile and unstr go?
BINMANDIR=$(prefix)/usr/share/man/man1
# What is their proper extension?
BINMANEXT=1
# And the same for the fortune man page
FORTMANDIR=$(prefix)/usr/share/man/man6
FORTMANEXT=6
# Do we want to install the offensive files? (0 no, 1 yes)
OFFENSIVE=1
# Do we want to install files with html tags? (0 no, 1 yes)
# (Note: These files are not yet available)
WEB=0

#
# Include whichever of the following defines that are appropriate
# for your system into REGEXDEFS:
#
# -DHAVE_REGEX_H
#	For systems that declare their regex functions in <regex.h>
# -DHAVE_REGEXP_H
#	For systems that declare their regex functions in <regexp.h>
# -DHAVE_RX_H
#	For systems that declare their regex functions in <rx.h>
# -DBSD_REGEX
#	For systems with BSD-compatible regex functions
# -DPOSIX_REGEX
#	For systems with POSIX-compatible regex functions
# -DHAVE_STDBOOL
#       For GNU system that declare bool type in <stdbool.h>
#
# NB. Under Linux, the BSD regex functions are _MUCH_ faster
#     than the POSIX ones, but your mileage may vary.
#
REGEXDEFS=-DHAVE_REGEX_H -DBSD_REGEX -DHAVE_STDBOOL

#
# If your system's regex functions are not in its standard C library,
# include the appropriate link flags into REGEXLIBS
#
REGEXLIBS=

RECODELIBS=-lrecode

DEFINES=-DFORTDIR="\"$(COOKIEDIR)\"" -DOFFDIR="\"$(OCOOKIEDIR)\"" -DLOCFORTDIR="\"$(LOCALDIR)\"" -DLOCOFFDIR="\"$(LOCALODIR)\""
CFLAGS=-O2 $(DEFINES) -Wall -fomit-frame-pointer -pipe -fsigned-char
LDFLAGS=-s

# The above flags are used by default; the debug flags are used when make
# is called with a debug target, such as 'make debug'

# to get a list of the possible targets, try 'make help'

# All targets are available at the top level, which exports the
# variables to sub-makes.  Avoid makes in subdirectories; cd .. and
# make <target> instead.

DEBUGCFLAGS=-g -DDEBUG $(DEFINES) -Wall
DEBUGLDFLAGS=

# Only ANSI-compatible C compilers are currently supported
CC=gcc

# ----------------------------------------
# Nothing below this line should have to be changed

SUBDIRS=fortune util datfiles

.PHONY: all debug fortune-bin fortune-debug util-bin randstr rot \
	util-debug cookies cookies-z install install-fortune \
	install-util install-man install-fman install-uman \
	clean love help

# By default, compile optimized versions
all: fortune-bin util-bin cookies-z

# Create debugging versions
debug: fortune-debug util-debug cookies-z 

# Just create the fortune binary
fortune-bin:
	cd fortune && $(MAKE) CC='$(CC)' \
		    CFLAGS='$(CFLAGS) $(REGEXDEFS) -I../util'	\
		    LDFLAGS='$(LDFLAGS)' LIBS='$(REGEXLIBS) $(RECODELIBS)'

fortune-debug:
	cd fortune && $(MAKE) CC='$(CC)' \
		    CFLAGS='$(DEBUGCFLAGS) $(REGEXDEFS) -I../util' \
		    LDFLAGS='$(DEBUGLDFLAGS)' LIBS='$(REGEXLIBS)'

util-bin:
	cd util && $(MAKE) CC='$(CC)' CFLAGS='$(CFLAGS)'	\
		    LDFLAGS='$(LDFLAGS)'

# Not listed in help
randstr:
	cd util && $(MAKE) CC='$(CC)' CFLAGS='$(CFLAGS)'	\
		    LDFLAGS='$(LDFLAGS)' randstr

util-debug:
	cd util && $(MAKE) CC='$(CC)' CFLAGS='$(DEBUGCFLAGS)'	\
		    LDFLAGS='$(DEBUGLDFLAGS)'

cookies:
	@echo "Try the kitchen, silly!" ; sleep 3
	@echo "Sorry, just joking."
	$(MAKE) cookies-z

cookies-z: util-bin
	cd datfiles && $(MAKE) COOKIEDIR=$(COOKIEDIR) \
		    OCOOKIEDIR=$(OCOOKIEDIR) WCOOKIEDIR=$(WCOOKIEDIR) \
		    OFFENSIVE=$(OFFENSIVE) WEB=$(WEB)

# Install everything
install: install-fortune install-util install-man install-cookie

# Install just the fortune program
install-fortune: fortune-bin
	install -m 0755 -d $(FORTDIR)
	install -m 0755 fortune/fortune $(FORTDIR)

# Install just the utilities strfile and unstr
install-util: util-bin
	install -m 0755 -d $(BINDIR)
	install -m $(BINMODE) util/strfile $(BINDIR)
	install -m $(BINMODE) util/unstr $(BINDIR)

# Install all the man pages
install-man: install-fman install-uman

# Note: this rule concatenates the parts of the man page with the locally
#       defined pathnames (which should reduce confusion).
fortune/fortune.man: fortune/fortune-man.part1 fortune/fortune-man.part2
	@echo -n "Building fortune/fortune.man ... "
	@cat fortune/fortune-man.part1 >fortune/fortune.man
	@echo ".I $(COOKIEDIR)" >>fortune/fortune.man
	@echo "Directory for innoffensive fortunes." >>fortune/fortune.man
	@echo ".TP" >>fortune/fortune.man
	@echo ".I $(OCOOKIEDIR)" >>fortune/fortune.man
	@echo "Directory for offensive fortunes." >>fortune/fortune.man
	@cat fortune/fortune-man.part2 >>fortune/fortune.man
	@echo done.

# Install the fortune man pages
install-fman: fortune/fortune.man
	install -m 0755 -d $(FORTMANDIR)
	install -m 0644 fortune/fortune.man $(FORTMANDIR)/fortune.$(FORTMANEXT)

# Install the utilities man pages
install-uman:
	install -m 0755 -d $(BINMANDIR)
	install -m 0644 util/strfile.man $(BINMANDIR)/strfile.$(BINMANEXT)
	rm -f $(BINMANDIR)/unstr.$(BINMANEXT)
	(cd $(BINMANDIR) && ln -sf strfile.$(BINMANEXT).gz $(BINMANDIR)/unstr.$(BINMANEXT).gz)

# Install the fortune cookie files
install-cookie: cookies-z
	cd datfiles && $(MAKE) COOKIEDIR=$(COOKIEDIR) \
		    OCOOKIEDIR=$(OCOOKIEDIR) WCOOKIEDIR=$(WCOOKIEDIR) \
		    OFFENSIVE=$(OFFENSIVE) WEB=$(WEB) install

clean:
	for i in $(SUBDIRS) ; do (cd $$i && $(MAKE) clean); done

love:
	@echo "Not war?" ; sleep 3
	@echo "Look, I'm not equipped for that, okay?" ; sleep 2
	@echo "Contact your hardware vendor for appropriate mods."

help:
	@echo "Targets:"
	@echo
	@echo "all:	make all the binaries and data files (the default target)"
	@echo " fortune-bin:	make the fortune binary"
	@echo " util-bin:	make the strfile and unstr binaries"
	@echo " cookies:	make the fortune-cookie data files"
	@echo
	@echo "debug:	make debugging versions of the binaries"
	@echo " fortune-debug:	Just the fortune program"
	@echo " util-debug:	Just strfile and unstr"
	@echo
	@echo "install:	install the files in locations specified in Makefile"
	@echo " install-fortune:	Just the fortune program"
	@echo " install-util:		Just strfile and unstr"
	@echo " install-cookie:	Just the fortune string and data files"
	@echo " install-man:		Just the man pages"
	@echo "  install-fman:		Just the fortune man page"
	@echo "  install-uman:		Just the strfile/unstr man page"
	@echo
	@echo "clean:	Remove object files and binaries"
	@echo 
	@echo "help:	This screen"
	@echo
	@echo "love:	What a *good* idea!  Let's!"
