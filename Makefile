default: build

build:
	flex -l lexer.l
	bison -d parser.y
	cc lex.yy.c parser.tab.c -lfl
	
run: build
	./a.out $(file)

clean:
	rm a.out parser.tab.* lex.yy.c