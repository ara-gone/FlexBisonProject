#include "SymTable.h"
#include <stdio.h>
#define LIMIT 100

struct init
{
  char const *name;
};

struct init vals[] =
{
  { "variable" },
  { "y" },
  { "x" },
};

int main()
{
  for (int i = 0; vals[i].name; i++)
  {
      symrec *ptr = putsym (vals[i].name);
  }
  display_table();
}

int display_table()
{
    symrec *ptr;
    for (ptr = sym_table; ptr != (symrec *)0; ptr = (symrec*)ptr->next)
        printf("Entry: %s\n", ptr->name);
    return 0;
}