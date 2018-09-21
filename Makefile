all:
	bsc -u -sim Test.bsv
	bsc -sim -e mkTest socketlib.c
clean:
	rm -f imported_BDPI_functions.h mkTest.cxx mkTest.h model_*.cxx model_*.h *.bo *.ba *.o *.so a.out
