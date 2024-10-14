#ifndef AST_H
#define AST_H

#include <vector>
#include <string>
#include <map>

/**
 * Class representing the details of an individual repetition within a set.
 */
class RepDetail {
public:
    int repNumber;                             // The repetition number (e.g., 1, 2, 3)
    std::string lineId;
    int lineNumber;
    std::map<std::string, std::pair<std::string, std::string> > customFields; // Custom fields associated with this rep

    /**
     * Constructor for RepDetail
     * 
     * @param rn The repetition number
     * @param fields The custom fields and their values for this rep
     * @param types The types of the custom fields
     * @param aliases The aliases used for custom fields
     */
    RepDetail(int rn, const std::map<std::string, 
    std::pair<std::string, std::string> >& fields,
    std::string lineId, int lineNumber);

    void inherit(const std::map<std::string, std::pair<std::string, std::string> > globalFields);
};

/**
 * Class representing a set of repetitions within an exercise.
 */
class SetDetail {
public:
    int setNumber;                        // The set number (e.g., 1st set, 2nd set)
    std::vector<RepDetail*> repDetails;   // A vector of RepDetail objects, each representing a rep
    std::map<std::string, std::pair<std::string, std::string> > customFields; // Custom fields associated with the Set
    int lineNumber;
    std::string lineId;
    int numberOfReps;
    

    /**
     * Constructor for SetDetail
     * 
     * @param sn The set number
     * @param rd A vector of RepDetail pointers representing the repetitions in this set
     */
    SetDetail(int sn, std::vector<RepDetail*> rd,
    std::string lineId,
    int lineNumber,
     std::map<std::string, std::pair<std::string, std::string> > fields  = *new std::map<std::string, std::pair<std::string, std::string> >());

    /**
     * Makes sure Reps start with 1 and are contiguous
     */
    void tally();

    /**
     * Fills in missing reps in a set
     */
    void expand(); // Deprecated

    void expand2();
    
    
    /**
     * Inherit fields from Exercise
     */
    void inherit(const std::map<std::string, std::pair<std::string, std::string> > setFields);

    /**
     * Finds the maximum rep number in this set
     */
    int findMaximumRepNumber();

    void passDownFieldsToReps();

    void setReps(std::vector<RepDetail*> reps);

    /**
     * Destructor for SetDetail
     */
    ~SetDetail();
};

/**
 * Class representing an entire exercise.
 */
class Exercise {
public:
    std::string name;                            // Name of the exercise (e.g., "squats")
    int sets;                                    // Number of sets for the exercise
    int reps;                                    // Number of repetitions per set
    std::string weight;                          // The weight used for the exercise
    std::vector<SetDetail*> setDetails;          // A vector of SetDetail objects representing sets
    std::map<std::string, std::pair<std::string, std::string> > customFields; // Custom fields associated with the exercise
    int lineNumber;
    std::string lineId;

    /**
     * Constructor for Exercise
     * 
     * @param n Name of the exercise
     * @param s Number of sets
     * @param r Number of reps per set
     * @param sd A vector of SetDetail pointers representing sets
     */
    Exercise(std::string n, int s, int r,
             std::vector<SetDetail*> sd, 
             const std::map<std::string, std::pair<std::string, std::string> >& fields, 
             std::string lineId, int lineNumber);

    /**
     * Destructor for Exercise
     */
    ~Exercise();

    void passDownRepNumberToSets();

    void passDownFieldsToSets();

    void inheritGlobalFields();

    void tally();

    void expand();

    int findMaximumSetNumber();
};

/**
 * Class representing a rest period within the workout.
 */
class Rest {
public:
    Rest();  // Constructor
};

/**
 * Class representing a list of exercises within a workout.
 */
class ExerciseList {
public:
    std::vector<Exercise*> exercises;  // A vector of Exercise pointers representing the exercises in the workout

    /**
     * Adds an exercise to the list of exercises.
     * 
     * @param e Pointer to the Exercise object to add
     */
    void addExercise(Exercise *e);

    /**
     * Destructor for ExerciseList
     */
    ~ExerciseList();
};

/**
 * Class representing the entire workout.
 */
class Workout {
public:
    ExerciseList *exerciseList;  // Pointer to an ExerciseList object

    /**
     * Constructor for Workout
     * 
     * @param el Pointer to an ExerciseList object
     */
    Workout(ExerciseList *el);

    /**
     * Destructor for Workout
     */
    ~Workout();

    /**
     * Function to print the workout details
     */
    void printWorkout() const;

    std::string csv() const;
};

#endif // AST_H