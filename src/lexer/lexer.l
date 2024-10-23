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
"workout" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    return WORKOUT; 
}

"exercise" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    return EXERCISE; 
}

"sets" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    return SETS; 
}

"reps" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    return REPS; 
}

"set" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    return SET; 
}

"rep" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    return REP; 
}

"rest" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    return REST; 
}

"field" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    return FIELD; 
}

"default" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    return DEFAULT; 
}

"type" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    return TYPE; 
}

"as" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    return AS; 
}

"string" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    return STRING_TYPE; 
}

"integer" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    return INTEGER_TYPE; 
}

"float" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    return FLOAT_TYPE; 
}

"time" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    return TIME_TYPE; 
}

"boolean" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    return BOOLEAN_TYPE; 
}

"fail" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    return FAIL; 
}

"const" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    return CONST; 
}

"true"|"false" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    return BOOLEAN_LITERAL; 
}

[a-zA-Z_][a-zA-Z0-9_]* { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    return IDENTIFIER; 
}

\"[^\"]*\" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    return STRING; 
}

[0-9]+ { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    return INTEGER_LITERAL; 
}

[0-9]*(\.[0-9]+)? { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    return FLOAT_LITERAL; 
}

([0-9]+h)?([0-9]+m)?([0-9]+s)? { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    return TIME_LITERAL; 
}

"{" { 
    yylval.token_info.str = nullptr; 
    yylval.token_info.line = line_number; 
    return '{'; 
}

"}" { 
    yylval.token_info.str = nullptr; 
    yylval.token_info.line = line_number; 
    return '}'; 
}

"-" { 
    yylval.token_info.str = nullptr; 
    yylval.token_info.line = line_number; 
    return '-'; 
}

[ \t]+ { 
    /* ignore whitespace */ 
}

\n { 
    line_number++; 
}

. { 
    std::cerr << "Unknown character: " << yytext << " at line " << line_number << std::endl; 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    return yytext[0]; 
}

"//".* { 
  // Ignore line comment
}

"/*"([^*]|[\r\n]|"*"[^/])*"*/" { 
     // Count newlines inside block comments
   std::cout << yytext << std::endl;
    for (char *c = yytext; *c; ++c) {
        // std::cout << "c is: " << *c << std::endl;
        if (*c == '\n') {
            ++line_number;
            std::cout << "\t Incremented" << std::endl;
        }
    } 
}

%%


// Function to handle errors
//int yywrap() {
//   return 1;
//}