%define parse.error verbose
%locations 

%{
#include <iostream>
#include <sstream>
#include <iomanip>
#include <vector>
#include <map>
#include <string>
#include <cstring>
#include <cmath>
#include "../exprtk/exprtk.hpp"
#include "../ast/ast.h"
#include "parser.tab.hpp"
#include "../globals/globals.h"
#include "../error/error.h"
#include <cstdlib>
#include "../helper/helper.h"
#include "../time/time.h"
#include "../time/timeError.h"
#include "../errorMessage/errorMessage.h"

// Declare external lexer function and necessary variables
extern int yylex();
extern int line_number;
void yyerror(const char *s);

Workout *parsedWorkout = nullptr; // To store the final parsed workout

std::map<std::string, std::string> aliasToNameMap;
std::map<std::string, std::string> nameToTypeMap = *new std::map<std::string, std::string>();
std::map<std::string, std::string> nameToDefaultMap;

std::map<std::string, std::string> constNameToValue;


void initializeMaps() {
    nameToTypeMap.insert({"REST", "time"});
}

extern int yylineno;
extern char *yytext;

const std::string operators = "+-*/";

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
    Field *field; // 
    std::map<std::string, std::pair<std::string, std::string> > *fieldValuePair; // Type for field value pair with type
                                                        // field (string) -> value, type (both strings)

    // Structure to include string and line information
    struct {
        char *str; // Token value if any, or nullptr for keywords/symbols
        int line;  // Line number where the token was found
        int column;
    } token_info;

    struct {
        int start;
        int end;
    } range;

}

// Token declarations
%token <token_info> STRING
%token <token_info> IDENTIFIER
%token <token_info> INTEGER_LITERAL
%token <token_info> FLOAT_LITERAL
%token <token_info> BOOLEAN_LITERAL
%token <token_info> TIME_LITERAL
%token <token_info> WORKOUT EXERCISE SETS REPS SET REP REST FIELD DEFAULT TYPE AS FAIL CONST
%token <token_info> STRING_TYPE INTEGER_TYPE FLOAT_TYPE TIME_TYPE BOOLEAN_TYPE 
%token <token_info> EXPRESSION
%token <range> RANGE

%type <exercise> exercise
%type <workout> workout
%type <exerciseList> exercise_list
%type <setDetails> set_details
%type <setDetails> set_details_without_fail
%type <setDetail> set_detail

%type <repDetails> rep_details_without_fail
%type <repDetails> rep_details
%type <repDetail> rep_detail
%type <repDetails> rep_range


%type <customFields> custom_fields
%type <type> field_type
%type <field> field_value
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

        if(*new std::string($2.str) == "REST"){
            // REST is a reserved word
            int correctLineNo = $1.line;
            std::string message = "'REST' is a reserved word, and therefore cannot be used as a field name.";
            printErrorMessage(correctLineNo, "Name Conflict", message, $2.column, strlen($2.str));
            exit(EXIT_FAILURE);

        }


        if(nameToTypeMap.find($2.str) != nameToTypeMap.end() || constNameToValue.find($2.str) != constNameToValue.end()){
            // Identifier is already being used

             std::string message = "The name '" + std::string($2.str) + "' is already being used.";

            int correctLineNo = $1.line;
            printErrorMessage(correctLineNo, "Name Conflict", message, $2.column, strlen($2.str));
            exit(EXIT_FAILURE);

        }

        if(aliasToNameMap.find($8.str) != aliasToNameMap.end()){
            // Alias is already being used

             std::string message = "The alias '" + std::string($8.str) + "' is already being used for field '"+  aliasToNameMap[$8.str]  +"'. It cannot be used again for '" + $2.str +"'.";

                int correctLineNo = $1.line;
                printErrorMessage(correctLineNo, "Alias Conflict", message, $8.column, strlen($8.str));
                exit(EXIT_FAILURE);

        }  



        aliasToNameMap[$8.str] = $2.str;
        nameToTypeMap[$2.str] = *$4;

        if(*$4 != $6->type){

            bool flag =  

                (!(*$4 == "float" && $6->type == "integer")) ||
                
                (!(*$4 == "float" && $6->type == "expression")) ||
                
                (!(*$4 == "float" && $6->type == "expression"));
            
            if(!flag) {

                std::string message = "The field '" + std::string($2.str) + "' was given the wrong type." +
                "\n" + 
                " Expected " + *$4 + " but got " + $6->value + " (" + $6->type + ").";

                int correctLineNo = $1.line;
                printErrorMessage(correctLineNo, "Type Mismatch", message, $6->column, $6->value.length());
                exit(EXIT_FAILURE);
        
            }
        }


        std::string value = $6->value;

        // To evaluate expression if it is an expression (if possible) 
        // then save that value in the hashmap
        if($6->type == "expression"){
            // Abort if it needs a previous value e.g +20
            if(operators.find(($6->value)[0]) != std::string::npos){
                printErrorMessage($6->line, "Inappropriate Expression", "This expression cannot be used during initialization.", $6->column,($6->value).length());
                
                exit(EXIT_FAILURE);
            }
            
            typedef exprtk::expression<double> expression_t;
            typedef exprtk::parser<double> parser_t;

            std::string expression_string = $6->value;
            expression_t expression;
            parser_t parser;

            if (parser.compile(expression_string, expression)) {
                value = std::to_string(expression.value()); 


                if(*$4 == "float"){
                    float num = std::stof(value);

                    std::ostringstream oss;
                    oss << std::fixed << std::setprecision(3) << num;

                    value = oss.str();

                }

                if(*$4 == "integer"){
                    int num = std::stoi(value);

                    std::ostringstream oss;
                    oss << num;

                    value = oss.str();

                }

                    
            }
            else {
                
                std::string errorMsg = parser.error();
                size_t pos = errorMsg.find('-');
                printErrorMessage($6->line, "Invalid Expression",errorMsg.substr(pos+2), $6->column,($6->value).length());
                exit(EXIT_FAILURE);
            }
        }

        nameToDefaultMap[$2.str] = value;
    }
    | FIELD IDENTIFIER TYPE field_type DEFAULT field_value { 

         if(*new std::string($2.str) == "REST"){
            // REST is a reserved word
            int correctLineNo = $1.line;
            std::string message = "'REST' is a reserved word, and therefore cannot be used as a field name.";
            printErrorMessage(correctLineNo, "Name Conflict", message, $2.column, strlen($2.str));
            exit(EXIT_FAILURE);

        }


        if(nameToTypeMap.find($2.str) != nameToTypeMap.end() || constNameToValue.find($2.str) != constNameToValue.end()){
            // Identifier is already being used

             std::string message = "The name '" + std::string($2.str) + "' is already being used.";

                int correctLineNo = $1.line;
                printErrorMessage(correctLineNo, "Name Conflict", message, $2.column, strlen($2.str));
                exit(EXIT_FAILURE);

        }



        nameToTypeMap[$2.str] = *$4;

        if(*$4 != $6->type){

            bool flag =  

                (!(*$4 == "float" && $6->type == "integer")) ||
                
                
                (!(*$4 == "float" && $6->type == "expression")) ||
                
                (!(*$4 == "float" && $6->type == "expression"));
            
            if(!flag) {

                std::string message = "The field '" + std::string($2.str) + "' was given the wrong type." +
                "\n" + 
                " Expected " + *$4 + " but got " + $6->value + " (" + $6->type + ").";

                int correctLineNo = $1.line;
                printErrorMessage(correctLineNo, "Type Mismatch", message, $6->column, $6->value.length());
                exit(EXIT_FAILURE);
        
            }
        }
        
        std::string value = $6->value;

        // To evaluate expression if it is an expression (if possible) 
        // then save that value in the hashmap
        if($6->type == "expression"){
            // Abort if it needs a previous value e.g +20
            if(operators.find(($6->value)[0]) != std::string::npos){
                printErrorMessage($6->line, "Inappropriate Expression", "This expression cannot be used during initialization.", $6->column,($6->value).length());
                
                exit(EXIT_FAILURE);
            }

            typedef exprtk::expression<double> expression_t;
            typedef exprtk::parser<double> parser_t;

            std::string expression_string = $6->value;
            expression_t expression;
            parser_t parser;

            if (parser.compile(expression_string, expression)) {
                double expressionValue = expression.value(); 


                if(*$4 == "float"){
                    float num = static_cast<float>(expressionValue);

                    std::ostringstream oss;
                    oss << std::fixed << std::setprecision(3) << num;

                    value = oss.str();

                }

                if(*$4 == "integer"){
                    int num = static_cast<int>(expressionValue);

                    std::ostringstream oss;
                    oss << num;

                    value = oss.str();

                }

                    
            }
            else {
                
                std::string errorMsg = parser.error();
                size_t pos = errorMsg.find('-');
                printErrorMessage($6->line, "Invalid Expression",errorMsg.substr(pos+2), $6->column,($6->value).length());
                exit(EXIT_FAILURE);
            }
        }

        nameToDefaultMap[$2.str] = value;
    }
    | CONST IDENTIFIER field_value {
        if(*new std::string($2.str) == "REST"){
            // REST is a reserved word
            int correctLineNo = $1.line;
            std::string message = "'REST' is a reserved word, and therefore cannot be used as a constant name.";
            printErrorMessage(correctLineNo, "Name Conflict", message, $2.column, strlen($2.str));
            exit(EXIT_FAILURE);

        }


        if(constNameToValue.find($2.str) != constNameToValue.end() || nameToTypeMap.find($2.str) != nameToTypeMap.end() ){
            // Identifier is already being used

             std::string message = "The name '" + std::string($2.str) + "' is already being used.";

                int correctLineNo = $1.line;
                printErrorMessage(correctLineNo, "Name Conflict", message, $2.column, strlen($2.str));
                exit(EXIT_FAILURE);

        }

        
        std::string value = $3->value;
        std::string type = $3->type;

        if($3->type == "float"){
            float num = std::stof($3->value);

            std::ostringstream oss;
            oss << std::fixed << std::setprecision(3) << num;

            value = oss.str();

        }

        if($3->type == "integer"){
            int num = std::stoi($3->value);

            std::ostringstream oss;
            oss << num;

            value = oss.str();

        }



        // To evaluate expression if it is an expression (if possible) 
        // then save that value in the hashmap
        if($3->type == "expression"){
            // Abort if it needs a previous value e.g +20
            if(operators.find(($3->value)[0]) != std::string::npos){
                printErrorMessage($3->line, "Inappropriate Expression", "This expression cannot be used during initialization.", $3->column,($3->value).length());
                
                exit(EXIT_FAILURE);
            }

            typedef exprtk::expression<double> expression_t;
            typedef exprtk::parser<double> parser_t;

            std::string expression_string = $3->value;
            expression_t expression;
            parser_t parser;

            if (parser.compile(expression_string, expression)) {
                double expressionValue = expression.value();

                double fracPart = expressionValue - std::floor(expressionValue);

                if(fracPart == 0.0){
                    type = "integer";
                }
                else{
                    type = "float";
                }
            

                if(type == "float"){
                    float num = static_cast<float>(expressionValue);

                    std::ostringstream oss;
                    oss << std::fixed << std::setprecision(3) << num;

                    value = oss.str();

                }

                if(type == "integer"){
                    int num = static_cast<int>(expressionValue);

                    std::ostringstream oss;
                    oss << num;

                    value = oss.str();

                }

                    
            }
            else {
                
                std::string errorMsg = parser.error();
                size_t pos = errorMsg.find('-');
                printErrorMessage($3->line, "Invalid Expression",errorMsg.substr(pos+2), $3->column,($3->value).length());
                exit(EXIT_FAILURE);
            }
        }


        constNameToValue[$2.str] = value;
        nameToTypeMap[$2.str] = type;

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
    STRING { $$ = new Field($1.str, "string", $1.line, $1.column); }
    | INTEGER_LITERAL { $$ = new Field($1.str, "integer", $1.line, $1.column); }
    | FLOAT_LITERAL { $$ = new Field($1.str, "float", $1.line, $1.column); }
    | BOOLEAN_LITERAL { $$ = new Field($1.str, "boolean", $1.line, $1.column); }
    | EXPRESSION { $$ = new Field($1.str, "expression", $1.line, $1.column); }
    | TIME_LITERAL { 
        Time time;
        try {
            time = *new Time(*new std::string($1.str));
        } catch (const InvalidHour& e) {
            int correctLineNo = $1.line;
            printErrorMessage(correctLineNo, "Invalid Hour", e.what(), $1.column, strlen($1.str));
            exit(EXIT_FAILURE);
        } catch (const InvalidMinute& e) {
            int correctLineNo = $1.line;
            printErrorMessage(correctLineNo, "Invalid Minute", e.what(), $1.column, strlen($1.str));
            exit(EXIT_FAILURE);
        } catch (const InvalidSecond& e) {
            int correctLineNo = $1.line;
            printErrorMessage(correctLineNo, "Invalid Second", e.what(), $1.column, strlen($1.str));
            exit(EXIT_FAILURE);
        }

        std::string timeString = std::to_string(time.convertIntoSeconds());
        $$ = new Field(timeString, "time", $1.line, $1.column);
    }
    ;

workout:
    WORKOUT '{' exercise_list '}' { $$ = new Workout($3); }
    ;

exercise_list:
    exercise_list exercise { 
        
        $$ = $1; 
        if($2->sets != -2)
            $1->addExercise($2); 
        
    }
    | exercise { 
        $$ = new ExerciseList(); 
        if($1->sets != -2)
            $$->addExercise($1);

    }
    ;

exercise:
    EXERCISE STRING SETS INTEGER_LITERAL REPS INTEGER_LITERAL custom_fields '{' set_details '}' { 
        $$ = new Exercise(
            std::string($2.str),                // Convert name to std::string
            std::stoi($4.str),                  // Convert sets to int
            std::stoi($6.str),                  // Convert reps to int
            *$9,                             // setDetails
            *$7,                             // fields
            "sets" + *new std::string($4.str),
            $1.line

        ); 
    }
    |
    EXERCISE STRING SETS INTEGER_LITERAL REPS INTEGER_LITERAL '{' set_details '}' { 
        $$ = new Exercise(
            std::string($2.str),                // Convert name to std::string
            std::stoi($4.str),                  // Convert sets to int
            std::stoi($6.str),                  // Convert reps to int
            *$8,                             // setDetails
            *new std::map<std::string, std::pair<std::string, std::string> >(),                             // fields,
            "sets" + *new std::string($4.str),
            $1.line

        ); 
    }
    | EXERCISE STRING SETS INTEGER_LITERAL REPS INTEGER_LITERAL custom_fields { 
        $$ = new Exercise(
            std::string($2.str),                // Convert name to std::string
            std::stoi($4.str),                  // Convert sets to int
            std::stoi($6.str),               // Convert reps to int
            *new std::vector<SetDetail*>(),
            *$7,                         // fields
            "sets"+ *new std::string($4.str),
            $1.line
        ); 
    }
    | EXERCISE STRING SETS INTEGER_LITERAL REPS INTEGER_LITERAL { 
        $$ = new Exercise(
            std::string($2.str),                // Convert name to std::string
            std::stoi($4.str),                  // Convert sets to int
            std::stoi($6.str),               // Convert reps to int
            *new std::vector<SetDetail*>(),
            *new std::map<std::string, std::pair<std::string, std::string> >(),                 // fields
            "sets"+ *new std::string($4.str),
            $1.line
        ); 
    }
     | EXERCISE STRING SETS INTEGER_LITERAL REPS INTEGER_LITERAL custom_fields '{' '}' { 
        $$ = new Exercise(
            std::string($2.str),                // Convert name to std::string
            std::stoi($4.str),                  // Convert sets to int
            std::stoi($6.str),               // Convert reps to int
            *new std::vector<SetDetail*>(),
            *$7,                         // fields
            "sets"+ *new std::string($4.str),
            $1.line
        ); 
    }
    | EXERCISE STRING SETS INTEGER_LITERAL REPS INTEGER_LITERAL '{' '}' { 
        $$ = new Exercise(
            std::string($2.str),                // Convert name to std::string
            std::stoi($4.str),                  // Convert sets to int
            std::stoi($6.str),               // Convert reps to int
            *new std::vector<SetDetail*>(),
            *new std::map<std::string, std::pair<std::string, std::string> >(),                 // fields
            "sets"+ *new std::string($4.str),
            $1.line
        ); 
    }
    | EXERCISE STRING SETS INTEGER_LITERAL REPS INTEGER_LITERAL custom_fields '{' FAIL '}' { 
        $$ = new Exercise(
            "FAIL",                // Convert name to std::string
            -2,                  // Convert sets to int
            -2,               // Convert reps to int
            *new std::vector<SetDetail*>(),
            *new std::map<std::string, std::pair<std::string, std::string> >(),                 // fields
            "sets"+ *new std::string($4.str),
            $1.line
        ); 
    }
    | EXERCISE STRING SETS INTEGER_LITERAL REPS INTEGER_LITERAL '{' FAIL '}' { 
         $$ = new Exercise(
            "FAIL",                // Convert name to std::string
            -2,                  // Convert sets to int
            -2,               // Convert reps to int
            *new std::vector<SetDetail*>(),
            *new std::map<std::string, std::pair<std::string, std::string> >(),                 // fields
            "sets"+ *new std::string($4.str),
            $1.line
        ); 
       
    }
    | REST TIME_LITERAL { 
        Time time;
        
        try{
            time = *new Time(*new std::string($2.str));
        }
        catch (const InvalidHour& e){
            int correctLineNo = $2.line;
            printErrorMessage(correctLineNo, "Invalid Hour", e.what(), $2.column, strlen($2.str));
            exit(EXIT_FAILURE);

        }
        catch (const InvalidMinute& e){
            int correctLineNo = $2.line;
            printErrorMessage(correctLineNo, "Invalid Minute", e.what(), $2.column, strlen($2.str));
            exit(EXIT_FAILURE);

        }
        catch (const InvalidSecond& e){
            int correctLineNo = $2.line;
            printErrorMessage(correctLineNo, "Invalid Second", e.what(), $2.column, strlen($2.str));
            exit(EXIT_FAILURE);

        }


        std::string timeString = std::to_string(time.convertIntoSeconds());

        std::map<std::string, std::pair<std::string, std::string> > fields;
        fields.insert({"REST", std::make_pair(timeString, "time")});

        $$ = new Exercise("REST", -1, -1,
                                *new std::vector<SetDetail*>(),
                                fields,
                                "REST", 
                                $1.line
                                ); 
                                
                                };
    

set_details:
    set_details_without_fail { $$ = $1; };
    
    | set_details_without_fail FAIL {

        std::vector<RepDetail*> reps = *new std::vector<RepDetail*>();
        RepDetail* failRep = new RepDetail(-2, *new std::map<std::string, std::pair<std::string, std::string> >(), "-2", -2);

        reps.push_back(failRep);
        
        SetDetail* failSet = new SetDetail(-2, reps, *new std::string("fail"), $2.line) ;
        //failSet->repDetails.push_back(failRep);
                
        $1->push_back(failSet); 
        
        $$ = $1;
        
        };

set_details_without_fail:
    set_details set_detail { $$ = $1; $1->push_back($2); }
    | set_detail { $$ = new std::vector<SetDetail*>(); $$->push_back($1); }
    ;

set_detail:
    SET INTEGER_LITERAL '{' rep_details '}' { $$ = new SetDetail(std::stoi($2.str), *$4, "set"+ *new std::string($2.str), $1.line); }
    |

    // custom fields
    SET INTEGER_LITERAL custom_fields '{' rep_details '}' { 
        std::map<std::string, std::pair<std::string, std::string> > combinedFields;
        combinedFields.insert($3->begin(), $3->end());
    
        
        $$ = new SetDetail(std::stoi($2.str), *$5, "set"+ *new std::string($2.str), $1.line, combinedFields); }


    | SET INTEGER_LITERAL { $$ = new SetDetail(std::stoi($2.str), *new std::vector<RepDetail*>(),  "set"+ *new std::string($2.str), $1.line); }

    // custom fields
    | SET INTEGER_LITERAL custom_fields { 

        std::map<std::string, std::pair<std::string, std::string> > combinedFields;
        combinedFields.insert($3->begin(), $3->end());
    

        $$ = new SetDetail(std::stoi($2.str), *new std::vector<RepDetail*>(),  "set"+ *new std::string($2.str), $1.line, combinedFields);
        
    }

    
    | SET INTEGER_LITERAL '{' '}' { $$ = new SetDetail(std::stoi($2.str), *new std::vector<RepDetail*>(), "set"+ *new std::string($2.str), $1.line); }

    // custom_fields
    | SET INTEGER_LITERAL custom_fields '{' '}' { 

        std::map<std::string, std::pair<std::string, std::string> > combinedFields;
        combinedFields.insert($3->begin(), $3->end());

        $$ = new SetDetail(std::stoi($2.str), *new std::vector<RepDetail*>(), "set"+ *new std::string($2.str), $1.line, combinedFields); 
        
        }


    | REST TIME_LITERAL { 
        std::vector<RepDetail*> tempRD = *new std::vector<RepDetail*>();
        std::map<std::string, std::pair<std::string, std::string> > fields = *new std::map<std::string, 
        std::pair<std::string, std::string> >();

        Time time;
        
        try{
            time = *new Time(*new std::string($2.str));
        
        }
        catch (const InvalidHour& e){
            int correctLineNo = $2.line;
            printErrorMessage(correctLineNo, "Invalid Hour", e.what(), $2.column, strlen($2.str));
            exit(EXIT_FAILURE);

        }
        catch (const InvalidMinute& e){
            int correctLineNo = $2.line;
            printErrorMessage(correctLineNo, "Invalid Minute", e.what(), $2.column, strlen($2.str));
            exit(EXIT_FAILURE);

        }
        catch (const InvalidSecond& e){
            int correctLineNo = $2.line;
            printErrorMessage(correctLineNo, "Invalid Second", e.what(), $2.column, strlen($2.str));
            exit(EXIT_FAILURE);

        }

        fields.insert({"REST", std::make_pair<std::string, std::string>(std::to_string(time.convertIntoSeconds()), "time")});


        // Directly adding the rest time attribute to the customFields of SetDetail
        $$ = new SetDetail(-1, tempRD, "rest" + *new std::string($2.str), $1.line, fields) ;
                            }
    ;

rep_details:
    rep_details_without_fail {
        $$ = $1;
    }
    | rep_details_without_fail FAIL{
        std::map<std::string, std::pair<std::string, std::string> > combinedFields;
      
        $$->push_back(new RepDetail(
            -2, // Rep number
            combinedFields, // Custom fields
           "fail",
           $2.line
        ));
    }

rep_details_without_fail:
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
            std::stoi($2.str), // Rep number
            *new std::map<std::string, std::pair<std::string, std::string> >(), // Empty custom fields
            "rep" + std::string($2.str),
            $1.line
        );
    }
    | REP INTEGER_LITERAL custom_fields {
        std::map<std::string, std::pair<std::string, std::string> > combinedFields;
        combinedFields.insert($3->begin(), $3->end());
        $$ = new RepDetail(
            std::stoi($2.str), // Rep number
            combinedFields, // Custom fields
           "rep" + std::string($2.str),
           $1.line
        );
    }
    | REST TIME_LITERAL {

        Time time;

        try{
            time = *new Time(*new std::string($2.str));
        
        }
        catch (const InvalidHour& e){
            int lineNo = $2.line;
            printErrorMessage( lineNo, "Invalid Hour", e.what(), $2.column, strlen($2.str));
            exit(EXIT_FAILURE);

        }
        catch (const InvalidMinute& e){
            int correctLineNo = $2.line;
            printErrorMessage(correctLineNo, "Invalid Minute", e.what(), $2.column, strlen($2.str));
            exit(EXIT_FAILURE);

        }
        catch (const InvalidSecond& e){
            int correctLineNo = $2.line;
            printErrorMessage(correctLineNo, "Invalid Second", e.what(), $2.column, strlen($2.str));
            exit(EXIT_FAILURE);

        }

        std::string timeString = std::to_string(time.convertIntoSeconds());

        std::map<std::string, std::pair<std::string, std::string> > combinedFields;
        combinedFields.insert({"REST", std::make_pair(timeString, "time")});
        $$ = new RepDetail(
            -1, // Rep number
            combinedFields, // Custom fields
           "rep" + std::string($2.str),
           $1.line
        );
    }
    ;

rep_range:
    REPS RANGE {
        $$ = new std::vector<RepDetail*>();
        for (int i = $2.start; i <= $2.end; ++i) {
            $$->push_back(new RepDetail(
                i, // Rep number in the range
                *new std::map<std::string, std::pair<std::string,std::string> >(), // Empty custom fields
                "reps" + std::to_string($2.start) + "-" + std::to_string($2.end),
                $1.line
                
            ));
        }
    }
    | REPS RANGE custom_fields {
        $$ = new std::vector<RepDetail*>();
        std::map<std::string, std::pair<std::string, std::string> > combinedFields;
        combinedFields.insert($3->begin(), $3->end());
        std::vector<std::string> exprFields;
        bool consec = false;
        
        for ( auto& [field, valuePair] : combinedFields){
            auto& [value, type] = valuePair;
             
            if(type == "expression"){
                std::string op = value.substr(0,2);
                std::string rest = value.substr(2);
                
                if(op == "++" || op == "--" || op == "**"){
                    consec = true;
                    value = op[0] + rest;
                }

                exprFields.push_back(field);
            }
        }
        
        for (int i = $2.start; i <= $2.end; ++i) {
            auto fields = combinedFields;

            for(std::string f: exprFields){
                if(i > $2.start && !consec){
                    fields[f] = std::make_pair("+0", "expression");
                }
            }
            
            RepDetail* r = new RepDetail(
                i, // Rep number in the range
                fields, // Custom fields
                "reps" + std::to_string($2.start) + "-" + std::to_string($2.end),
                $1.line
            );


            $$->push_back(r);
        }
    }
    ;

custom_fields:
    custom_fields field_value_pair { $$ = $1; $1->insert($2->begin(), $2->end()); }
    | field_value_pair { $$ = new std::map<std::string, std::pair<std::string, std::string> >(); $$->insert($1->begin(), $1->end()); }
   
    ;

field_value_pair:
    // TODO: Type checking here instead of at runtime
    // Makes reporting error and error column easier as well
    // Only deferred expression should happen at run time

    IDENTIFIER STRING { 
        std::string field = $1.str;
        std::string actualField = $1.str;
        
        // Field could be an alias
        if(aliasToNameMap.find(field) != aliasToNameMap.end()){
            actualField = aliasToNameMap.at(field);
        }else{
            // Field does not exist i.e has not been defined
            if(nameToTypeMap.find(field) == nameToTypeMap.end()){
                std::string errorMessage = "The field '" + field + "' has not been defined.";

                printErrorMessage($2.line, "Undefined Field", errorMessage, $2.column, field.length() );

                exit(EXIT_FAILURE);
            }
        }

        if(constNameToValue.find(field) != constNameToValue.end()){
            // Field is actually a constant
            
            std::string errorMessage = "The field '" + field + "' is a constant. Its value cannot be changed.";

            printErrorMessage($2.line, "Constant Violation", errorMessage, $2.column, field.length() );

            exit(EXIT_FAILURE);
        }

        // Type check
        std::string type = "string";
        std::string value = $2.str;
        if(type != nameToTypeMap.at(actualField)){
            // Type error

                std::string errorMessage = "The field '" + field + "' has the wrong type."
                + "\n"
                + " Expected " + nameToTypeMap.at(actualField) + " but got " + value + " (" +type + ")."
                ;

                
                // int correctLineNo = line_number;
                printErrorMessage($2.line, "AWrong Type", errorMessage, $2.column, value.length());

                exit(EXIT_FAILURE);

        }

        std::map<std::string, std::pair<std::string, std::string> > *m = new std::map<std::string, std::pair<std::string, std::string> >();
        m->insert(std::make_pair(actualField, std::make_pair($2.str,*new std::string("string"))));
        $$ = m;
    }

    | IDENTIFIER EXPRESSION { 

        std::string value = $2.str;
        // Type check required here otherwise itt will fail if identifier does not exist
        // Gotta check if identifier exists and that it is either of type integer or float
        std::string field = $1.str;
        std::string actualField = field;

        // Field could be an alias
        if(aliasToNameMap.find(field) != aliasToNameMap.end()){
            actualField = aliasToNameMap.at(field);
        }else{
            // Field does not exist i.e has not been defined
            if(nameToTypeMap.find(field) == nameToTypeMap.end()){
                std::string errorMessage = "The field '" + field + "' has not been defined.";


                printErrorMessage($1.line, "Undefined Field", errorMessage, $1.column, field.length() );

                exit(EXIT_FAILURE);
            }
        }

        if(constNameToValue.find(field) != constNameToValue.end()){
            // Field is actually a constant
            
            std::string errorMessage = "The field '" + field + "' is a constant. Its value cannot be changed.";

            printErrorMessage($1.line, "Constant Violation", errorMessage, $1.column, field.length() );

            exit(EXIT_FAILURE);
        }

        std::string type = nameToTypeMap[actualField];

        // Type check
        // check if integer or float

        if("integer" != type && "float" != type && "expression" != type){
            // Type error


            std::string errorMessage = "The field '" + field + "' has the wrong type."
            + "\n"
            + " Expected " + nameToTypeMap.at(actualField) + " but got " + value + " (" +type + ")."
            ;

            
            printErrorMessage($2.line, "XWrong Type", errorMessage, $2.column, value.length());

            exit(EXIT_FAILURE);

        }

        // To evaluate expression if it is an expression (if possible) 
        // then save that value in the hashmap
        // Abort if it needs a previous value e.g +20
        if(operators.find(($2.str)[0]) == std::string::npos){
            // Ignore if it needs a previous value
            // Needs to be evaluated at run time
        

            typedef exprtk::expression<double> expression_t;
            typedef exprtk::parser<double> parser_t;

            std::string expression_string = $2.str;
            expression_t expression;
            parser_t parser;

            if (parser.compile(expression_string, expression)) {
                double expressionValue = expression.value();

                // double frVacPart = expressionValue - std::floor(expressionValue);

                //if(fracPart == 0.0){
                //    type = "integer";
                //}
                //else{
                //    type = "float";
                //}
            

                if(type == "float"){
                    float num = static_cast<float>(expressionValue);

                    std::ostringstream oss;
                    oss << std::fixed << std::setprecision(3) << num;

                    value = oss.str();

                }

                if(type == "integer"){
                    int num = static_cast<int>(expressionValue);

                    std::ostringstream oss;
                    oss << num;

                    value = oss.str();

                }

                    
            }
            else {
                
                std::string errorMsg = parser.error();
                size_t pos = errorMsg.find('-');
                printErrorMessage($2.line, "Invalid Expression",errorMsg.substr(pos+2), $2.column,strlen($2.str));
                exit(EXIT_FAILURE);
            }
        }
        else{
            // Defer evaluation at run time as a previous value is needed
            // i.e +20
            type = "expression";
        }

        std::map<std::string, std::pair<std::string, std::string> > *m = new std::map<std::string, std::pair<std::string, std::string> >();
        
        m->insert(std::make_pair(actualField, std::make_pair(value , type)));

        $$ = m;
    }
    
    | IDENTIFIER INTEGER_LITERAL { 
        std::string field = $1.str;
        std::string actualField = $1.str;
        
        // Field could be an alias
        if(aliasToNameMap.find(field) != aliasToNameMap.end()){
            actualField = aliasToNameMap.at(field);
        }else{
            // Field does not exist i.e has not been defined
            if(nameToTypeMap.find(field) == nameToTypeMap.end()){
                std::string errorMessage = "The field '" + field + "' has not been defined.";

                printErrorMessage($2.line, "Undefined Field", errorMessage, $2.column, field.length() );

                exit(EXIT_FAILURE);
            }
        }

        if(constNameToValue.find(field) != constNameToValue.end()){
            // Field is actually a constant
            
            std::string errorMessage = "The field '" + field + "' is a constant. Its value cannot be changed.";

            printErrorMessage($2.line, "Constant Violation", errorMessage, $2.column, field.length() );

            exit(EXIT_FAILURE);
        }

        // Type check
        std::string type = "integer";
        std::string value = $2.str;
        if(type != nameToTypeMap.at(actualField)){
            if(nameToTypeMap.at(actualField) != "float"){
                // Type error

                std::string errorMessage = "The field '" + field + "' has the wrong type."
                + "\n"
                + " Expected " + nameToTypeMap.at(actualField) + " but got " + value + " (" +type + ")."
                ;

                
                // int correctLineNo = line_number;
                printErrorMessage($2.line, "AWrong Type", errorMessage, $2.column, value.length());

                exit(EXIT_FAILURE);
            }
        }

        std::string actualValue = $2.str;
        
        if(nameToTypeMap.at(actualField) == "float"){
            float num = std::stof(value);

            std::ostringstream oss;
            oss << std::fixed << std::setprecision(3) << num;

            actualValue = oss.str();
            type = "float";

        }

        if(nameToTypeMap.at(actualField) == "integer"){
            int num = std::stoi(value);

            std::ostringstream oss;
            oss << num;

            actualValue = oss.str();

        }

        std::map<std::string, std::pair<std::string, std::string> > *m = new std::map<std::string, std::pair<std::string, std::string> >();
        m->insert(std::make_pair(actualField, std::make_pair(actualValue , type)));

        $$ = m;
    }
    | IDENTIFIER FLOAT_LITERAL { 
        std::string field = $1.str;
        std::string actualField = $1.str;
        
        // Field could be an alias
        if(aliasToNameMap.find(field) != aliasToNameMap.end()){
            actualField = aliasToNameMap.at(field);
        }else{
            // Field does not exist i.e has not been defined
            if(nameToTypeMap.find(field) == nameToTypeMap.end()){
                std::string errorMessage = "The field '" + field + "' has not been defined.";

                printErrorMessage($2.line, "Undefined Field", errorMessage, $2.column, field.length() );

                exit(EXIT_FAILURE);
            }
        }

        if(constNameToValue.find(field) != constNameToValue.end()){
            // Field is actually a constant
            
            std::string errorMessage = "The field '" + field + "' is a constant. Its value cannot be changed.";

            printErrorMessage($2.line, "Constant Violation", errorMessage, $2.column, field.length() );

            exit(EXIT_FAILURE);
        }

        // Type check
        std::string type = "float";
        std::string value = $2.str;
        if(type != nameToTypeMap.at(actualField)){
            // Type error

            if(nameToTypeMap.at(actualField) != "integer"){
                std::string errorMessage = "The field '" + field + "' has the wrong type."
                + "\n"
                + " Expected " + nameToTypeMap.at(actualField) + " but got " + value + " (" +type + ")."
                ;

                
                // int correctLineNo = line_number;
                printErrorMessage($2.line, "AWrong Type", errorMessage, $2.column, value.length());

                exit(EXIT_FAILURE);
            }
        }


        std::string actualValue = $2.str;
        
        if(nameToTypeMap.at(actualField) == "float"){
            float num = std::stof(value);

            std::ostringstream oss;
            oss << std::fixed << std::setprecision(3) << num;

            actualValue = oss.str();

        }

        if(nameToTypeMap.at(actualField) == "integer"){
            int num = std::stoi(value);

            std::ostringstream oss;
            oss << num;

            actualValue = oss.str();
            type = "integer";

        }
        std::map<std::string, std::pair<std::string, std::string> > *m = new std::map<std::string, std::pair<std::string, std::string> >();

        m->insert(std::make_pair(actualField, std::make_pair(actualValue , type)));

        $$ = m;
    }
    | IDENTIFIER BOOLEAN_LITERAL { 
        std::string field = $1.str;
        std::string actualField = $1.str;
        
        // Field could be an alias
        if(aliasToNameMap.find(field) != aliasToNameMap.end()){
            actualField = aliasToNameMap.at(field);
        }else{
            // Field does not exist i.e has not been defined
            if(nameToTypeMap.find(field) == nameToTypeMap.end()){
                std::string errorMessage = "The field '" + field + "' has not been defined.";

                printErrorMessage($2.line, "Undefined Field", errorMessage, $2.column, field.length() );

                exit(EXIT_FAILURE);
            }
        }

        if(constNameToValue.find(field) != constNameToValue.end()){
            // Field is actually a constant
            
            std::string errorMessage = "The field '" + field + "' is a constant. Its value cannot be changed.";

            printErrorMessage($2.line, "Constant Violation", errorMessage, $2.column, field.length() );

            exit(EXIT_FAILURE);
        }

        // Type check
        std::string type = "boolean";
        std::string value = $2.str;
        if(type != nameToTypeMap.at(actualField)){
            // Type error

                std::string errorMessage = "The field '" + field + "' has the wrong type."
                + "\n"
                + " Expected " + nameToTypeMap.at(actualField) + " but got " + value + " (" +type + ")."
                ;

                
                // int correctLineNo = line_number;
                printErrorMessage($2.line, "AWrong Type", errorMessage, $2.column, value.length());

                exit(EXIT_FAILURE);

        }
        std::map<std::string, std::pair<std::string, std::string> > *m = new std::map<std::string, std::pair<std::string, std::string> >();

        m->insert(std::make_pair(actualField, std::make_pair($2.str,*new std::string("boolean"))));

        $$ = m;
    }
    | IDENTIFIER TIME_LITERAL { 
        std::string field = $1.str;
        std::string actualField = $1.str;
        
        // Field could be an alias
        if(aliasToNameMap.find(field) != aliasToNameMap.end()){
            actualField = aliasToNameMap.at(field);
        }else{
            // Field does not exist i.e has not been defined
            if(nameToTypeMap.find(field) == nameToTypeMap.end()){
                std::string errorMessage = "The field '" + field + "' has not been defined.";

                printErrorMessage($2.line, "Undefined Field", errorMessage, $2.column, field.length() );

                exit(EXIT_FAILURE);
            }
        }

        if(constNameToValue.find(field) != constNameToValue.end()){
            // Field is actually a constant
            
            std::string errorMessage = "The field '" + field + "' is a constant. Its value cannot be changed.";

            printErrorMessage($2.line, "Constant Violation", errorMessage, $2.column, field.length() );

            exit(EXIT_FAILURE);
        }

        // Type check
        std::string type = "time";
        std::string value = $2.str;
        if(type != nameToTypeMap.at(actualField)){
            // Type error

                std::string errorMessage = "The field '" + field + "' has the wrong type."
                + "\n"
                + " Expected " + nameToTypeMap.at(actualField) + " but got " + value + " (" +type + ")."
                ;

                
                // int correctLineNo = line_number;
                printErrorMessage($2.line, "AWrong Type", errorMessage, $2.column, value.length());

                exit(EXIT_FAILURE);

        }
        std::map<std::string, std::pair<std::string, std::string> > *m = new std::map<std::string, std::pair<std::string, std::string> >();

     Time time;

     try {
            time = *new Time(*new std::string($2.str));
     }
     catch (const InvalidHour& e){
        int correctLineNo = $2.line;
        printErrorMessage(correctLineNo, "Invalid Hour", e.what(), $2.column, strlen($2.str));
        exit(EXIT_FAILURE);

     }
     catch (const InvalidMinute& e){
        int correctLineNo = $2.line;
        printErrorMessage(correctLineNo, "Invalid Minute", e.what(), $2.column, strlen($2.str));
        exit(EXIT_FAILURE);

     }
     catch (const InvalidSecond& e){
        int correctLineNo = $2.line;
        printErrorMessage(correctLineNo, "Invalid Second", e.what(), $2.column, strlen($2.str));
        exit(EXIT_FAILURE);

     }

        std::string timeString = std::to_string(time.convertIntoSeconds());

        m->insert(std::make_pair(actualField, std::make_pair(timeString,*new std::string("time"))));
        $$ = m;
    }
    ;

%%

/* void yyerror(const char *s) {
    std::cerr << "Error: " << s << " at line " << line_number << std::endl;
}
*/

void yyerror(const char *s) {
    initializeErrorMessageMap();
    extern char* yytext;

    std::vector<std::string> expectedTokens = extractExpectedTokens(s);
    std::string expected;
    if (!expectedTokens.empty()) {
        std::string token;
        for (auto it = expectedTokens.begin(); it != expectedTokens.end(); ++it) {
            token = *it;
            
            if(std::next(it) != expectedTokens.end()){
                token+=" ";
            }

            expected += token;
        }
        std::cerr << std::endl;
    }

    std::string errorMessage = expectedToken2ErrorMessage[expected];
    std::cout << expected << std::endl;
    if(expected == "") errorMessage += *new std::string(yytext) + "'.";
    printErrorMessage(yylval.token_info.line, "Syntax", errorMessage, yylval.token_info.column, strlen(yytext));
}