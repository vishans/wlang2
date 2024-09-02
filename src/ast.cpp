#include <iostream>
#include "ast.h"
#include "globals.h" // To be able to access nameToTypeMap for type checking


using namespace std;

// Implementation of RepDetail class
RepDetail::RepDetail(int rn, const map<string, pair<string, string> >& fields, const map<string, string>& aliasToNameMap)
    : repNumber(rn) {
    // Populate customFields with the relevant fields and values
    string actualField;
    for (const auto& [field, valueType] : fields) {
        const auto& [value, type] = valueType;
        actualField = field;

        // Field could be an alias
        if(aliasToNameMap.find(field) != aliasToNameMap.end()){
            actualField = aliasToNameMap.at(field);
        }
        
        customFields[actualField] = fields.at(field);
        
    }
}

// Implementation of SetDetail class
SetDetail::SetDetail(int sn, vector<RepDetail*> rd)
    : setNumber(sn), repDetails(rd) {
}

// Destructor to clean up dynamically allocated RepDetail objects
SetDetail::~SetDetail() {
    for (auto rep : repDetails) {
        delete rep;
    }
}

// Implementation of Exercise class
Exercise::Exercise(string n, int s, int r, vector<SetDetail*> sd, map<string, string> cf)
    : name(n), sets(s), reps(r), setDetails(sd), customFields(cf) {
}

// Destructor to clean up dynamically allocated SetDetail objects
Exercise::~Exercise() {
    for (auto set : setDetails) {
        delete set;
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
             << ", Reps: " << exercise->reps
             << ", Weight: " << exercise->weight << endl;

        // Print custom fields for the exercise
        for (const auto& field : exercise->customFields) {
            cout << "    " << field.first << ": " << field.second << endl;
        }

        // Print details of each set
        for (SetDetail* setDetail : exercise->setDetails) {
            cout << "  Set " << setDetail->setNumber << ":" << endl;
            for (RepDetail* repDetail : setDetail->repDetails) {
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