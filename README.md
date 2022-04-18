# Lexical Analysis using Flex and Bison

Implementing a sample parser for a trivial toy language. Flex is used for tokenization, and Bison for parsing.

## How to run

```c++
make run file=($filepath)
```
Parses a .txt file with output.
The makefile accepts strictly one file argument of format 'txt'.
A test suite is provided in the /tests folder.

## Miscellaneous

Reference files are generated with the format '.txt' when the program is run to assist in error-checking.

symbol_table.txt: outputs a list of all entries in the symbol table, separated by name and type
lexer_output.txt: outputs a list and value of all tokens returned by yylex()

