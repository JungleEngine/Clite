clite: lex.yy.c y.tab.c
	gcc -g lex.yy.c y.tab.c -o clite

lex.yy.c: y.tab.c clite.l
	lex clite.l

y.tab.c: clite.y
	yacc -d clite.y

clean: 
	rm -rf lex.yy.c y.tab.c y.tab.h clite clite.dSYM

