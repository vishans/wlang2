#include <iostream>
#include "ast.h"
#include "globals.h" // To be able to access nameToTypeMap for type checking
#include <cstdlib> // For exit()
#include "error.h"
#include "helper.h"


using namespace std;
extern int line_number;

// Implementation of RepDetail class
RepDetail::RepDetail(int rn, const map<string, pair<string, string> >& fields, std::string lineId, int lineNumber)
    : repNumber(rn), lineId(lineId), lineNumber(lineNumber) {
    // Populate customFields with the relevant fields and values
    string actualField;
    for (const auto& [field, valueType] : fields) {
        const auto& [value, type] = valueType;
        actualField = field;

        // Field could be an alias
        if(aliasToNameMap.find(field) != aliasToNameMap.end()){
            actualField = aliasToNameMap.at(field);
        }else{
            // Field does not exist i.e has not been defined
            if(nameToTypeMap.find(field) == nameToTypeMap.end()){
                std::string errorMessage = "The field '" + field + "' has not been defined.";
                int correctLineNo = getActualLineNumber(line_number, lineId);
                printErrorMessage(correctLineNo, "Undefine Field", errorMessage);

                exit(EXIT_FAILURE);
            }
        }

        // Type check
        if(type != nameToTypeMap.at(actualField)){
            // Type error

            if(!(type == "integer" && nameToTypeMap.at(actualField) == "float")){

                std::string errorMessage = "The field '" + field + "' has the wrong type."
                + "\n"
                + " Expected " + nameToTypeMap.at(actualField) + " but got " + value + " (" +type + ")."
                ;

                std::cout << "in here " << std::endl;
                
                int correctLineNo = getActualLineNumber(line_number, lineId);
                printErrorMessage(correctLineNo, "Wrong Type", errorMessage);

                exit(EXIT_FAILURE);

            }
        }
        
        customFields[actualField] = fields.at(field);
        
    }
}

void RepDetail::inherit(const std::map<std::string, std::pair<std::string, std::string> > setFields){
    for(const auto& [field, valueType]: setFields){

        const auto& [value, type] = valueType;

        if(customFields.find(field) != customFields.end()){
            customFields[field] = {value, type};
        }

    }
}


// Implementation of SetDetail class
SetDetail::SetDetail(int sn, vector<RepDetail*> rd,
std::string lineId,
int lineNumber,
 std::map<std::string, std::pair<std::string, std::string> >fields
) : setNumber(sn), repDetails(rd), lineId(lineId), lineNumber(lineNumber){

    string actualField;
    for (const auto& [field, valueType] : fields) {
        const auto& [value, type] = valueType;
        actualField = field;

        // Field could be an alias
        if(aliasToNameMap.find(field) != aliasToNameMap.end()){
            actualField = aliasToNameMap.at(field);
        }else{
            // Field does not exist i.e has not been defined
            if(nameToTypeMap.find(field) == nameToTypeMap.end()){
                std::string errorMessage = "The field '" + field + "' has not been defined.";
                int correctLineNo = getActualLineNumber(line_number, lineId);
                printErrorMessage(correctLineNo, "Undefine Field", errorMessage);

                exit(EXIT_FAILURE);
            }
        }

        // Type check
        if(type != nameToTypeMap.at(actualField)){
            // Type error

            if(!(type == "integer" && nameToTypeMap.at(actualField) == "float")){


            std::string errorMessage = "The field '" + field + "' has the wrong type."
            + "\n"
            + " Expected " + nameToTypeMap.at(actualField) + " but got " + value + " (" +type + ")."
            ;
           
            int correctLineNo = getActualLineNumber(line_number, lineId);
            printErrorMessage(correctLineNo, "Wrong Type", errorMessage);

            exit(EXIT_FAILURE);

            }
        }
        
        customFields[actualField] = fields.at(field);
        
    }



}

void SetDetail::tally(){
    int count = 1;
    for(const RepDetail* rep: repDetails){ 
        if(rep->repNumber != -1 && rep->repNumber != count){
            // error reps are not contiguous
            std::string errorMessage = "Reps should start with 1 and be contiguous.";
            int correctLineNo = getActualLineNumber(lineNumber, lineId);
            printErrorMessage(correctLineNo, "Non Contiguous Reps", errorMessage);

            exit(EXIT_FAILURE);
        }
        count++;
    }
}

int SetDetail::findMaximumRepNumber(){
    int max = -1;
    for(const auto& rep: repDetails){
        if(rep->repNumber > max)
            max = rep->repNumber;
    }

    return max;
}

void SetDetail::expand(){

    int maxRepNo = findMaximumRepNumber();
    vector<RepDetail*> reps;

    //return;// *new vector<RepDetail*>(); // TO DO: to expand set with -1 as rest
                            // Also will have to expand when for e.g we have
                            // set 4 {} -> inherit set fields and exercise

    if(maxRepNo < 0){
        if(setNumber != -1){ 
            for(int i = 0; i < numberOfReps; i++){
                reps.push_back(new RepDetail(i+1, customFields, "-1", -1));
            }

            repDetails = move(reps);

        }

        return;
    } 

    
    if(maxRepNo < 0){
        if(setNumber > 0){ // Not a rest; just an empty set clause

            // Just inherit from set custom fields
            for(int i = 0; i < maxRepNo; i++){
                reps.push_back(new RepDetail(i+1, customFields, "-1", -1));
            }


        }else{
            return;
        }
    }


    cout << "Max rep no is " << maxRepNo << std::endl;

    int j = 0;
    int repDetailsSize = repDetails.size();

   for(int i = 0; i < maxRepNo; i++){
        const RepDetail currentRep = *repDetails[j];
       

        if(currentRep.repNumber == i + 1){
             // Copy fields specific to this rep
            map<string, pair<string, string> > tempFields = customFields;

            for(auto& element: currentRep.customFields){
                tempFields[element.first] = element.second;
            }   

            reps.push_back(new RepDetail(currentRep.repNumber, tempFields, currentRep.lineId, currentRep.lineNumber)); 


            j++;
        }
        else{
            reps.push_back(new RepDetail(i+1, customFields, "-1", -1)); 
            // Both lineId and lineNumber are -1 because this is generated by the interpreter
        }
    
   }

    for (RepDetail* rep : repDetails) {
        delete rep; // Free the memory for each pointer
    }
    repDetails.clear(); // Remove all elements from the vector

    repDetails = move(reps);

    // return reps;

}

void SetDetail::setReps(std::vector<RepDetail*> reps){
    for (RepDetail* rep : repDetails) {
        delete rep; // Free the memory for each pointer
    }

    repDetails.clear();

    repDetails = *new vector<RepDetail*>();

    for(auto rep : reps){
        repDetails.push_back(rep);
    }
}

// Destructor to clean up dynamically allocated RepDetail objects
SetDetail::~SetDetail() {
    for (auto rep : repDetails) {
        delete rep;
    }
}

// Implementation of Exercise class
Exercise::Exercise(string n, int s, int r, 
vector<SetDetail*> sd,
const map<string, pair<string, string> >& fields,
std::string lineId, int lineNumber)

    : name(n), sets(s), reps(r), setDetails(sd), lineNumber(lineNumber), lineId(lineId)
    {
        // Populate customFields with the relevant fields and values
    string actualField;
    for (const auto& [field, valueType] : fields) {
        const auto& [value, type] = valueType;
        actualField = field;

        // Field could be an alias
        if(aliasToNameMap.find(field) != aliasToNameMap.end()){
            actualField = aliasToNameMap.at(field);
        }else{
            // Field does not exist i.e has not been defined
            if(nameToTypeMap.find(field) == nameToTypeMap.end()){
                std::string errorMessage = "The field '" + field + "' has not been defined.";
                int correctLineNo = getActualLineNumber(line_number, lineId);
                printErrorMessage(correctLineNo, "Undefine Field", errorMessage);

                exit(EXIT_FAILURE);
            }
        }

        // Type check
        if(type != nameToTypeMap.at(actualField)){
            // Type error

            if(!(type == "integer" && nameToTypeMap.at(actualField) == "float")){


            std::string errorMessage = "The field '" + field + "' has the wrong type."
            + "\n"
            + " Expected " + nameToTypeMap.at(actualField) + " but got " + value + " (" +type + ")."
            ;
           
            int correctLineNo = getActualLineNumber(line_number, lineId);
            printErrorMessage(correctLineNo, "Wrong Type", errorMessage);

            exit(EXIT_FAILURE);

            }
        }
        
        customFields[actualField] = fields.at(field);
        
    }
}

// Destructor to clean up dynamically allocated SetDetail objects
Exercise::~Exercise() {
    for (auto set : setDetails) {
        delete set;
    }
}

void Exercise::passDownRepNumberToSets(){
    for(SetDetail* set : setDetails){
        set->numberOfReps = reps;
    }
}

// Implementation of ExerciseList class
void ExerciseList::addExercise(Exercise* e) {
    exercises.push_back(e);
}

// Destructor to clean up dynamically allocated Exercise objects
ExerciseList::~ExerciseList() {
    for (auto exercise : exercises) {
        delete exercise;
    }
}

// Implementation of Workout class
Workout::Workout(ExerciseList* el)
    : exerciseList(el) {
}

// Destructor to clean up dynamically allocated ExerciseList object
Workout::~Workout() {
    delete exerciseList;
}

// Function to print the workout details
void Workout::printWorkout() const {
    for (Exercise* exercise : exerciseList->exercises) {
        cout << "Exercise: " << exercise->name
             << ", Sets: " << exercise->sets
             << ", Reps: " << exercise->reps;

        // Print custom fields for the exercise
        for (const auto& field : exercise->customFields) {
            cout << ", " << field.first << ": " << field.second.first << "," << field.second.second;
        }

        std::cout << std::endl;

        exercise->passDownRepNumberToSets();

        // Print details of each set
        for (SetDetail* setDetail : exercise->setDetails) {
            cout << "  Set " << setDetail->setNumber;
            
            for (const auto& field : setDetail->customFields) {
            cout << ", " << field.first << ": " << field.second.first << "," << field.second.second;
            }

            std::cout << " " << std::endl;
           
        //    setDetail->tally();
            setDetail->expand();
           
            for (RepDetail* repDetail : setDetail->repDetails)
            //for (RepDetail* repDetail : setDetail->expand()) 
             {
                cout << "    Rep " << repDetail->repNumber;

                // Print custom fields for each rep
                for (const auto& field : repDetail->customFields) {
                    cout << ", " << field.first << ": " << field.second.first << "," << field.second.second;
                }
                cout << endl;
            }
        }
    }
}