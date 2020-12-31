a.out: lex.yy.o y.tab.o asgn4_18CS30042.o
	gcc lex.yy.o y.tab.o asgn4_18CS30042.o -lfl

lex.yy.o: lex.yy.c
	gcc -c lex.yy.c

y.tab.o: y.tab.c
	gcc -c y.tab.c

asgn4_18CS30042.o: asgn4_18CS30042.c
	gcc -c asgn4_18CS30042.c

lex.yy.c: asgn4_18CS30042.l y.tab.h
	flex asgn4_18CS30042.l

y.tab.c: asgn4_18CS30042.y
	yacc -dtv asgn4_18CS30042.y -W

y.tab.h: asgn4_18CS30042.y
	yacc -dtv asgn4_18CS30042.y -W

test: 
	./a.out < asgn4_18CS30042_test.c

clean:
	rm lex.yy.c y.tab.c y.tab.h lex.yy.o y.tab.o asgn4_18CS30042.o y.output a.out

asgn4_18CS30042.c:
		touch asgn4_18CS30042.c 