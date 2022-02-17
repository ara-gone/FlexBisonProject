default: build

build:
	flex lexer.l
	cc lex.yy.c -lfl
	
run: build
	./a.out $(file)
