petrinet: petrinet.l petrinet.y
	bison -d petrinet.y
	flex petrinet.l lex.yy.c
	gcc -o $@ petrinet.tab.c lex.yy.c
clean:
	rm petrinet.tab.* petrinet lex.yy.c
