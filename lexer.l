/* declarations */

%{
	int chars = 0;
	int words = 0;
	int lines = 0;
%}

/* lexical analysis */

%%
([#][#]|[/][/])[a-zA-Z0-9_" "]* { printf("COMMENT "); }
"void" 							{ printf("VOID "); }
"struct" 						{ printf("STRUCT "); }
"string" 						{ printf("STRING "); }
"int" 							{ printf("INT "); }
"bool"	 						{ printf("BOOL "); }
"+"   				   			{ printf("PLUS "); }
"-"   				   	 		{ printf("MINUS "); }
"*"   				   	 		{ printf("MUL "); }
"="   				   	 		{ printf("EQU "); }
"/"   				    		{ printf("DIV "); }
"{" 							{ printf("LEFTBRACE "); }
"}" 							{ printf("RIGHTBRACE "); }
[-]?[0-9]*						{ printf("INTLITERAL "); }
[\\"][a-zA-Z0-9_" "]*[\\"]	    { printf("STRINGLITERAL "); }
[a-zA-Z_][a-zA-Z0-9_]*  		{ printf("IDENTIFIER "); } 
\n					    		{ printf("EOL\n"); }
\t								{ printf("\t"); }
.								{ }

%%

/* user code */

int main(int argc, char *argv[])
{
  if (argc !=2) {
	  return 1; // need to add error checking + message
  }
  
  yyin = fopen(argv[1], "r");
  yylex(); 
  fclose(yyin);
  // printf("LINES: %3d, WORDS: %3d, CHARACTERS:, %3d\n", ++lines, words, chars);
}
