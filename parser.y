%{
	#include <stdio.h>
  #include <stdlib.h>
  #include "SymTable.h"
  
  /* guide for node-types:
  
    N = unary negation operator '-'
    D = integer
    I = identifier <id>
    L = left expression
    S = struct entry
    G = struct declaration
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
  void check_procs();
  char* prettyPrintNodeTypes(int t);

  int add_symbol(char* sym_name, int nodetype, char* type, char* scope) {  
    symrec *s;
    s = getsym (sym_name);
    if (s == 0)
    {
      s = putsym (sym_name, nodetype, type, scope);
    }
    else 
    { 
      if (strcmp(scope,s->scope) != 0) // if scope is different, can redefine!
      {
        s->type = type;
        s->scope = scope;
      }
      else
      {
        yyerror("redeclaration of variable within same scope");
      }
    }  
  }

  int get_sym_type(char* sym_name) { 
    
    struct symrec *ptr = getsym( sym_name );
    if ( getsym( sym_name ) == 0 ) 
    {
        yyerror("undeclared ID or record type in symtable");
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
  
  int check_scope(char* scope, int type) { 
    
    struct symrec *ptr = getsym( scope );

    if (scope != NULL)
    {
        int t;
        t = get_sym_type(scope);

        // printf( "does %s = %s in %s?(%d=%d) \n", prettyPrintNodeTypes(type), 
        //   prettyPrintNodeTypes(t), scope, type, t );

        if (t != type)
          yyerror("return type or lexp reference is incorrect");
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
        int t;
        t = get_sym_type(sym_name);

        // printf( "does %s = %s?(%d=%d) \n", prettyPrintNodeTypes(type), 
        //   prettyPrintNodeTypes(t), type, t );

        if (t != type)
          yyerror("badly typed assignment or function declaration");
    }
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
        case 'T' :

        return (node->nodetype); // current node!

        default :
        break;
      }
    }
    
    return 0;
  } 


  // vars for scoping

  char* scope;
  char* buffer;
  int sc_num = 0;
  int arg_counter;
  int asprintf(char **restrict strp, const char *restrict fmt, ...);

  int enter_scope(char* sc)
  {
    strcpy(scope,sc); 
    asprintf(&buffer, "%d", sc_num); 
    strcat(scope,buffer);  
  }

  int add_call(char* fname, char* scope, int type) {  
    call *c;
    c = putcall(fname, scope, type);
    // do checking after parse method finishes
  }

  int add_call_arg(char* fname, struct ast* arg) {  
    // do checking after parse method finishes
  }
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
%type <i> lexp

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

proc: return-type ID 
      { scope = $2; add_symbol($2, 'P', $1, scope); }
      '(' zeroOrMoreDeclarations ')' '{' zeroOrMoreStatements '}' 
;

struct: STRUCT ID 
        { scope = $2; add_symbol($2, 'S', NULL, scope); }
        '{' oneOrMoreDeclarations '}' 
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

declaration: type ID { add_symbol($2, 'G', $1, scope); }
;

stmt: FOR '(' ID { enter_scope("for"); } '=' expr ';' expr ';' stmt ')' '{' stmt-seq '}' 
      { 
        sc_num++;
        if (type_check($8) != 'B') yyerror("expr in FOR is not a boolean exp"); 
      }

  | PRINTF '(' STRINGLITERAL ')' ';' 
  | RETURN expr ';'                 { check_scope(scope, type_check($2)); }  
  | type ID ';'                     { add_symbol($2, 'I', $1, scope); }                 
  | ID '=' expr ';'                 { context_check( $1, type_check($3) ); }                   
  | ID '.' lexp '=' expr ';'        { get_sym_type($1); if (type_check($5) != $3) yyerror("bad struct reference");  }                    
  | ID '(' args ')' ';'            { add_call($1, scope, -1); arg_counter = 0; }                // check proc calls later!                   
  | ID '=' ID '(' args')' ';'     { add_call($3, scope, get_sym_type($1)); arg_counter = 0; }  // ...after initial parse do this -> { context_check($1, get_sym_type($3)); } 
;

if_stmt: mt_stmt
  | unmt_stmt
;
                                                                   // print_tree($3); 
mt_stmt: IF '(' expr ')' THEN '{' mt_stmt '}' ELSE '{' mt_stmt '}' { type_check($3); scope = "if"; }
  | stmt
; 

unmt_stmt: IF '(' expr ')' THEN '{' mt_stmt '}'                   { type_check($3); scope = "if"; }
  | IF '(' expr ')' THEN '{' mt_stmt '}' ELSE '{' unmt_stmt '}'   { type_check($3); scope = "if"; }
;

args: /* empty  */
    | exprs
;

exprs: expr            { call_table->args[arg_counter++] = $1; }
    | expr "," exprs   { call_table->args[arg_counter++] = $1; }
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
  | STRINGLITERAL       { $$ = newval('T', $1); }
  | TRUE                { $$ = newval('B', "true"); }
  | FALSE               { $$ = newval('B', "false"); }
  | lexp                { $$ = newval($1, NULL); }  
  | '(' expr ')'        { $$ = newast('(', $2, NULL); }
;

lexp: ID                { $$ = get_sym_type($1); }
  | ID '.' lexp         { check_scope($1,$3); $$ = $3; }
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

  scope = (char *) malloc(100);
  buffer = (char *) malloc(100);
  arg_counter = 0;

  extern FILE* yyin;
  yyin = fopen(argv[1], "r");

  int parse = yyparse();
  fclose(yyin);
  display_table();

  if(parse != 0)
  {
    yyerror("INVALID\n");
  } 

  check_procs();

  printf("VALID\n");
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
      case 'T' :
        return "string";
        break;
      case 'G' :
        return "declaration";
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
  
  void check_procs()
  {
    call *ptr;
    for (ptr = call_table; ptr != (call *)0; ptr = (call*)ptr->next)
    {
      // printf("%s : %s : %d\n", ptr->fname, ptr->scope, ptr->type);
      // check all typed calls
      if (ptr->type != -1)
      {
        if (ptr->type != get_sym_type(ptr->fname))
        {
          yyerror("bad procedure call");
        }

        int max_args_size = 100;
        for (int i = 0; i < max_args_size; i++)
        {
          struct ast *node = ptr->args[i];
          type_check(node);
        }
      }

    }
  }

  int display_table()
  {
    FILE * pFile;
    pFile = fopen ("symbol_table.txt","w");

    fprintf(pFile,"%-15s %-15s %-15s %-15s \n", 
      "*identifier*", "*id_type*", "*var_type*", "*scope*");
    fprintf(pFile,"%-15s %-15s %-15s %-15s \n", 
      "----------", "-----", "----------", "-----");

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
        fprintf(pFile,"%-15s %-15s %-15s %-15s \n", ptr->name, 
          prettyPrintNodeTypes(ptr->nodetype), ptr->type, ptr->scope);
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

  