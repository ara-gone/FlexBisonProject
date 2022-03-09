default: build

build:
	flex lexer.l
	bison -d parser.y
	cc lex.yy.c -lfl
	
run: build
	./a.out $(file)
