%{
	#include <stdio.h>
  #include <stdlib.h>
  #include "SymTable.h"
  
  /* guide for node-types:
  
    N = unary negation operator '-'
    D = integer
    I = identifier <id>
    L = left expression
    S = struct
    T = string
    P = procedure/function
    B = boolean VALUE (true or false)
    '=' = boolean OPERATORS (AND, OR, ==, <=, <, >, >=, etc.)
  
   */

  char* itoa(int val, int base);
  int yylex();
  int display_output();
  int display_table();
  int print_tree();
  char* prettyPrintNodeTypes(int t);

  int add_symbol(char* sym_name, int nodetype, char* type) {  
    symrec *s;
    s = getsym (sym_name);
    if (s == 0)
    {
      s = putsym (sym_name, nodetype, type);
    }
    else 
    { 
      printf( "%s is already defined\n", sym_name );
    }  
  }

  int context_check(char* sym_name, int type) { 
    
    struct symrec *ptr = getsym( sym_name );
    if ( getsym( sym_name ) == 0 ) 
    {
        yyerror("undeclared ID in symtable");
        return 0;
    }
    else 
    {
        printf( "%s\n", prettyPrintNodeTypes(type) );

    }
  }

  int get_sym_type(char* sym_name) { 
    
    struct symrec *ptr = getsym( sym_name );
    if ( getsym( sym_name ) == 0 ) 
    {
        printf( "undeclared ID in symtable: %s\n", sym_name );
    }
    else 
    {
        char* s;
        s = (ptr->type);

        switch (s[0]) // use first char of type
        {
          case 'b':
          return 'B';

          case 'i':
          return 'D';

          case 's':
          return 'T';

          default:
          break;
        }
        
    }
    return 0;
  }

  int type_check(struct ast *node)
  {
    // printf("checking tree of type: %s\n", prettyPrintNodeTypes(node->nodetype));

    int left;
    int right;

    if (node != NULL) {

      int t = node->nodetype;
      switch(t) {
        // binary arithmetic operators
        case '+' :
        case '-' :
        case '*' :
        case '/' :
        case '%' :

        left = type_check(node->l);
        right = type_check(node->r);

        if (left != right)
        {
          printf( "failed type check: %s != %s\n", 
            prettyPrintNodeTypes(left),
            prettyPrintNodeTypes(right) );
        }     
        return 'D';

        // unary arithmetic operators
        case '(' :
        case 'N' :

        return left = type_check(node->l); 

        // binary boolean operators
        case '=' :
        case '&' :
        case '|' :

        left = type_check(node->l);
        right = type_check(node->r);

        if (left != right)
        {
          printf( "failed type check: %s != %s (%d!=%d)\n", 
            prettyPrintNodeTypes(left), 
            prettyPrintNodeTypes(right), left, right  );
        }

        return 'B';

        // unary boolean operators

        case '!' :

        return left = type_check(node->l);
        break;

        // single values
        case 'B' :
        case 'D' :
        case 'I' : // need to resolve I/L to become B and D through symbols!
        case 'L' :

        return (node->nodetype); // current node!

        default :
        break;
      }
    }
    
    return 0;
  }

  int scope;
%}

%union { 
  char *id; 
  int i;
  struct ast *tree;
}

%token <i> NUMBER
%token <id> ID STRINGLITERAL TYPE VOID
%token FOR RETURN VALID BOOL_OP STRUCT PRINTF
%token EQU MOD AND OR IF THEN ELSE TRUE FALSE

%type <tree> expr addsub factor equality term
%type <id> type return-type

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

proc: return-type ID '(' zeroOrMoreDeclarations ')' '{' zeroOrMoreStatements '}' { add_symbol($2, 'P', $1); }
;

struct: STRUCT ID '{' oneOrMoreDeclarations '}' { add_symbol($2, 'S', NULL); }
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

stmt: FOR '(' ID '=' expr ';' expr ';' stmt ')' '{' stmt-seq '}' { type_check($7); }
  | PRINTF '(' STRINGLITERAL ')' ';' 
  | RETURN expr ';'
  | type ID ';'       { add_symbol($2, 'I', $1); }                 // declarations
  | ID '=' expr ';'   { context_check( $1, type_check($3) ); }                   // assignment
  | ID '.' lexp '=' expr ';'                                   // referencing struct
  | ID '(' exprs ')' ';'                                       // function call
  | ID '=' ID '(' exprs ')' ';'  { context_check($1, get_sym_type($3)); }        // function assignment
;

if_stmt: mt_stmt
  | unmt_stmt
;
                                                                  // print_tree($3); 
mt_stmt: IF '(' expr ')' THEN '{' mt_stmt '}' ELSE '{' mt_stmt '}' { type_check($3); }
  | stmt
;

unmt_stmt: IF '(' expr ')' THEN '{' mt_stmt '}'                    { type_check($3); }
  | IF '(' expr ')' THEN '{' mt_stmt '}' ELSE '{' unmt_stmt '}'    { type_check($3); }
;

exprs: 
    | expr "," exprs
;

stmt-seq:
  | stmt stmt-seq
;

type: TYPE
  | ID 
;

return-type: TYPE 
  | VOID
;

expr: addsub
  | '-' expr         { $$ = newast('N', $2, NULL); }
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
  | expr OR expr        { $$ = newast('|', $1, $3); }
  | expr MOD expr       { $$ = newast('%', $1, $3); }
  | expr AND expr       { $$ = newast('&', $1, $3); }
  | expr BOOL_OP expr   { $$ = newast('=', $1, $3); }
;

term: NUMBER            { $$ = newval('D', itoa($1,10));  } // set (base=10) for base 10 conversion
  | STRINGLITERAL       { $$ = newval('S', $1); }
  | TRUE                { $$ = newval('B', "true"); }
  | FALSE               { $$ = newval('B', "false"); }
  | lexp                { $$ = newval('L', "nothing"); }   // how to get type of lexp? make a new ast type?
  | '(' expr ')'        { $$ = newast('(', $2, NULL); }
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

  // printf("atoi test: %s\n", itoa(20,10));

  display_output();

  extern FILE* yyin;
  yyin = fopen(argv[1], "r");

  int parse = yyparse();
  fclose(yyin);
  display_table();

  if(parse == 0)
  {
    printf("VALID\n");
  } 

  return 0;
}

int yyerror(const char *msg){
  printf("INVALID\n");
	fprintf(stderr, "%s\n", msg);
  exit(1);
}

char* prettyPrintNodeTypes(int t) 
{
      switch(t) {
      case '+' :
      case '-' :
      case '*' :
      case '/' :
      case '|' :
      case '%' :
      case '&' :
        return "op";
        break;
      case '!' :
        return "bool_negation";
        break;
      case '(' :
        return "prec:";
        break;
      case '=' :
        return "b_op";
        break;
      case 'B' :
        return "boolean";
        break;
      case 'D' :
        return "integer";
        break;
      case 'N' :
        return "arith_negation";
        break;
      case 'S' :
        return "struct";
        break;
      case 'P' :
        return "proc";
        break;
      case 'I' :
        return "id";
        break;
      case 'L' :
        return "lexp";
        break;
      default :
         break;
   }

   return "unknown"; // need to add error check here
  }
  

  int display_table()
  {
    FILE * pFile;
    pFile = fopen ("symbol_table.txt","w");

    fprintf(pFile,"%-15s %-15s %-15s \n", "*identifier*", "*id_type*", "*var_type*");
    fprintf(pFile,"%-15s %-15s %-15s \n", "----------", "-----", "----------");

    symrec *ptr;

    symrec *current = sym_table;
    symrec *prev = NULL;
    symrec *after = NULL;

    // reverse symbol table order for readability
    while (current != NULL) {
      after = current->next;
      current->next = prev;
      prev = current;
      current = after;
    }

    // set to new head of list
    sym_table = prev;

    for (ptr = sym_table; ptr != (symrec *)0; ptr = (symrec*)ptr->next)
    {
        fprintf(pFile,"%-15s %-15s %-15s \n", ptr->name, prettyPrintNodeTypes(ptr->nodetype), ptr->type);
    }
        
    fclose (pFile);
    return 0;
  }

  int print_tree(struct ast *node)
  {

    if (node != NULL) {
      
      int t = node->nodetype;

      switch(t) {
        case '+' :
        case '-' :
        case '*' :
        case '/' :
        case '|' :
        case '%' :
        case '&' :
        case '=' :

        printf("(");
        print_tree(node->l);
        printf("%s", prettyPrintNodeTypes(node->nodetype));
        print_tree(node->r);
        printf(")");

        break;

        case '(':
        case '!':
        case 'N':

        printf("(");
        printf("%s", prettyPrintNodeTypes(node->nodetype));
        print_tree(node->l);
        printf(")");

        break;

        default: // else if leaf node
        printf("(%s)", prettyPrintNodeTypes(node->nodetype));

        break;
      }
    }

    return 0;
  }

  char* itoa(int val, int base)
  {
    static char buf[32] = {0};
    int i = 30;
    for(; val && i ; --i, val /= base)
      buf[i] = "0123456789abcdef"[val % base];
    return &buf[i+1];
  }

  