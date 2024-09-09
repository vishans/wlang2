%error-verbose
%locations

%{
#include <iostream>
#include <vector>
#include <map>
#include <string>
#include "ast.h"
#include "parser.tab.hpp"
#include "globals.h"
#include "error.h"
#include <cstdlib>
#include "helper.h"
#include "time.h"
#include "timeError.h"

// Declare external lexer function and necessary variables
extern int yylex();
extern int line_number;
void yyerror(const char *s);

Workout *parsedWorkout = nullptr; // To store the final parsed workout

std::map<std::string, std::string> aliasToNameMap;
std::map<std::string, std::string> nameToTypeMap = *new std::map<std::string, std::string>();
std::map<std::string, std::string> nameToDefaultMap;

void initializeMaps() {
    nameToTypeMap.insert({"REST", "time"});
}

extern int yylineno;
extern char *yytext;


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
    std::map<std::string, std::pair<std::string, std::string> > *customFields;
    std::string *type;  // Type for field_type
    std::pair<std::string, std::string> *value; // Type for field_value + type
    std::map<std::string, std::pair<std::string, std::string> > *fieldValuePair; // Type for field value pair with type
                                                        // field (string) -> value, type (both strings)
}

// Token declarations
%token <str> STRING
%token <str> IDENTIFIER
%token <str> INTEGER_LITERAL
%token <str> FLOAT_LITERAL
%token <str> BOOLEAN_LITERAL
%token <str> TIME_LITERAL
%token WORKOUT EXERCISE SETS REPS SET REP REST FIELD DEFAULT TYPE AS
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
        aliasToNameMap[$8] = $2;
        nameToTypeMap[$2] = *$4;
        if(*$4 != $6->second){
            std::string message = "The field '" + std::string($2) + "' was given the wrong type." +
            "\n" + 
            " Expected " + *$4 + " but got " + $6->first + " (" + $6->second + ").";

            int correctLineNo = getActualLineNumber(line_number, $6->first);
            printErrorMessage(correctLineNo, "Type Mismatch", message);
            exit(EXIT_FAILURE);

        }
        nameToDefaultMap[$2] = $6->first;
    }
    | FIELD IDENTIFIER TYPE field_type DEFAULT field_value { 
        nameToTypeMap[$2] = *$4;

        if(*$4 != $6->second){
            std::string message = "The field '" + std::string($2) + "' was given the wrong type." +
            "\n" + 
            " Expected " + *$4 + " but got " + $6->first + " (" + $6->second + ").";

            int correctLineNo = getActualLineNumber(line_number, $6->first);
            printErrorMessage(correctLineNo, "Type Mismatch", message);
            exit(EXIT_FAILURE);

        }

        nameToDefaultMap[$2] = $6->first;
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
    STRING { $$ = new std::pair<std::string, std::string>(*new std::string($1), "string"); }
    | INTEGER_LITERAL { $$ = new std::pair<std::string, std::string>(*new std::string($1), "integer"); }
    | FLOAT_LITERAL { $$ = new std::pair<std::string, std::string>(*new std::string($1), "float"); }
    | BOOLEAN_LITERAL{ $$ = new std::pair<std::string, std::string>(*new std::string($1), "boolean"); }
    | TIME_LITERAL { 

     Time time;

     try {
            time = *new Time(*new std::string($1));
     }
     catch (const InvalidHour& e){
        int correctLineNo = getActualLineNumber(line_number, std::string($1));
        printErrorMessage(correctLineNo, "Invalid Hour", e.what());
        exit(EXIT_FAILURE);

     }
     catch (const InvalidMinute& e){
        int correctLineNo = getActualLineNumber(line_number, std::string($1));
        printErrorMessage(correctLineNo, "Invalid Minute", e.what());
        exit(EXIT_FAILURE);

     }
     catch (const InvalidSecond& e){
        int correctLineNo = getActualLineNumber(line_number, std::string($1));
        printErrorMessage(correctLineNo, "Invalid Second", e.what());
        exit(EXIT_FAILURE);

     }

        std::string timeString = std::to_string(time.convertIntoSeconds());
        $$ = new std::pair<std::string, std::string>(timeString, "time"); 
        }
    ;

workout:
    WORKOUT '{' exercise_list '}' { $$ = new Workout($3); }
    ;

exercise_list:
    exercise_list exercise { $$ = $1; $1->addExercise($2); }
    | exercise { $$ = new ExerciseList(); $$->addExercise($1); }
    ;

exercise:
    EXERCISE STRING SETS INTEGER_LITERAL REPS INTEGER_LITERAL custom_fields '{' set_details '}' { 
        $$ = new Exercise(
            std::string($2),                // Convert name to std::string
            std::stoi($4),                  // Convert sets to int
            std::stoi($6),                  // Convert reps to int
            *$9,                             // setDetails
            *$7,                             // fields
            "sets" + *new std::string($4)

        ); 
    }
    |
    EXERCISE STRING SETS INTEGER_LITERAL REPS INTEGER_LITERAL '{' set_details '}' { 
        $$ = new Exercise(
            std::string($2),                // Convert name to std::string
            std::stoi($4),                  // Convert sets to int
            std::stoi($6),                  // Convert reps to int
            *$8,                             // setDetails
            *new std::map<std::string, std::pair<std::string, std::string> >(),                             // fields,
            "sets" + *new std::string($4)

        ); 
    }
    | EXERCISE STRING SETS INTEGER_LITERAL REPS INTEGER_LITERAL custom_fields { 
        $$ = new Exercise(
            std::string($2),                // Convert name to std::string
            std::stoi($4),                  // Convert sets to int
            std::stoi($6),               // Convert reps to int
            *new std::vector<SetDetail*>(),
            *$7,                         // fields
            "sets"+ *new std::string($4)
        ); 
    }
    | EXERCISE STRING SETS INTEGER_LITERAL REPS INTEGER_LITERAL { 
        $$ = new Exercise(
            std::string($2),                // Convert name to std::string
            std::stoi($4),                  // Convert sets to int
            std::stoi($6),               // Convert reps to int
            *new std::vector<SetDetail*>(),
            *new std::map<std::string, std::pair<std::string, std::string> >(),                 // fields
            "sets"+ *new std::string($4)
        ); 
    }
    | REST TIME_LITERAL { 
        Time time;
        
        try{
            time = *new Time(*new std::string($2));
        }
        catch (const InvalidHour& e){
            int correctLineNo = getActualLineNumber(line_number, "rest"+std::string($2));
            printErrorMessage(correctLineNo, "Invalid Hour", e.what());
            exit(EXIT_FAILURE);

        }
        catch (const InvalidMinute& e){
            int correctLineNo = getActualLineNumber(line_number, std::string($2));
            printErrorMessage(correctLineNo, "Invalid Minute", e.what());
            exit(EXIT_FAILURE);

        }
        catch (const InvalidSecond& e){
            int correctLineNo = getActualLineNumber(line_number, std::string($2));
            printErrorMessage(correctLineNo, "Invalid Second", e.what());
            exit(EXIT_FAILURE);

        }


        std::string timeString = std::to_string(time.convertIntoSeconds());

        std::map<std::string, std::pair<std::string, std::string> > fields;
        fields.insert({"REST", std::make_pair(timeString, "time")});

        $$ = new Exercise("REST", -1, -1,
                                *new std::vector<SetDetail*>(),
                                fields,
                                "REST"
                                ); 
                                
                                }
    ;

set_details:
    set_details set_detail { $$ = $1; $1->push_back($2); }
    | set_detail { $$ = new std::vector<SetDetail*>(); $$->push_back($1); }
    ;

set_detail:
    SET INTEGER_LITERAL '{' rep_details '}' { $$ = new SetDetail(std::stoi($2), *$4); }
    | SET INTEGER_LITERAL { $$ = new SetDetail(std::stoi($2), *new std::vector<RepDetail*>()) }
    | SET INTEGER_LITERAL '{' '}' { $$ = new SetDetail(std::stoi($2), *new std::vector<RepDetail*>()) }
    | REST TIME_LITERAL { 
        std::vector<RepDetail*> tempRD = *new std::vector<RepDetail*>();
        std::map<std::string, std::pair<std::string, std::string> > fields = *new std::map<std::string, 
        std::pair<std::string, std::string> >();

        Time time;
        
        try{
            time = *new Time(*new std::string($2));
        
        }
        catch (const InvalidHour& e){
            int correctLineNo = getActualLineNumber(line_number, "rest"+std::string($2));
            printErrorMessage(correctLineNo, "Invalid Hour", e.what());
            exit(EXIT_FAILURE);

        }
        catch (const InvalidMinute& e){
            int correctLineNo = getActualLineNumber(line_number, "rest"+std::string($2));
            printErrorMessage(correctLineNo, "Invalid Minute", e.what());
            exit(EXIT_FAILURE);

        }
        catch (const InvalidSecond& e){
            int correctLineNo = getActualLineNumber(line_number, "rest"+std::string($2));
            printErrorMessage(correctLineNo, "Invalid Second", e.what());
            exit(EXIT_FAILURE);

        }

        fields.insert({"REST", std::make_pair<std::string, std::string>(std::to_string(time.convertIntoSeconds()), "time")});

        tempRD.push_back(new RepDetail(-1, fields, 
        *new std::map<std::string, std::string>(),
        "rest" + *new std::string($2)));

        $$ = new SetDetail(-1, tempRD) ;
                            }
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
    REP INTEGER_LITERAL {
        $$ = new RepDetail(
            std::stoi($2), // Rep number
            *new std::map<std::string, std::pair<std::string, std::string> >(), // Empty custom fields
            *new std::map<std::string, std::string>(), // Since custom fields are empty no need for alias
            "rep" + std::string($2)
        );
    }
    | REP INTEGER_LITERAL custom_fields {
        std::map<std::string, std::pair<std::string, std::string> > combinedFields;
        combinedFields.insert($3->begin(), $3->end());
        $$ = new RepDetail(
            std::stoi($2), // Rep number
            combinedFields, // Custom fields
           aliasToNameMap,
           "rep" + std::string($2)
        );
    }
    | REST TIME_LITERAL {

        Time time;

        try{
            time = *new Time(*new std::string($2));
        
        }
        catch (const InvalidHour& e){
            int correctLineNo = getActualLineNumber(line_number, "rest"+std::string($2));
            printErrorMessage(correctLineNo, "Invalid Hour", e.what());
            exit(EXIT_FAILURE);

        }
        catch (const InvalidMinute& e){
            int correctLineNo = getActualLineNumber(line_number, "rest"+std::string($2));
            printErrorMessage(correctLineNo, "Invalid Minute", e.what());
            exit(EXIT_FAILURE);

        }
        catch (const InvalidSecond& e){
            int correctLineNo = getActualLineNumber(line_number, "rest"+std::string($2));
            printErrorMessage(correctLineNo, "Invalid Second", e.what());
            exit(EXIT_FAILURE);

        }

        std::string timeString = std::to_string(time.convertIntoSeconds());

        std::map<std::string, std::pair<std::string, std::string> > combinedFields;
        combinedFields.insert({"REST", std::make_pair(timeString, "time")});
        $$ = new RepDetail(
            -1, // Rep number
            combinedFields, // Custom fields
           aliasToNameMap,
           "rep" + std::string($2)
        );
    }
    ;

rep_range:
    REPS INTEGER_LITERAL '-' INTEGER_LITERAL {
        $$ = new std::vector<RepDetail*>();
        for (int i = std::stoi($2); i <= std::stoi($4); ++i) {
            $$->push_back(new RepDetail(
                i, // Rep number in the range
                *new std::map<std::string, std::pair<std::string,std::string> >(), // Empty custom fields
                *new std::map<std::string, std::string>(), // No need for alias
                "reps" + std::string($2) + "-" + std::string($4)
                
            ));
        }
    }
    | REPS INTEGER_LITERAL '-' INTEGER_LITERAL custom_fields {
        $$ = new std::vector<RepDetail*>();
        std::map<std::string, std::pair<std::string, std::string> > combinedFields;
        combinedFields.insert($5->begin(), $5->end());
        for (int i = std::stoi($2); i <= std::stoi($4); ++i) {
            $$->push_back(new RepDetail(
                i, // Rep number in the range
                combinedFields, // Custom fields
                aliasToNameMap,
                "reps" + std::string($2) + "-" + std::string($4)

            ));
        }
    }
    ;

custom_fields:
    custom_fields field_value_pair { $$ = $1; $1->insert($2->begin(), $2->end()); }
    | field_value_pair { $$ = new std::map<std::string, std::pair<std::string, std::string> >(); $$->insert($1->begin(), $1->end()); }
    ;

field_value_pair:
    IDENTIFIER STRING { 
        std::map<std::string, std::pair<std::string, std::string> > *m = new std::map<std::string, std::pair<std::string, std::string> >();
        m->insert(std::make_pair($1, std::make_pair($2,*new std::string("string"))));
        $$ = m;
    }
    | IDENTIFIER INTEGER_LITERAL { 
        std::map<std::string, std::pair<std::string, std::string> > *m = new std::map<std::string, std::pair<std::string, std::string> >();
        
        m->insert(std::make_pair($1, std::make_pair($2,*new std::string("integer"))));

        $$ = m;
    }
    | IDENTIFIER FLOAT_LITERAL { 
        std::map<std::string, std::pair<std::string, std::string> > *m = new std::map<std::string, std::pair<std::string, std::string> >();

        m->insert(std::make_pair($1, std::make_pair($2,*new std::string("float"))));

        $$ = m;
    }
    | IDENTIFIER BOOLEAN_LITERAL { 
        std::map<std::string, std::pair<std::string, std::string> > *m = new std::map<std::string, std::pair<std::string, std::string> >();

        m->insert(std::make_pair($1, std::make_pair($2,*new std::string("boolean"))));

        $$ = m;
    }
    | IDENTIFIER TIME_LITERAL { 
        std::map<std::string, std::pair<std::string, std::string> > *m = new std::map<std::string, std::pair<std::string, std::string> >();

     Time time;

     try {
            time = *new Time(*new std::string($2));
     }
     catch (const InvalidHour& e){
        int correctLineNo = getActualLineNumber(line_number, std::string($1)+std::string($2));
        printErrorMessage(correctLineNo, "Invalid Hour", e.what());
        exit(EXIT_FAILURE);

     }
     catch (const InvalidMinute& e){
        int correctLineNo = getActualLineNumber(line_number, std::string($1)+std::string($2));
        printErrorMessage(correctLineNo, "Invalid Minute", e.what());
        exit(EXIT_FAILURE);

     }
     catch (const InvalidSecond& e){
        int correctLineNo = getActualLineNumber(line_number, std::string($1)+std::string($2));
        printErrorMessage(correctLineNo, "Invalid Second", e.what());
        exit(EXIT_FAILURE);

     }

        std::string timeString = std::to_string(time.convertIntoSeconds());

        m->insert(std::make_pair($1, std::make_pair(timeString,*new std::string("time"))));
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
    std::cerr << "Syntax error at line " << line_number << ": " << s << std::endl;
    std::cerr << "Unexpected token: '" << yytext << "'" << std::endl;
}