
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
  | struct prog

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
  | FOR '(' ID '=' expr ';' expr ';' stmt ')' stmt 
  | IF '(' expr ')' THEN stmt ELSE stmt
  | PRINTF '(' STRINGLITERAL ')' ';'
  | RETURN expr ';' 
  | '{' stmt-seq '}'
  | type ID ';'
  | ID '=' expr ';'
  | ID '.' lexp '=' expr ';'
  | ID '(' exprs ')' ';'
  | ID '=' ID '(' exprs ')' ';'
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
