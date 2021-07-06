TOP = ../..

OCOOKIES_UNROTATED=drugs misandry privates sex astrology ethnic \
	miscellaneous racism songs-poems black-humor hphobia misogyny \
	religion vulgarity definitions limerick politics riddles zippy \
	cookie fortunes linux art atheism debian

OCOOKIES_ROTATED=

OCOOKIES=$(OCOOKIES_UNROTATED) $(OCOOKIES_ROTATED)

STRFILE=$(TOP)/util/strfile
ROT=$(TOP)/util/rot


all:	ocookies-stamp

ocookies-stamp:	rotated-stamp
	rm -f *.dat
	for i in $(OCOOKIES) ; do $(STRFILE) -x rotated/$$i || exit $$? ; done
	touch ocookies-stamp

rotated-stamp:
	for i in $(OCOOKIES_UNROTATED) ; \
	    do $(ROT) < unrotated/$$i > rotated/$$i || exit $$? ; (cd rotated && ln -sf $$i $$i.u8) ; done
	touch rotated-stamp

check: all
	for i in $(OCOOKIES) ; \
		do \
			if ! sh $(TOP)/tests/scripts/check-fortune-file.sh "unrotated/$$i" ; then \
				exit 1; \
			fi ; \
		done;
install:
	install -m 0755 -d $(OCOOKIEDIR)
	for i in $(OCOOKIES) ; \
	    do install -m 0644 rotated/$$i rotated/$$i.dat $(OCOOKIEDIR) || exit $$? ; \
	    cp -P rotated/$$i.u8 $(OCOOKIEDIR) ; \
	done

clean:
	rm -f ocookies-stamp rotated-stamp recoded-stamp rotated/*
	touch rotated/PLACEHOLDER
