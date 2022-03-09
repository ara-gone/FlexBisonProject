
%{
#  include <stdio.h>
%}

%token EOL
%token ID
%token RESERVE

%%

prog: proc
  | proc prog { }
  | struct prog { }

struct: RESERVE ID '{' declarations '}' { }

declarations: RESERVE ID 
  | RESERVE ID declarations

proc: RESERVE ID '(' declarations ')' '{' stmt '}'
stmt: 
  
%%

main()
{
  printf("> "); 
  yyparse();
}

yyerror(char *s)
{
  fprintf(stderr, "error: %s\n", s);
}

#include "lex.yy.c"
