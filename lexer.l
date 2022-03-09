/* declarations */
	
%{
   enum yytokentype {
     NUMBER = 1,
	 ERR = 2,
	 VALID = 3,
	 ID = 4,
	 INTLITERAL = 5,
	 STRINGLITERAL = 6,
	 RESERVE = 7,
	 BOOL_OP = 8,
   };

	long yylval;
	int yyltex;

%}

/* lexical analysis */

%%



(" ")+							|
[(][)]							|	

([#][#]|[/][/])[a-zA-Z0-9_" "]* { }

					
"void" 							|
"struct" 						|
"string" 						|
"int" 							|
"bool"	 						{ return RESERVE; }

"&&"   				   	 		|
"||"   				   	 		|
"=="   				   	 		|
"!="   				   	 		|
"<"								|
">"								|
"<="   				   	 		|
">="   				   	 		{ }

";"								|
"+"   				   			|
"-"								|
"*"   				   	 		|
"%"   				   	 		|
"/"   				    		|
"{" 							|
"}"								|
"!"   				   	 		|
"="   				   	 		{ return yytext[0]; }


[-]?[0-9]+						{ 
								  yylval = strtoul(yytext, NULL, 0);
								  return NUMBER;	
								}

["]([a-zA-Z0-9_! ])*["]			{ return STRINGLITERAL; }	  
[a-zA-Z_][a-zA-Z_0-9]*			{ return ID; }	 


[\r\n]+							|
[\t]+							{ }	  

.								{ 	
									return ERR;
								}

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

	/* 
	error checking 	
	printf("%d\n", tok); 
	*/
		
	if(tok == NUMBER)
	{
		if(yylval > INT_MAX || yylval < INT_MIN ) 
		{ 
			printf("ERROR\n");
			return ERR; 
		}	
	}
	
	if(tok == ERR)
	{
		printf("ERROR\n");
		return ERR;
	}
  }
  printf("Lexer: VALID\n");
  fclose(yyin);
}