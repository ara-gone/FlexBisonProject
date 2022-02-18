/* declarations */
	
%{
   enum yytokentype {
     NUMBER = 1,
	 ERR = 2
   };

	int yylval;
	int yyltex;

%}

/* lexical analysis */

%%

(" ")*							{ }

([#][#]|[/][/])[a-zA-Z0-9_" "]* { }
[(][)]							|

"void" 							{ }
"struct" 						|
"string" 						|
"int" 							|
"bool"	 						|
";"								|
"+"   				   			|
"-"   				   	 		|
"*"   				   	 		|
"="   				   	 		|
"<="   				   	 		|
">="   				   	 		|
"/"   				    		|
"{" 							|
"}" 							|

[-]?[0-9]						{ 
								  yylval = atoi(yytext);
								  return NUMBER;	
								}
[-]?[0-9]+[a-zA-Z0-9_" "]*		{ }

["][a-zA-Z0-9_" "]*["]			{ }
								  
[a-zA-Z_][a-zA-Z0-9_]*  		{ } 
							
[;]?[\r\n]+						{ }
[\t]+							{ }		  

.								{ printf("ERROR "); 
								  printf(yytext); 
								  printf("\n"); }

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
		if(yylval > INT_MAX) { printf("badint "); 
		printf(yylval); 
		printf("\n"); }
	}

  }
  fclose(yyin);
}