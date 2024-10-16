#include <iostream>
#include "./ast.h"
#include "../globals/globals.h" // To be able to access nameToTypeMap for type checking
#include <cstdlib> // For exit()
#include "../error/error.h"
#include "../helper/helper.h"
#include <algorithm>
#include <map>


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

        if(customFields.find(field) == customFields.end()){
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
    
    int prev = 0;
    for(const RepDetail* rep: repDetails){ 
        if(rep->repNumber != -1 && rep->repNumber != -2){ // skip REST reps and FAIL reps
            if(rep->repNumber <= prev){
                
                std::string errorMessage = "Reps should be positive and increasing.";
                int correctLineNo = getActualLineNumber(rep->lineNumber, rep->lineId);
                printErrorMessage(correctLineNo, "Invalid Reps", errorMessage);

                exit(EXIT_FAILURE);
            }
            prev = rep->repNumber;
        }
        // else{
        //     std::cout<< "SKIPPED REST" <<std::endl;
        // }
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

void SetDetail::expand2(){
    std::vector<RepDetail*> reps;

    if(setNumber < 0){ // The Set itself is either a REST (-1) or a FAIL (-2)
        return; // Nothing to expand
    }

    if(repDetails.size() == 0 ){ // No reps inside
        // Empty set clause
        // Inherits everything from Set

        for(int i = 0; i < numberOfReps; i++){
            reps.push_back(new RepDetail(i+1, customFields, "-404", -404));
        }

        repDetails = std::move(reps);
    }


    int i = 0; // repDetails index
    int j = 1; // actualRep


    while(i < repDetails.size()){
        RepDetail* currentRep = repDetails[i];

        if(currentRep->repNumber < 0){ // Either a REST (-1) or a FAIL (-2) rep
            if(currentRep->repNumber == -2){ // FAIL -> we abort everything
                repDetails = std::move(reps);
                return;

            }

            // Just a REST rep
            reps.push_back(currentRep);
            i++;
            continue;
        }

        if(currentRep->repNumber != j){
            reps.push_back(new RepDetail(j, customFields, "-404", -404)); // Fill
            j++;

        }
        else{
           reps.push_back(currentRep);
           j++;
           i++;

        }
    }

    // Walking back to see where we left off and avoid REST and FAIL reps
    // Might need to add remaining reps

    int k = reps.size()-1;
    while(k > 0 && reps[k]->repNumber < 0){
        k--;
    }

    // Note k is the index of the last normal rep; not the rep itself

    // Add the remaining reps if need be
    for(int i = reps[k]->repNumber + 1; i <= numberOfReps; i++){
        reps.push_back(new RepDetail(i, customFields, "-404", -404)); // Fill
    }


    repDetails = std::move(reps);

}

void SetDetail::expand(){

    std::cout << "---" << std::endl;
    int specialCount = 0;
    for(auto rep: repDetails){
        std::cout<< rep->repNumber << std::endl;
        if(rep->repNumber < 0 ) specialCount++;
    }
    std::cout << "---" << std::endl;


    int maxRepNo = findMaximumRepNumber();
    vector<RepDetail*> reps;

    //return;// *new vector<RepDetail*>(); // TO DO: to expand set with -1 as rest
                            // Also will have to expand when for e.g we have
                            // set 4 {} -> inherit set fields and exercise

    if(maxRepNo < 0){
        if(setNumber != -1 && setNumber != -2){ 
            for(int i = 0; i < numberOfReps; i++){
                reps.push_back(new RepDetail(i+1, customFields, "-404", -404));
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
        // std::cout << "meow"<< std::endl;
        const RepDetail currentRep = *repDetails[j];
        std::cout << "  Current NO " << currentRep.repNumber <<std::endl;
        if(currentRep.repNumber < 0){
            reps.push_back(repDetails[j]);
            i--;
            j++;
            std::cout << "here" << std::endl;
            continue;
        }
       

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

   // Add remaining reps if any
   int lastSetNumber = reps[reps.size()-1]->repNumber;
   
   for(int i = lastSetNumber+1; i <= numberOfReps; i++){
        reps.push_back(new RepDetail(i, customFields, "-1", -1));
   }

    // for (RepDetail* rep : repDetails) {
    //     delete rep; // Free the memory for each pointer
    // }
    // repDetails.clear(); // Remove all elements from the vector

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

void SetDetail::passDownFieldsToReps(){
    for(RepDetail* rep: repDetails){
        rep->inherit(customFields);
    }
}

void SetDetail::inherit(const std::map<std::string, std::pair<std::string, std::string> > setFields){
    // std::cout <<"set number " <<setNumber << std::endl;
    for(const auto& [field, valueType]: setFields){

        const auto& [value, type] = valueType;

        if(customFields.find(field) == customFields.end()){
            customFields[field] = {value, type};

            // std::cout << field << " is not present. SO ADDING <<<" << std::endl;
        }else{
            // std::cout << field << " is already present" << std::endl;
        }

    }

    // std::cout << std::endl << std::endl;
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

void Exercise::inheritGlobalFields(){
    for(const auto& [fieldName, defaultValue]: nameToDefaultMap){
        if(customFields.find(fieldName) == customFields.end()){
            std::string type = nameToTypeMap.at(fieldName);

            customFields[fieldName] = {defaultValue, type};
        }
    }
}

void Exercise::passDownFieldsToSets(){
    for(SetDetail* set: setDetails){
        set->inherit(customFields);
    }
}

void Exercise::tally(){
    int prev = 0;

    for(const SetDetail* set: setDetails){
        if(set->setNumber != -1 && set->setNumber != -2){ // Skip Rest set and fail set
            if(set->setNumber <= prev){

                std::string errorMessage = "Sets should be positive and increasing.";
                int correctLineNo = getActualLineNumber(set->lineNumber, set->lineId);
                printErrorMessage(correctLineNo, "Invalid Sets", errorMessage);

                exit(EXIT_FAILURE);
            }

            prev = set->setNumber;
        }
    }
}

int Exercise::findMaximumSetNumber(){
    int max = -1;
    for(const SetDetail* set: setDetails){
        if(set->setNumber > max){
            max = set->setNumber;
        }
    }

    return max;
}

void Exercise::expand(){

    if(sets < 0) return; // Skip REST


    int maxSetNo = std::max(findMaximumSetNumber(), sets);
    // std::cout << "Max set num is " << maxSetNo << std::endl;
    std::vector<SetDetail*> tempSets;
    SetDetail* currentSet;

    int i = 0, j = 1;

    while(i < setDetails.size()){
        // std::cout << "i is " << i << std::endl;

        currentSet = setDetails[i];
        // std::cout<< "Current set number " << currentSet->setNumber << std::endl;

        if(currentSet->setNumber < 0){ // REST or FAIL

            if(currentSet->setNumber == -2){  // FAIL
                setDetails = tempSets;
                return;
            }


            i++;
            tempSets.push_back(currentSet);
            continue; // Skip it
        }

        if(currentSet->setNumber != j){
            // Fill in that missing set
            tempSets.push_back(new SetDetail(j, *new std::vector<RepDetail*>, "-1", -1));
            
            
        }else{
            tempSets.push_back(currentSet);
            i++;
        }

        j++; // Increase j no matter what since we pushed back a set into the temp vector

    }

    // Add any remaining missing sets
    while (j <= maxSetNo) {
        tempSets.push_back(new SetDetail(j, std::vector<RepDetail*>(), "-1", -1));
        j++;
    }

    setDetails = tempSets;

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

        if(exercise->sets == -1){
            // REST
            cout << "REST " << exercise->customFields["REST"].first << "s" << endl << endl;
            continue;
        }


        cout << "Exercise: " << exercise->name
             << ", Sets: " << exercise->sets
             << ", Reps: " << exercise->reps;

        // Print custom fields for the exercise
        for (const auto& field : exercise->customFields) {
            cout << ", " << field.first << ": " << field.second.first << "," << field.second.second;
        }

        std::cout << std::endl;

        exercise->tally();
        exercise->expand();

        exercise->inheritGlobalFields();
        exercise->passDownRepNumberToSets();
        exercise->passDownFieldsToSets();

        // Print details of each set
        for (SetDetail* setDetail : exercise->setDetails) {

            if(setDetail->setNumber == -1){
                // REST
                cout << "  REST " << setDetail->customFields["REST"].first << "s" << endl;
               
                continue;
            }



            cout << "  Set " << setDetail->setNumber;
            
            // for (const auto& field : setDetail->customFields) {
            // cout << ", " << field.first << ": " << field.second.first << "," << field.second.second;
            // }

            std::cout << " " << std::endl;
           
            setDetail->tally();
            setDetail->passDownFieldsToReps();
            setDetail->expand2();
           
            for (RepDetail* repDetail : setDetail->repDetails) 
            {
                // Rest
                if(repDetail->repNumber == -1){
                    cout << "    REST " << repDetail->customFields["REST"].first << "s" << endl;
                    continue;
                }

                cout << "    Rep " << repDetail->repNumber;

                // Print custom fields for each rep
                for (const auto& field : repDetail->customFields) {
                    cout << ", " << field.first << ": " << field.second.first << "," << field.second.second;
                }
                cout << endl;
            }
        }

        cout << endl;
    }
}

string Workout::csv() const {

    map<string, vector<string> > columnToValues;

    vector<string> columnNames = {"exercise_id","set_id","rep_id","exercise_name"};

    // Mandatory Fields, as specified just above in columnNames
    for(auto& columnName: columnNames){
        columnToValues[columnName] = *new vector<string>();
    }

    // Custom Fields
    for(auto& nameTypePair: nameToTypeMap){
        columnToValues[nameTypePair.first] = *new vector<string>();
    }

    // Constants
    for(auto& nameValuePair: constNameToValue){
        columnToValues[nameValuePair.first] = *new vector<string>();
    }



    int exerciseId = 0;

    for (Exercise* exercise : exerciseList->exercises) {
        exerciseId++;


        // REST
        if(exercise->sets == -1){
            exerciseId--;

            for(auto& columnValuesPair : columnToValues){
                auto& [column, values] = columnValuesPair;
                values.push_back("");

            }

            columnToValues["REST"].at(columnToValues["REST"].size()-1) = exercise->customFields["REST"].first;
            columnToValues["exercise_name"].at(columnToValues["exercise_name"].size()-1) = "REST";

            columnToValues["rep_id"].at(columnToValues["rep_id"].size()-1) = "-1";
            columnToValues["set_id"].at(columnToValues["set_id"].size()-1) = "-1";
            columnToValues["exercise_id"].at(columnToValues["exercise_id"].size()-1) = "-1";

            for(auto& nameToValuePair: constNameToValue){
                columnToValues[nameToValuePair.first].at(columnToValues[nameToValuePair.first].size()-1) = nameToValuePair.second;
            }

            continue;
        }


        
        exercise->tally();
        exercise->expand();

        exercise->inheritGlobalFields();
        exercise->passDownRepNumberToSets();
        exercise->passDownFieldsToSets();

       
        for (SetDetail* setDetail : exercise->setDetails) {

            // REST
            if(setDetail->setNumber == -1){


                for(auto& columnValuesPair : columnToValues){
                    auto& [column, values] = columnValuesPair;
                    values.push_back("");

                }

                columnToValues["REST"].at(columnToValues["REST"].size()-1) = setDetail->customFields["REST"].first;
                columnToValues["exercise_name"].at(columnToValues["exercise_name"].size()-1) = "REST";

                columnToValues["rep_id"].at(columnToValues["rep_id"].size()-1) = "-1";
                columnToValues["set_id"].at(columnToValues["set_id"].size()-1) = "-1";
                columnToValues["exercise_id"].at(columnToValues["exercise_id"].size()-1) = "-1";

                for(auto& nameToValuePair: constNameToValue){
                    columnToValues[nameToValuePair.first].at(columnToValues[nameToValuePair.first].size()-1) = nameToValuePair.second;
                }


                continue;

            }


            setDetail->tally();
            setDetail->passDownFieldsToReps();
            setDetail->expand2();
           
            for (RepDetail* repDetail : setDetail->repDetails)
            {
                // REST
                if(repDetail->repNumber == -1){

                    for(auto& [columnName, values] : columnToValues){

                        values.push_back("");

                    }

                    columnToValues["REST"].at(columnToValues["REST"].size()-1) =repDetail->customFields["REST"].first;

                    columnToValues["exercise_name"].at(columnToValues["exercise_name"].size()-1) = "REST";

                    columnToValues["rep_id"].at(columnToValues["rep_id"].size()-1) ="-1";

                    columnToValues["set_id"].at(columnToValues["set_id"].size()-1) = "-1";

                    columnToValues["exercise_id"].at(columnToValues["exercise_id"].size()-1) = "-1";


                    // Add constant fields to rep
                    for(auto& nameToValuePair: constNameToValue){
                        columnToValues[nameToValuePair.first].at(columnToValues[nameToValuePair.first].size()-1) = nameToValuePair.second;
                    }          

                    continue;
                    
                }
                
                // Populating fields that this rep has
                for(auto& [columnName, values] : columnToValues){

                    if(repDetail->customFields.find(columnName) != repDetail->customFields.end()){
                        values.push_back(repDetail->customFields[columnName].first);
                    }
                    else{
                        values.push_back("");
                    }

                }


                columnToValues["exercise_name"].at(columnToValues["exercise_name"].size()-1) = exercise->name;

                columnToValues["rep_id"].at(columnToValues["rep_id"].size()-1) = to_string(repDetail->repNumber);
                columnToValues["set_id"].at(columnToValues["set_id"].size()-1) = to_string(setDetail->setNumber);
                columnToValues["exercise_id"].at(columnToValues["exercise_id"].size()-1) = to_string(exerciseId);

                for(auto& nameToValuePair: constNameToValue){
                    columnToValues[nameToValuePair.first].at(columnToValues[nameToValuePair.first].size()-1) = nameToValuePair.second;
                }
            }
        }

    }

    string result;
    int n = columnToValues["set_id"].size();

    // Create row names ie rep_id,set_id etc...
    for(auto it = columnToValues.begin(); it != columnToValues.end(); it++){
        result += it->first;

        if(next(it) != columnToValues.end()){
            result += ",";
        }
    }
   
    string row;
    for(int i = 0 ; i < n; i++){
        row = "";

        for(auto it = columnToValues.begin(); it != columnToValues.end(); it++){
            row += it->second.at(i) ;

            if(next(it) != columnToValues.end()){
                row += ",";
            }
        }


        result += '\n' + row;
        
    }
    
    return result;
}