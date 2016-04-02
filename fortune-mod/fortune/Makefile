# Note: this makefile should be called by the makefile in the parent
# directory, which will pass it a number of variables.  Better to call
# make fortune-bin or make fortune-debug from there.  make install
# *only* works at the top level--do make install-fortune and make
# install-fman.  Make clean is an acceptable target called directly
# in this directory, though.

all: fortune

fortune: fortune.o
	$(CC) $(LDFLAGS) -o fortune fortune.o $(LIBS)

clean:
	rm -f fortune.o fortune fortune.man


