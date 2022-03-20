/* declarations */
	
%{
	#include <stdio.h>
	#include "parser.tab.h"

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
">="   				   	 		{ return BOOL_OP; }

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

