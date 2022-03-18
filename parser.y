
%{
#  include <stdio.h>
%}

%token EOL
%token ID
%token TYPE
%token RESERVE

%%

prog: 
  | proc prog { }
  | struct prog { }

struct: RESERVE ID '{' declarations '}' { }

declarations: RESERVE ID 
  | TYPE ID declarations

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
