%{
	#include <stdio.h>
  #include <stdlib.h>
  #include "SymTable.h"
  /* #define YYSTYPE char* */

  int add_identifier(char* sym_name) {  
    symrec *s;
    s = getsym (sym_name);
    if (s == 0)
    {
      s = putsym (sym_name);
    }
    else 
    { 
      printf( "%s is already defined\n", sym_name );
    }  
  }

  int context_check(char* sym_name) { 
    if ( getsym( sym_name ) == 0 ) 
        printf( "%s is an undeclared identifier\n", sym_name );
  }

  int display_table()
  {
    symrec *ptr;
    for (ptr = sym_table; ptr != (symrec *)0; ptr = (symrec*)ptr->next)
        printf("Entry: %s\n", ptr->name);
    return 0;
  }

  int yyerror(const char *msg);
  int yylex();
%}

%union { 
  char *id; 
}

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

proc: return-type ID '(' zeroOrMoreDeclarations ')' '{' zeroOrMoreStatements '}'
;

struct: STRUCT ID '{' oneOrMoreDeclarations '}' 
;

zeroOrMoreDeclarations: 
  | declaration
  | declaration ',' zeroOrMoreDeclarations
;

oneOrMoreDeclarations: declaration 
  | declaration ',' oneOrMoreDeclarations
;

zeroOrMoreStatements:
  | if_stmt zeroOrMoreStatements
;

declaration: type ID { /*  add_identifier($2); */ }
;

stmt: FOR '(' ID '=' expr ';' expr ';' stmt ')' '{' stmt '}'
  | PRINTF '(' STRINGLITERAL ')' ';' 
  | RETURN expr ';'
  | '{' stmt-seq '}'
  | type ID ';'       { add_identifier(yylval.id); }
  | ID '=' expr ';'   { context_check(yylval.id); }
  | ID '.' lexp '=' expr ';'
  | ID '(' exprs ')' ';'
  | ID '=' ID '(' exprs ')' ';'  /*  will need to fix error with add_identifier($2); */
;

if_stmt: mt_stmt
  | unmt_stmt
;

mt_stmt: IF '(' expr ')' THEN '{' mt_stmt '}' ELSE '{' mt_stmt '}'
  | stmt
;

unmt_stmt: IF '(' expr ')' THEN '{' mt_stmt '}' 
  | IF '(' expr ')' THEN '{' mt_stmt '}' ELSE '{' unmt_stmt '}'
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
  display_table();

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
