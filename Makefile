.PHONY : build
build :
	dune build

.PHONY : test
test : build
	make -wC test

.PHONY : clean
clean :
	dune clean
	make -wC test clean
