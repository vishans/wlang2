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
    std::string weight;                        // The weight used for this rep
    std::map<std::string, std::string> customFields; // Custom fields associated with this rep

    /**
     * Constructor for RepDetail
     * 
     * @param rn The repetition number
     * @param w The weight used for this repetition
     * @param fields The custom fields and their values for this rep
     * @param types The types of the custom fields
     * @param aliases The aliases used for custom fields
     */
    RepDetail(int rn, std::string w, const std::map<std::string, std::string>& fields,
              const std::map<std::string, std::string>& types, const std::map<std::string, std::string>& aliases);
};

/**
 * Class representing a set of repetitions within an exercise.
 */
class SetDetail {
public:
    int setNumber;                        // The set number (e.g., 1st set, 2nd set)
    std::vector<RepDetail*> repDetails;   // A vector of RepDetail objects, each representing a rep

    /**
     * Constructor for SetDetail
     * 
     * @param sn The set number
     * @param rd A vector of RepDetail pointers representing the repetitions in this set
     */
    SetDetail(int sn, std::vector<RepDetail*> rd);

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
    std::map<std::string, std::string> customFields; // Custom fields associated with the exercise

    /**
     * Constructor for Exercise
     * 
     * @param n Name of the exercise
     * @param s Number of sets
     * @param r Number of reps per set
     * @param w Weight used for the exercise
     * @param sd A vector of SetDetail pointers representing sets
     * @param cf Custom fields associated with the exercise
     */
    Exercise(std::string n, int s, int r, std::string w, 
             std::vector<SetDetail*> sd = std::vector<SetDetail*>(), 
             std::map<std::string, std::string> cf = std::map<std::string, std::string>());

    /**
     * Destructor for Exercise
     */
    ~Exercise();
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
};

#endif // AST_H