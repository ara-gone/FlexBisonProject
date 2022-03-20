
%{
	#include <stdio.h>
  int yylex();
  int yyerror(const char *msg);
%}

%token NUMBER ERR VALID 
%token ID INTLITERAL STRINGLITERAL
%token RESERVE TYPE BOOL_OP

%%

prog: 
  | proc prog { }
  | struct prog { }
;

struct: RESERVE ID '{' declarations '}' { }
;

declarations: RESERVE ID 
  | TYPE ID declarations
;

proc: RESERVE ID '(' declarations ')' '{' stmt '}'
;
stmt:
; 
  
%%

/* user code */

#include <limits.h>
int main(int argc, char *argv[])
{

  if (argc !=2) {
    return 1; 
  }

  extern FILE* yyin;
  yyin = fopen(argv[1], "r");

  int tok; 
  while(tok = yylex()) {

    if(tok == NUMBER)
    {
      if(yylval > INT_MAX || yylval < INT_MIN ) 
      { 
        printf("ERROR\n");
        return ERR; 
      }	
    }
    
    if(tok == ERR)
    {
      printf("ERROR\n");
      return ERR;
    }

  }

  printf("Lexer: VALID\n");

  int parse = yyparse();
  if(parse == 0)
  {
    printf("Parser: VALID\n");
  } 
  return 0;
}

int yyerror(const char *msg){
	fprintf(stderr, "%s\n", msg);
  return 0;
}
