
%{
	#include <stdio.h>
  #include <stdlib.h>

  int yyerror(const char *msg);
  int yylex();
%}

%token NUMBER VALID 
%token ID STRINGLITERAL FOR RETURN 
%token TYPE BOOL_OP STRUCT VOID PRINTF
%token EQU MOD AND OR IF THEN ELSE TRUE FALSE

%nonassoc BOOL_OP
%right '='
%left '!'
%left '+' '-'
%left '*' '/' '.'
%precedence "lexp"
%nonassoc OR AND MOD 
 
%%

prog: proc progm
  | struct progm

progm: 
  | proc progm
  | struct progm
;

proc: return-type ID '(' zeroOrMoreDeclarations ')' '{' stmt '}'
;

struct: STRUCT ID '{' oneOrMoreDeclarations '}' 
;

zeroOrMoreDeclarations: 
  | declaration ',' zeroOrMoreDeclarations
;

oneOrMoreDeclarations: declaration 
  | declaration ',' oneOrMoreDeclarations
;

declaration: type ID 
;

stmt:
  | FOR '(' ID '=' expr ';' expr ';' stmt ')' '{' stmt '}' stmt
  | IF '(' expr ')' THEN '{' stmt '}' ELSE '{' stmt '}'
  | PRINTF '(' STRINGLITERAL ')' ';' stmt
  | RETURN expr ';' stmt
  | '{' stmt-seq '}'stmt
  | type ID ';'stmt
  | ID '=' expr ';' stmt
  | ID '.' lexp '=' expr ';' stmt
  | ID '(' exprs ')' ';' stmt
  | ID '=' ID '(' exprs ')' ';' stmt
;

exprs: 
    | expr "," exprs
;

stmt-seq:
  | stmt ',' stmt-seq
;

type: TYPE
  | ID 
;

return-type: TYPE 
  | VOID
;

expr: addsub
  | '-' expr
  | '!' expr

addsub: factor
  | expr '+' expr
  | expr '-' expr
;

factor: equality
  | expr '*' expr
  | expr '/' expr
;

equality: term 
  | expr OR expr
  | expr MOD expr
  | expr AND expr
;

term: NUMBER
  | STRINGLITERAL
  | TRUE
  | FALSE
  | lexp
  | '(' expr ')'
;

lexp: ID
  | ID '.' lexp
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
