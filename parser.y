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

  struct ast *type_check(int nodetype, struct ast *root)
  {
    printf("nodetype: %d\n", nodetype);
    return NULL;
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

  int walk_tree(struct ast *node)
  {

  }

  char* itoa(int val, int base)
  {
    static char buf[32] = {0};
    int i = 30;
    for(; val && i ; --i, val /= base)
      buf[i] = "0123456789abcdef"[val % base];
    return &buf[i+1];
  }

  int yylex();
%}

%union { 
  char *id; 
  double i;
  struct ast *tree;
}

%token <i> NUMBER
%token <id> ID STRINGLITERAL
%token FOR RETURN VALID TYPE BOOL_OP STRUCT VOID PRINTF
%token EQU MOD AND OR IF THEN ELSE TRUE FALSE

%type <tree> expr addsub factor equality term

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

stmt: FOR '(' ID '=' expr ';' expr ';' stmt ')' '{' stmt '}'  { type_check('B', $7); }
  | PRINTF '(' STRINGLITERAL ')' ';' 
  | RETURN expr ';'
  | '{' stmt-seq '}'
  | type ID ';'       { add_symbol($2, 'I'); }                 // declarations
  | ID '=' expr ';'   { context_check($1); }                   // assignment
  | ID '.' lexp '=' expr ';'                                   // referencing struct
  | ID '(' exprs ')' ';'                                       // function call
  | ID '=' ID '(' exprs ')' ';'  { context_check($1); }        // function assignment
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
  | '-' expr         { $$ = newast('-', $2, NULL); }
  | '!' expr         { $$ = newast('!', $2, NULL); }
;

addsub: factor
  | expr '+' expr    { $$ = newast('+', $1, $3); }
  | expr '-' expr    { $$ = newast('-', $1, $3); }
;

factor: equality  
  | expr '*' expr    { $$ = newast('*', $1, $3); }
  | expr '/' expr    { $$ = newast('/', $1, $3); }
;

equality: term 
  | expr OR expr
  | expr MOD expr
  | expr AND expr
  | expr BOOL_OP expr
;

term: NUMBER         { $$ = newval('D', itoa($1,10)); printf(itoa($1,10)); }
  | STRINGLITERAL    { $$ = newval('S', $1); }
  | TRUE             { $$ = newval('B', "true"); }
  | FALSE            { $$ = newval('B', "false"); }
  | lexp             { $$ = newval('L', "stub"); } // how to get type of lexp? make a new ast type?
  | '(' expr ')'     { $$ = newast('|', $2, NULL); }
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
