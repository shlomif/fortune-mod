
OCOOKIES_UNROTATED=drugs misandry privates sex astrology ethnic \
	miscellaneous racism songs-poems black-humor hphobia misogyny \
	religion vulgarity definitions limerick politics riddles zippy \
	cookie fortunes linux art atheism debian

OCOOKIES_ROTATED=

OCOOKIES=$(OCOOKIES_UNROTATED) $(OCOOKIES_ROTATED)

STRFILE=../../util/strfile
ROT=../../util/rot


all:	ocookies-stamp

ocookies-stamp:	rotated-stamp
	rm -f *.dat
	for i in $(OCOOKIES) ; do $(STRFILE) -x $$i || exit $$? ; done
	touch ocookies-stamp

rotated-stamp: recoded-stamp
	for i in $(OCOOKIES_UNROTATED) ; \
	    do $(ROT) < unrotated/$$i > $$i || exit $$? ; ln -s $$i $$i.u8; done
	touch rotated-stamp

recoded-stamp:
	for i in $(OCOOKIES_UNROTATED) ; \
	    do \
	        if [ ! -f unrotated/$$i.old ]; then \
	    	    cp unrotated/$$i unrotated/$$i.old ; \
		fi; \
		recode latin1..u8 unrotated/$$i; \
	    done
	touch recoded-stamp
	    
install:
	install -m 0755 -d $(OCOOKIEDIR)
	for i in $(OCOOKIES) ; \
	    do install -m 0644 $$i $$i.dat $(OCOOKIEDIR) || exit $$? ; \
	    cp -d $$i.u8 $(OCOOKIEDIR) ; \
	done

clean:
	rm -f ocookies-stamp rotated-stamp recoded-stamp *.dat $(OCOOKIES_UNROTATED)
	rm -f *u8
	for i in $(OCOOKIES_UNROTATED) ; do \
		if [ -f unrotated/$$i.old ] ; then \
			mv unrotated/$$i.old unrotated/$$i; \
		fi; \
	done
									      
