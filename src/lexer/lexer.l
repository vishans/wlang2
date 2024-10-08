%{
#include "../ast/ast.h"
#include "../parser/parser.tab.hpp"
#include <string>
#include <iostream>

// Externally defined in parser.tab.h
//extern int yylval;

// To keep track of line numbers for better error messages
int line_number = 1;
%}

%option noyywrap
%option yylineno


%%
"workout"           { return WORKOUT; }
"exercise"          { return EXERCISE; }
"sets"              { return SETS; }
"reps"              { return REPS; }
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
"fail"              { return FAIL; }
"const"             { return CONST; }
"true"|"false"      { yylval.str = strdup(yytext); return BOOLEAN_LITERAL; }
[a-zA-Z_][a-zA-Z0-9_]* { yylval.str = strdup(yytext); return IDENTIFIER; }
\"[^\"]*\"          { yylval.str = strdup(yytext); return STRING; }
[0-9]+              { yylval.str = strdup(yytext); return INTEGER_LITERAL; }
[0-9]*(\.[0-9]+)?   { yylval.str = strdup(yytext); return FLOAT_LITERAL; }
([0-9]+h)?([0-9]+m)?([0-9]+s)?  { yylval.str = strdup(yytext); return TIME_LITERAL; }
"{"                 { return '{'; }
"}"                 { return '}'; }
"-"                 { return '-'; }
[ \t]+              { /* ignore whitespace */ }
\n                  { line_number++; }
.                   { std::cerr << "Unknown character: " << yytext << " at line " << line_number << std::endl; return yytext[0]; }
"//".* { /* Ignore line comment */ }
"/*"([^*]|[\r\n]|"*"[^/])*"*/" { /* Ignore block comment */ }

%%

// Function to handle errors
//int yywrap() {
//   return 1;
//}