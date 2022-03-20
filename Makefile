default: build

build:
	bison -d parser.y
	flex lexer.l
	cc lex.yy.c parser.tab.c -lfl
	
run: build
	./a.out $(file)

clean:
	rm a.out parser.tab.* lex.yy.c