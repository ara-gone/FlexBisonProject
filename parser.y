%{
	#include <stdio.h>
  #include <stdlib.h>
  #include "SymTable.h"
  /* #define YYSTYPE char* */

  int add_symbol(char* sym_name, int type) {  
    symrec *s;
    s = getsym (sym_name);
    if (s == 0)
    {
      // printf( "adding type: %d \n", type );
      s = putsym (sym_name, type);
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

  char* prettyPrintNodeTypes(int t) 
  {
      switch(t) {
      case 'S' :
        return "struct";
        break;
      case 'P' :
        return "proc";
        break;
      case 'I' :
        return "id";
        break;
      default :
         printf("Invalid node!\n" );
   }

   return NULL; // need to add error check here
  }

  int display_table()
  {
    FILE * pFile;
    pFile = fopen ("symbol_table.txt","w");

    symrec *ptr;
    for (ptr = sym_table; ptr != (symrec *)0; ptr = (symrec*)ptr->next)
    {
        fprintf(pFile,"%-15s %-15s \n", ptr->name, prettyPrintNodeTypes(ptr->type));
    }
        // fprintf("entry: %s with nodetype: %d\n", ptr->name, ptr->type);
        
    fclose (pFile);
    return 0;
  }

  int yyerror(const char *msg);
  int yylex();
%}

%union { 
  char *id; 
  double num;
}

%token <double> NUMBER 
%token <id> ID 
%token STRINGLITERAL FOR RETURN VALID 
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

proc: return-type ID '(' zeroOrMoreDeclarations ')' '{' zeroOrMoreStatements '}' { add_symbol($2, 'P'); }
;

struct: STRUCT ID '{' oneOrMoreDeclarations '}' { add_symbol($2, 'S'); }
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

declaration: type ID { /*  add_symbol($2); */ }
;

stmt: FOR '(' ID '=' expr ';' expr ';' stmt ')' '{' stmt '}'
  | PRINTF '(' STRINGLITERAL ')' ';' 
  | RETURN expr ';'
  | '{' stmt-seq '}'
  | type ID ';'       { add_symbol($2, 'I'); }
  | ID '=' expr ';'   { context_check($1); } 
  | ID '.' lexp '=' expr ';'
  | ID '(' exprs ')' ';'
  | ID '=' ID '(' exprs ')' ';'  { context_check($1); }
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
  | expr BOOL_OP expr
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
