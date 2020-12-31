a.out: lex.yy.o y.tab.o ass5_18CS30042_18CS30010_translator.o 
	g++ ass5_18CS30042_18CS30010_translator.o lex.yy.o y.tab.o -lfl
	./a.out > ass5_18CS30042_18CS30010_quads1.out < ass5_18CS30042_18CS30010_test1.c
	./a.out > ass5_18CS30042_18CS30010_quads2.out < ass5_18CS30042_18CS30010_test2.c
	./a.out > ass5_18CS30042_18CS30010_quads3.out < ass5_18CS30042_18CS30010_test3.c
	./a.out > ass5_18CS30042_18CS30010_quads4.out < ass5_18CS30042_18CS30010_test4.c 
	./a.out > ass5_18CS30042_18CS30010_quads5.out < ass5_18CS30042_18CS30010_test5.c
y.tab.o: y.tab.c
	g++ -c y.tab.c
y.tab.c: ass5_18CS30042_18CS30010.y 
	yacc -dtv ass5_18CS30042_18CS30010.y
lex.yy.o: lex.yy.c y.tab.o 
	g++ -c lex.yy.c
lex.yy.c: ass5_18CS30042_18CS30010.l 
	flex ass5_18CS30042_18CS30010.l
ass5_18CS30042_18CS30010_translator.o: ass5_18CS30042_18CS30010_translator.cxx ass5_18CS30042_18CS30010_translator.h
	g++ -c ass5_18CS30042_18CS30010_translator.cxx
clean:
	rm lex.yy.o y.tab.o ass5_18CS30042_18CS30010_translator.o y.tab.c lex.yy.c a.out y.tab.h y.output ass5_18CS30042_18CS30010_quads*