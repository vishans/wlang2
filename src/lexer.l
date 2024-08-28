%{
#include "parser.tab.h"
#include <string>
#include <iostream>

// Externally defined in parser.tab.h
extern int yylval;

// To keep track of line numbers for better error messages
int line_number = 1;
%}

%option noyywrap


%%
"workout"           { return WORKOUT; }
"exercise"          { return EXERCISE; }
"sets"              { return SETS; }
"reps"              { return REPS; }
"weight"            { return WEIGHT; }
"set"               { return SET; }
"rep"               { return REP; }
"rest"              { return REST; }
"field"             { return FIELD; }
"default"           { return DEFAULT; }
"type"              { return TYPE; }
"as"                { return AS; }
"string"            { return STRING_TYPE; }
"integer"           { return INTEGER_TYPE; }
"float"             { return FLOAT_TYPE; }
"time"              { return TIME_TYPE; }
"boolean"           { return BOOLEAN_TYPE; }
"true"|"false"      { yylval.str = strdup(yytext); return BOOLEAN_LITERAL; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return IDENTIFIER; }
\"[^\"]*\"          { yylval.str = strdup(yytext); return STRING; }
[0-9]+\.[0-9]+      { yylval.str = strdup(yytext); return FLOAT_LITERAL; }
[0-9]+              { yylval.str = strdup(yytext); return INTEGER_LITERAL; }
([0-9]+[hms]?|([0-9]+h[0-9]+m?|[0-9]+m[0-9]+s?|[0-9]+s)) { yylval.str = strdup(yytext); return TIME_LITERAL; }
"{"                 { return '{'; }
"}"                 { return '}'; }
"-"                 { return '-'; }
[ \t]+              { /* ignore whitespace */ }
\n                  { line_number++; }
.                   { std::cerr << "Unknown character: " << yytext << " at line " << line_number << std::endl; return yytext[0]; }
%%

// Function to handle errors
int yywrap() {
    return 1;
}