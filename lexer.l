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

(" ")+							{ }
([#][#]|[/][/]).*				{ printf("[comment at line %d: \"%s\"]\n", yylineno, yytext); }


"string" 						|
"int" 							|
"bool"	 						{ 
								  printf("[type at line %d: \"%s\"]\n", yylineno, yytext);
								  return TYPE; 
								}

"printf"						{ return PRINTF; }

"void" 							{ return VOID; }

"struct"						{ return STRUCT; }

"for"							{ return FOR; }

"if"							{ return IF; }
"else"							{ return ELSE; }
"then"							{ return THEN; }
"true"							{ return TRUE; }
"false"							{ return FALSE; }
"return"						{ return RETURN; }

"=="   				   	 		|
"!="   				   	 		|
"<"								|
">"								|
"<="   				   	 		|
">="   				   	 		{ return BOOL_OP; }

"mod"							{ return MOD; }
"and"							{ return AND; }
"or"							{ return OR; }

"("								|
")"								|
";"								|
"+"   				   			|
"-"								|
"*"   				   	 		|
"/"   				    		|
"{" 							|
"}"								|
"!"   				   	 		|
"."								|
","								|
"="   				   	 		{ printf("[ch at line %d: \"%s\"]\n", yylineno, yytext); return yytext[0]; }


[-]?[0-9]+						{ 
								  long lval = strtoul(yytext, NULL, 0);
								  printf("[number at line %d: \"%s\"]\n", yylineno, yytext);
								  	  
								  if( lval > INT_MAX || lval < INT_MIN ) 
								  { 
									  printf("ERROR at line %d: \"%lu\"\n", yylineno, lval);
									  yyerror("ERROR: Integer limit");
								  }
								  else
								  {
									  return NUMBER;
								  }	
								  	
								}

["]([a-zA-Z0-9_! ])*["]			{ printf("[strliteral at line %d: %s]\n", yylineno, yytext); return STRINGLITERAL; }	  
[a-zA-Z_][a-zA-Z_0-9]*			{ printf("[identifier at line %d: \"%s\"]\n", yylineno, yytext); 
								  yylval.id = (char*)strdup(yytext); 
								  return ID;
								}	 


[\r\n]+							|
[\t]+							{ }	  

.								{ 	
									yyerror("ERROR: Unrecognized character");
								}

%%
