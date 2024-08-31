%{
#include <iostream>
#include <vector>
#include <map>
#include <string>
#include "ast.h"
#include "parser.tab.hpp"

// Declare external lexer function and necessary variables
extern int yylex();
extern int line_number;
void yyerror(const char *s);

Workout *parsedWorkout = nullptr; // To store the final parsed workout
%}

%union {
    char *str;
    int num;
    Exercise *exercise;
    Workout *workout;
    ExerciseList *exerciseList;
    SetDetail *setDetail;
    RepDetail *repDetail;
    std::vector<SetDetail*> *setDetails;
    std::vector<RepDetail*> *repDetails;
    std::map<std::string, std::string> *customFields;
    std::string *type;  // Type for field_type
    std::string *value; // Type for field_value
    std::map<std::string, std::string> *fieldValuePair; // Type for field_value_pair
}

// Token declarations
%token <str> STRING
%token <str> IDENTIFIER
%token <str> INTEGER_LITERAL
%token <str> FLOAT_LITERAL
%token <str> BOOLEAN_LITERAL
%token <str> TIME_LITERAL
%token WORKOUT EXERCISE SETS REPS WEIGHT SET REP REST FIELD DEFAULT TYPE AS
%token STRING_TYPE INTEGER_TYPE FLOAT_TYPE TIME_TYPE BOOLEAN_TYPE

%type <exercise> exercise
%type <workout> workout
%type <exerciseList> exercise_list
%type <setDetails> set_details
%type <setDetail> set_detail

%type <repDetails> rep_details
%type <repDetail> rep_detail
%type <repDetails> rep_range


%type <customFields> custom_fields
%type <type> field_type
%type <value> field_value
%type <fieldValuePair> field_value_pair

%%

// Grammar rules
input:
    field_declarations workout { parsedWorkout = $2; }
    | workout { parsedWorkout = $1; }
    ;

field_declarations:
    field_declarations field_def { /* Fields added */ }
    | field_def { /* Fields added */ }
    ;

field_def:
    FIELD IDENTIFIER TYPE field_type DEFAULT field_value AS IDENTIFIER { 
        // Store field definition
    }
    | FIELD IDENTIFIER TYPE field_type DEFAULT field_value { 
        // Store field definition
    }
    ;

field_type:
    STRING_TYPE { $$ = new std::string("string"); }
    | INTEGER_TYPE { $$ = new std::string("integer"); }
    | FLOAT_TYPE { $$ = new std::string("float"); }
    | TIME_TYPE { $$ = new std::string("time"); }
    | BOOLEAN_TYPE { $$ = new std::string("boolean"); }
    ;

field_value:
    STRING { $$ = new std::string($1); }
    | INTEGER_LITERAL { $$ = new std::string($1); }
    | FLOAT_LITERAL { $$ = new std::string($1); }
    | BOOLEAN_LITERAL { $$ = new std::string($1); }
    | TIME_LITERAL { $$ = new std::string($1); }
    ;

workout:
    WORKOUT '{' exercise_list '}' { $$ = new Workout($3); }
    ;

exercise_list:
    exercise_list exercise { $$ = $1; $1->addExercise($2); }
    | exercise { $$ = new ExerciseList(); $$->addExercise($1); }
    ;

exercise:
    EXERCISE STRING SETS INTEGER_LITERAL REPS INTEGER_LITERAL WEIGHT STRING '{' set_details '}' { 
        $$ = new Exercise(
            std::string($2),                // Convert name to std::string
            std::stoi($4),                  // Convert sets to int
            std::stoi($6),                  // Convert reps to int
            std::string($8),                // Convert weight to std::string
            *$10                             // setDetails
        ); 
    }
    | EXERCISE STRING SETS INTEGER_LITERAL REPS INTEGER_LITERAL WEIGHT STRING { 
        $$ = new Exercise(
            std::string($2),                // Convert name to std::string
            std::stoi($4),                  // Convert sets to int
            std::stoi($6),                  // Convert reps to int
            std::string($8)                 // Convert weight to std::string
        ); 
    }
    | REST { $$ = new Exercise("REST", -1, -1, "-1"); }
    ;

set_details:
    set_details set_detail { $$ = $1; $1->push_back($2); }
    | set_detail { $$ = new std::vector<SetDetail*>(); $$->push_back($1); }
    ;

set_detail:
    SET INTEGER_LITERAL '{' rep_details '}' { $$ = new SetDetail(std::stoi($2), *$4); }
    ;

rep_details:
    rep_details rep_detail {
        $1->push_back($2);
        $$ = $1;
    }
    | rep_details rep_range {
        $1->insert($1->end(), $2->begin(), $2->end());
        $$ = $1;
    }
    | rep_detail {
        $$ = new std::vector<RepDetail*>();
        $$->push_back($1);
    }
    | rep_range {
        $$ = $1; // rep_range already returns a vector
    }
    ;

rep_detail:
    REP INTEGER_LITERAL WEIGHT STRING {
        $$ = new RepDetail(
            std::stoi($2), // Rep number
            std::string($4), // Weight
            *new std::map<std::string, std::string>(), // Empty custom fields
            *new std::map<std::string, std::string>(), // Empty types
            *new std::map<std::string, std::string>()  // Empty aliases
        );
    }
    | REP INTEGER_LITERAL WEIGHT STRING custom_fields {
        std::map<std::string, std::string> combinedFields;
        combinedFields.insert($5->begin(), $5->end());
        $$ = new RepDetail(
            std::stoi($2), // Rep number
            std::string($4), // Weight
            combinedFields, // Custom fields
            *new std::map<std::string, std::string>(), // Empty types
            *new std::map<std::string, std::string>()  // Empty aliases
        );
    }
    ;

rep_range:
    REPS INTEGER_LITERAL '-' INTEGER_LITERAL WEIGHT STRING {
        $$ = new std::vector<RepDetail*>();
        for (int i = std::stoi($2); i <= std::stoi($4); ++i) {
            $$->push_back(new RepDetail(
                i, // Rep number in the range
                std::string($6), // Weight
                *new std::map<std::string, std::string>(), // Empty custom fields
                *new std::map<std::string, std::string>(), // Empty types
                *new std::map<std::string, std::string>()  // Empty aliases
            ));
        }
    }
    | REPS INTEGER_LITERAL '-' INTEGER_LITERAL WEIGHT STRING custom_fields {
        $$ = new std::vector<RepDetail*>();
        std::map<std::string, std::string> combinedFields;
        combinedFields.insert($7->begin(), $7->end());
        for (int i = std::stoi($2); i <= std::stoi($4); ++i) {
            $$->push_back(new RepDetail(
                i, // Rep number in the range
                std::string($6), // Weight
                combinedFields, // Custom fields
                *new std::map<std::string, std::string>(), // Empty types
                *new std::map<std::string, std::string>()  // Empty aliases
            ));
        }
    }
    ;

custom_fields:
    custom_fields field_value_pair { $$ = $1; $1->insert($2->begin(), $2->end()); }
    | field_value_pair { $$ = new std::map<std::string, std::string>(); $$->insert($1->begin(), $1->end()); }
    ;

field_value_pair:
    IDENTIFIER STRING { 
        std::map<std::string, std::string> *m = new std::map<std::string, std::string>();
        m->insert(std::make_pair($1, $2));
        $$ = m;
    }
    | IDENTIFIER INTEGER_LITERAL { 
        std::map<std::string, std::string> *m = new std::map<std::string, std::string>();
        m->insert(std::make_pair($1, $2));
        $$ = m;
    }
    | IDENTIFIER FLOAT_LITERAL { 
        std::map<std::string, std::string> *m = new std::map<std::string, std::string>();
        m->insert(std::make_pair($1, $2));
        $$ = m;
    }
    | IDENTIFIER BOOLEAN_LITERAL { 
        std::map<std::string, std::string> *m = new std::map<std::string, std::string>();
        m->insert(std::make_pair($1, $2));
        $$ = m;
    }
    | IDENTIFIER TIME_LITERAL { 
        std::map<std::string, std::string> *m = new std::map<std::string, std::string>();
        m->insert(std::make_pair($1, $2));
        $$ = m;
    }
    ;

%%

/* void yyerror(const char *s) {
    std::cerr << "Error: " << s << " at line " << line_number << std::endl;
}
*/

void yyerror(const char *s) {
    extern int yylineno; // Defined and maintained by Bison to track line numbers
    extern char *yytext; // The text of the current token
    std::cerr << "Syntax error at line " << yylineno << ": " << s << std::endl;
    std::cerr << "Unexpected token: '" << yytext << "'" << std::endl;
}