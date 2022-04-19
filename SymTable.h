#include <stdlib.h>
#include <string.h>

int yyerror(const char *msg);

struct symrec
{
  char *name;             /* name of symbol */
  int nodetype;
  char* type;
  char* scope;
  struct symrec *next;    /* link field  */
};

typedef struct symrec symrec;
symrec *sym_table = (symrec*)0;

symrec *putsym ( char *sym_name, int nodetype, char* type, char* scope )
{
  symrec *ptr;
  ptr = (symrec *) malloc (sizeof(symrec));
  ptr->name = (char *) malloc (strlen(sym_name)+1);
  strcpy (ptr->name,sym_name);
  ptr->nodetype = nodetype;
  ptr->type = type;
  ptr->scope = scope;
  ptr->next = (struct symrec *)sym_table;
  sym_table = ptr;
  return ptr;
}

symrec *getsym ( char *sym_name )
{
  symrec *ptr;
  for (ptr = sym_table; ptr != (symrec *)0; ptr = (symrec*)ptr->next)
    if (strcmp (ptr->name,sym_name) == 0)
      return ptr;
  return 0;
}

static unsigned symhash(char *sym)
{
 unsigned int hash = 0;
 unsigned c;
 while((c = *sym++)) 
  hash = hash*9 ^ c;
 return hash;
}

// handles expressions
struct ast 
{
  int nodetype;
  struct ast *l;
  struct ast *r;
};

// handles single-value nodes
struct aval
{
  int nodetype;
  char *value;
};

struct ast *newast(int nodetype, struct ast *l, struct ast *r)
{
 struct ast *a = malloc(sizeof(struct ast));

 if (!a) {
   yyerror("out of space");
   exit(0);
 }
 
 a->nodetype = nodetype;
 a->l = l;
 a->r = r;
 return a;
}

struct ast *newval(int nodetype, char* value)
{
  struct aval *a = malloc(sizeof(struct aval));

  if(!a) {
    yyerror("out of space");
    exit(0);
  }
  
  a->nodetype = nodetype;
  a->value = value;
  return (struct ast *)a;
}

struct call
{
  char *fname;
  char *scope;
  int type;
  struct ast* args[100];
  struct call *next;
};

typedef struct call call;
call *call_table = (call*)0;

call *putcall ( char *fname, char* scope, int type )
{
  call *ptr;
  ptr = (call *) malloc (sizeof(call));
  ptr->fname = (char *) malloc (strlen(fname)+1);
  ptr->scope = (char *) malloc (strlen(scope)+1);

  strcpy (ptr->fname,fname);
  strcpy (ptr->scope,scope);
  ptr-> type = type;
  ptr->next = (struct call *)call_table;
  call_table = ptr;
  return ptr;
}
