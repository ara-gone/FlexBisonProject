default: build

build:
	bison -d -v parser.y
	flex lexer.l
	cc lex.yy.c parser.tab.c SymTable.h -lfl
# add SymTable.c later
	
run: build
	./a.out $(file)

clean:
	rm a.out parser.tab.* lex.yy.c