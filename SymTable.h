struct symrec
{
  char *name;             /* name of symbol          */
  struct symrec *next;    /* link field              */
};
typedef struct symrec symrec;
symrec *sym_table = (symrec *)0;
symrec *putsym ();
symrec *getsym ();
