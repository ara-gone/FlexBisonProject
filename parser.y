
%{
	#include <stdio.h>
  #include <stdlib.h>

  int yyerror(const char *msg);
  int yylex();
%}

%token NUMBER VALID 
%token ID INTLITERAL STRINGLITERAL
%token RESERVE TYPE BOOL_OP STRUCT
%token EQU

%%

prog: proc progm
  | struct progm

progm: 
  | proc progm
  | struct progm
;

proc: RESERVE ID '(' declarations ')' '{' stmt '}'
;

struct: RESERVE ID '{' declarations '}' 
;

declarations: 
  | TYPE ID 
  | TYPE ID ',' declarations
;

stmt: 
  | lexp '=' expr
; 

lexp: ID 
  | ID '.' lexp
;

expr: NUMBER
;

%%

/* user code */


int main(int argc, char *argv[])
{

  if (argc !=2) {
    return 1; 
  }

  extern FILE* yyin;
  yyin = fopen(argv[1], "r");

  int parse = yyparse();
  fclose(yyin);

  if(parse == 0)
  {
    printf("Parser: VALID\n");
  } 

  return 0;
}

int yyerror(const char *msg){
	fprintf(stderr, "%s\n", msg);
  exit(1);
}
