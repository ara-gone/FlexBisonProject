/* declarations */
	
%{
   enum yytokentype {
     NUMBER = 1,
	 ERR = 2,
	 VALID = 3
   };

	long yylval;
	int yyltex;

%}

/* lexical analysis */

%%

(" ")+							|

([#][#]|[/][/])[a-zA-Z0-9_" "]* |
[(][)]							|

"void" 							|
"struct" 						|
"string" 						|
"int" 							|
"bool"	 						|
";"								|
"+"   				   			|
"-"								|
"*"   				   	 		|
"%"   				   	 		|
"&&"   				   	 		|
"||"   				   	 		|
"!"   				   	 		|
"="   				   	 		|
"=="   				   	 		|
"!="   				   	 		|
"<"								|
">"								|
"<="   				   	 		|
">="   				   	 		|
"/"   				    		|
"{" 							|
"}"								{return VALID;}

[-]?[0-9]+						{ 
								  yylval = strtoul(yytext, NULL, 0);
								  return NUMBER;	
								}

["]([a-zA-Z0-9_! ])*["]			|
[a-zA-Z_]+						|
[;]?[\r\n]+						|
[\t]+							{ return VALID;}	  

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
  printf("VALID\n");
  fclose(yyin);
}