clite: lex.yy.c y.tab.c
	g++ -g lex.yy.c y.tab.c -o clite --std=c++14

lex.yy.c: y.tab.c clite.l
	lex clite.l

y.tab.c: clite.y
	yacc -dv clite.y

clean: 
	rm -rf lex.yy.c y.tab.c y.tab.h clite y.output

