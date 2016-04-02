
COOKIES=art ascii-art computers cookie definitions drugs education ethnic \
	food fortunes goedel humorists kids law linuxcookie literature \
	love magic medicine men-women miscellaneous news people pets \
	platitudes politics riddles science songs-poems sports \
	startrek translate-me wisdom work linux perl knghtbrd \
	paradoxum zippy debian

STRFILE=../util/strfile

.PHONY: all cookies o-cookies w-cookies install clean

all: cookies o-cookies w-cookies

check:
	for i in $(COOKIES) ; \
		do \
			echo -n "Testing $$i..."; \
			if ! tail -n 1 $$i | grep -q ^%$  ; then \
			        echo " failed % check" ; \
				echo "Fortune cookie file does not end in a single %" ; \
				exit 1; \
			fi;\
			if egrep -q ".{72}." $$i ; then \
				echo " failed length check"; \
				echo "Fortune cookie file contains a line longer than 72 characters"; \
				exit 1; \
			fi; \
			echo " passed " ;\
		done;

cookies: cookies-stamp

o-cookies:
	if [ $(OFFENSIVE) = 1 ] ; then \
	    cd off && $(MAKE) OCOOKIEDIR=$(OCOOKIEDIR) ; fi

w-cookies:
	if [ $(WEB) = 1 ] ; then \
	    cd html && $(MAKE) WCOOKIEDIR=$(WCOOKIEDIR); fi

cookies-stamp:
	rm -f *.dat
	for i in $(COOKIES) ; \
	    do \
	        if [ ! -f $$i.old ] ; then \
	        	cp $$i $$i.old; \
		fi; \
	        recode latin1..u8 $$i ; \
		$(STRFILE) $$i ; \
		ln -s $$i $$i.u8 || exit $? ; \
	    done
	touch cookies-stamp

install: cookies-stamp
	install -m 0755 -d $(COOKIEDIR)
	if [ $(OFFENSIVE) = 1 ] ; then cd off && $(MAKE) install ; fi
	if [ $(WEB) = 1 ] ; then cd html && $(MAKE) install ; fi
	for i in $(COOKIES) ; do \
		install -m 0644 $$i $$i.dat $(COOKIEDIR) || exit $? ; \
		cp -d $$i.u8 $(COOKIEDIR) ; \
		done

clean:
	rm -f cookies-stamp *.dat
	rm -f *.u8
	cd off && $(MAKE) clean
	cd html && $(MAKE) clean
	for i in $(COOKIES) ; do \
		if [ -f $$i.old ] ; then \
			mv $$i.old $$i; \
		fi; \
	done
