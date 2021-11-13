%option noyywrap
%option nodefault
%option yylineno
%{
#include "petrinet.tab.h"
%}

%%
"P" |
"PLACE"	{ return place; }
"T" |
"TRANSITION" { return transition; }
"A" |
"ARC" { return arc; }
"FIRE" { return fire; }
"EX_MUTUA" { return EX_MUTUA; } 
"FORK" { return FORK; } 
"SHOW" {return SHOW; }
"FROM" {return FROM; }
"TO"   {return TO; }

[a-zA-Z_]+ |
([a-zA-Z_]+[0-9]+)+ { yylval.n = strdup(yytext); return name; }
" " { return spc; }
[-0-9]+ { yylval.v = atof(yytext); return NUMERO; }
\n { return FINLINEA; }
[ \t]   {}
.	{}
%%
