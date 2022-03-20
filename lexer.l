/* declarations */
	
%{
	#include <stdio.h>
	#include <limits.h>
	#include "parser.tab.h"

	int yyerror(const char *msg);
	int yyltex;
%}

/* lexical analysis */

%%



(" ")+							|
([#][#]|[/][/])[a-zA-Z0-9_" "]* { }


"struct"						|
"void" 							|
"string" 						|
"int" 							|
"bool"	 						{ 
								  printf("[keyword at line %d: \"%s\"]\n", yylineno, yytext);
								  return RESERVE; 
								}

"&&"   				   	 		|
"||"   				   	 		|
"=="   				   	 		|
"!="   				   	 		|
"<"								|
">"								|
"<="   				   	 		|
">="   				   	 		{ return BOOL_OP; }

"("								|
")"								|
";"								|
"+"   				   			|
"-"								|
"*"   				   	 		|
"%"   				   	 		|
"/"   				    		|
"{" 							|
"}"								|
"!"   				   	 		|
"="   				   	 		{ printf("[ch at line %d: \"%s\"]\n", yylineno, yytext); return yytext[0]; }


[-]?[0-9]+						{ 
								  yylval = strtoul(yytext, NULL, 0);
								  printf("[number at line %d: \"%s\"]\n", yylineno, yytext);
								  
								  if(yylval > INT_MAX || yylval < INT_MIN ) 
								  { 
									  yyerror("ERROR: Integer limit");
								  }
								  else
								  {
									  return NUMBER;
								  }	
								  	
								}

["]([a-zA-Z0-9_! ])*["]			{ printf("[strliteral at line %d: \"%s\"]\n", yylineno, yytext); return STRINGLITERAL; }	  
[a-zA-Z_][a-zA-Z_0-9]*			{ printf("[identifier at line %d: \"%s\"]\n", yylineno, yytext); return ID; }	 


[\r\n]+							|
[\t]+							{ }	  

.								{ 	
									yyerror("ERROR: Unrecognized character");
								}

%%

