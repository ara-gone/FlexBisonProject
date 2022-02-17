/* declarations */
	
%{
   enum yytokentype {
     NUMBER = 1,
	 ERR = 2
   };

	int yylval;
	int yyltex;

%}

COMMENT ([#][#]|[/][/])[a-zA-Z0-9_" "]*

/* lexical analysis */

%%

(" ")*							{ }

{COMMENT} 						{ printf("COMMENT "); }

"void" 							{ printf("VOID "); }
"struct" 						{ printf("STRUCT "); }
"string" 						{ printf("STRING "); }
"int" 							{ printf("INT "); }
"bool"	 						{ printf("BOOL "); }
"+"   				   			{ printf("PLUS "); }
"-"   				   	 		{ printf("MINUS "); }
"*"   				   	 		{ printf("MUL "); }
"="   				   	 		{ printf("EQU "); }
"<="   				   	 		{ printf("LE "); }
">="   				   	 		{ printf("GE "); }
"/"   				    		{ printf("DIV "); }
"{" 							{ printf("LEFTBRACE "); }
"}" 							{ printf("RIGHTBRACE "); }

[-]?[0-9]						{ printf("INTLITERAL ");
								  yylval = atoi(yytext);
								  return NUMBER;	}
[-]?[0-9]+[a-zA-Z0-9_" "]*		{ printf("ERROR "); }

["][a-zA-Z0-9_" "]*["]			{ printf("STRINGLITERAL "); }

								  
[a-zA-Z_][a-zA-Z0-9_]*  		{ printf("IDENTIFIER "); } 
							
[;]?[\r\n]+						{ printf("EOL\n"); }
[\t]+							{ printf("\t"); }		  

.								{ printf("ERROR "); }

%%

/* user code */

#include <limits.h>
int main(int argc, char *argv[])
{
  if (argc !=2) {
	  return 1; 
  }
  
  int tok; 
  yyin = fopen(argv[1], "r");
  while(tok = yylex()) {
	if(tok == NUMBER)
	{
		if(yylval > INT_MAX) { printf("badint "); }
	}

  }
  fclose(yyin);
}