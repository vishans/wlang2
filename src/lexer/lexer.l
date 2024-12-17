%{
#include "../ast/ast.h"
#include "../parser/parser.tab.hpp"
#include <string>
#include <iostream>
#include <cstdlib>

// Externally defined in parser.tab.h
//extern int yylval;

// To keep track of line numbers and columns for better error messages
int line_number = 1;
int column = 1;
%}

%option noyywrap
%option yylineno

%%

"workout" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    yylval.token_info.column = column;
    column += yyleng;
    return WORKOUT; 
}

"exercise" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    yylval.token_info.column = column;
    column += yyleng;
    return EXERCISE; 
}

"sets" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    yylval.token_info.column = column;
    column += yyleng;
    return SETS; 
}

"reps" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    yylval.token_info.column = column;
    column += yyleng;
    return REPS; 
}

"set" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    yylval.token_info.column = column;
    column += yyleng;
    return SET; 
}

"rep" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    yylval.token_info.column = column;
    column += yyleng;
    return REP; 
}

"rest" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    yylval.token_info.column = column;
    column += yyleng;
    return REST; 
}

"field" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    yylval.token_info.column = column;
    column += yyleng;
    return FIELD; 
}

"default" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    yylval.token_info.column = column;
    column += yyleng;
    return DEFAULT; 
}

"type" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    yylval.token_info.column = column;
    column += yyleng;
    return TYPE; 
}

"as" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    yylval.token_info.column = column;
    column += yyleng;
    return AS; 
}

"string" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    yylval.token_info.column = column;
    column += yyleng;
    return STRING_TYPE; 
}

"integer" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    yylval.token_info.column = column;
    column += yyleng;
    return INTEGER_TYPE; 
}

"float" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    yylval.token_info.column = column;
    column += yyleng;
    return FLOAT_TYPE; 
}

"time" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    yylval.token_info.column = column;
    column += yyleng;
    return TIME_TYPE; 
}

"boolean" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    yylval.token_info.column = column;
    column += yyleng;
    return BOOLEAN_TYPE; 
}

"fail" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    yylval.token_info.column = column;
    column += yyleng;
    return FAIL; 
}

"const" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    yylval.token_info.column = column;
    column += yyleng;
    return CONST; 
}

"true"|"false" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    yylval.token_info.column = column;
    column += yyleng;
    return BOOLEAN_LITERAL; 
}

[a-zA-Z_][a-zA-Z0-9_]* { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    yylval.token_info.column = column;
    column += yyleng;
    return IDENTIFIER; 
}

\"[^\"]*\" { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    yylval.token_info.column = column;
    column += yyleng;
    return STRING; 
}

[1-9][0-9]*-[0-9]+ { 
    char *duplicate = strdup(yytext);
    std::string range(duplicate);
    free(duplicate);

    size_t dashPos = range.find('-');

    std::string startDigits = range.substr(0,dashPos);
    std::string endDigits = range.substr(dashPos + 1);

    yylval.range.start = std::stoi(startDigits);
    yylval.range.end = std::stoi(endDigits);

    column += yyleng;
    return RANGE; 
}

-?[0-9]+ { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    yylval.token_info.column = column;
    column += yyleng;
    return INTEGER_LITERAL; 
}

-?[0-9]*(\.[0-9]+)? { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    yylval.token_info.column = column;
    column += yyleng;
    return FLOAT_LITERAL;
}

([0-9]+h)?([0-9]+m)?([0-9]+s)? { 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    yylval.token_info.column = column;
    column += yyleng;
    return TIME_LITERAL; 
}

"{" { 
    yylval.token_info.str = nullptr; 
    yylval.token_info.line = line_number; 
    yylval.token_info.column = column;
    column += yyleng;
    return '{'; 
}

"}" { 
    yylval.token_info.str = nullptr; 
    yylval.token_info.line = line_number; 
    yylval.token_info.column = column;
    column += yyleng;
    return '}'; 
}

[ \t]+ { 
    column += yyleng;  // Update column for whitespace
    /* ignore whitespace */ 
}

\n { 
    line_number++; 
    column = 1;  // Reset column at the start of a new line
}

. { 
    std::cerr << "Unknown character: " << yytext << " at line " << line_number << ", column " << column << std::endl; 
    yylval.token_info.str = strdup(yytext); 
    yylval.token_info.line = line_number; 
    yylval.token_info.column = column;
    column += yyleng;
    return yytext[0]; 
}

"//".* { 
    // Ignore line comment
}

"/*"([^*]|[\r\n]|"*"[^/])*"*/" { 
    // Count newlines inside block comments and update column
    for (char *c = yytext; *c; ++c) {
        if (*c == '\n') {
            line_number++;
            column = 1;  // Reset column on new line within block comment
        } else {
            column++;  // Increment column for other characters
        }
    } 
}

%%

// Function to handle errors (if needed)
//int yywrap() {
//   return 1;
//}