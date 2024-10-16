# The W Language

The **W Language**, is a domain-specific language (DSL) designed to define and track workout routines. With the ability to define exercises, sets, reps, and custom fields, W Language aims to be a powerful tool for fitness enthusiasts and developers alike. 

## Key Features

- **Structure and Organize Your Workouts**: Transform your fitness routine into a well-organized plan! With W Language, you can effortlessly define exercises, sets, and reps, creating a clear structure for every workout. Whether you're planning a simple routine or a complex regimen, W Language makes it easy to keep everything in order.

- **Unleash the Power of Custom Fields**: Personalize your workout tracking by using custom fields with default values and optional aliases. Whether it's tracking rest time, tempo, or any other variable that matters to you, W Language lets you tailor your workout data to your unique fitness goals. It's all about flexibility and focusing on what you care about most in your fitness journey.

- **Unlock Data-Driven Insights**: Go beyond just tracking reps and sets. By capturing your workout data in a structured format, W Language enables powerful data analysis. Monitor your progress, identify trends, and even predict your next personal bests. Turn your workout logs into actionable insights to take your performance to the next level.

- **Perfect for Journaling Enthusiasts**: Keep a comprehensive and detailed record of your workouts. W Language is perfect for fitness enthusiasts who love to journal their progress. It provides a clear, organized format to log every session, helping you stay on track, reflect on your journey, and celebrate your achievements.

## Why C++?

The original prototype of the W Language, built in 2022, was developed entirely in Python, including its lexer and parser. However, I have now transitioned to C++ for a **major overhaul**. This move is driven by the need for:

- **Performance Improvements**: C++ offers enhanced speed and efficiency, essential for processing complex workout routines quickly and effectively.
- **Scalability**: With C++, the W Language can handle more complex parsing tasks and larger datasets, preparing for future enhancements.

## Technologies Used

- **C++**: The main language used for implementing the parser and interpreter.
- **Bison**: A powerful parser generator for defining the grammar and creating the parser.
- **Flex**: A lexical analyzer generator for tokenizing the input.

## W Compiler Usage

The `W` Compiler allows you to compile `.w` files with various options to customize the output. Below are the available options:

**Usage**:  


- `file` - The `.w` file you wish to compile.

### Options:
- `-h, --help`  
  Prints this help message and exits.
  
- `-p, --print`  
  Outputs the result to the standard output instead of a CSV file.
  
- `-c, --csv`  
  Generates CSV output. This is enabled by default.
  
- `-o, --output <path>`  
  Specifies the name or path of the output CSV file.
  
- `-v, --version`  
  Prints the compiler version and exits.




## Example of W Language Syntax

Here's a sneak peek at how you can define a workout using W Language:

```plaintext

// W supports both in-line and block comments

/*
Lower Body Workout 
October 16, 2024
*/

field weight type float default 0 as w // 'w' is an alias for weight
field perceived_difficulty type integer default 5 as pd // Scale of 1 to 10 where 5 is like average

const date "16/10/2024" // a const is appended to every row

workout {
    exercise "squats" sets 3 reps 10 weight 100 {
        set 1 {
            reps 1-5 weight 100
            rep 6 w 90 // using alias 'w' instead of 'weight'
            rest 1m
            reps 7-10 w 69.69
        }

        rest 2m30s

        set 2 {
            reps 1-8 w 90
            rep 9 w 90 pd 9 // Found this rep difficult to execute
            fail
        }

        rest 2m30s

        set 3 pd 7{ // Found the third set more challenging 7/10
            rep 1 w 80
            reps 2-10 w 69
        }

        rest 3m
    }
}

```

## Default CSV Output

By default, the compiler generates a CSV file when no additional options are provided. The output file will have the same name as the input file but with a `.csv` extension.

Generated output for the example above:

```plaintext

REST,date,exercise_id,exercise_name,perceived_difficulty,rep_id,set_id,weight
,"16/10/2024",1,"squats",5,1,1,100
,"16/10/2024",1,"squats",5,2,1,100
,"16/10/2024",1,"squats",5,3,1,100
,"16/10/2024",1,"squats",5,4,1,100
,"16/10/2024",1,"squats",5,5,1,100
,"16/10/2024",1,"squats",5,6,1,90
60,"16/10/2024",-1,REST,,-1,-1,
,"16/10/2024",1,"squats",5,7,1,69.69
,"16/10/2024",1,"squats",5,8,1,69.69
,"16/10/2024",1,"squats",5,9,1,69.69
,"16/10/2024",1,"squats",5,10,1,69.69
150,"16/10/2024",-1,REST,,-1,-1,
,"16/10/2024",1,"squats",5,1,2,90
,"16/10/2024",1,"squats",5,2,2,90
,"16/10/2024",1,"squats",5,3,2,90
,"16/10/2024",1,"squats",5,4,2,90
,"16/10/2024",1,"squats",5,5,2,90
,"16/10/2024",1,"squats",5,6,2,90
,"16/10/2024",1,"squats",5,7,2,90
,"16/10/2024",1,"squats",5,8,2,90
,"16/10/2024",1,"squats",9,9,2,90
150,"16/10/2024",-1,REST,,-1,-1,
,"16/10/2024",1,"squats",7,1,3,80
,"16/10/2024",1,"squats",7,2,3,69
,"16/10/2024",1,"squats",7,3,3,69
,"16/10/2024",1,"squats",7,4,3,69
,"16/10/2024",1,"squats",7,5,3,69
,"16/10/2024",1,"squats",7,6,3,69
,"16/10/2024",1,"squats",7,7,3,69
,"16/10/2024",1,"squats",7,8,3,69
,"16/10/2024",1,"squats",7,9,3,69
,"16/10/2024",1,"squats",7,10,3,69
180,"16/10/2024",-1,REST,,-1,-1,

```

## --print Option

When the `--print` option is used, the output is printed directly to the standard output instead of generating a CSV file.

Generated output for the example above:

```plaintext

Exercise: "squats", Sets: 3, Reps: 10, weight: 100,integer
  Set 1 
    Rep 1, perceived_difficulty: [ 5, integer ], weight: [ 100, integer ]
    Rep 2, perceived_difficulty: [ 5, integer ], weight: [ 100, integer ]
    Rep 3, perceived_difficulty: [ 5, integer ], weight: [ 100, integer ]
    Rep 4, perceived_difficulty: [ 5, integer ], weight: [ 100, integer ]
    Rep 5, perceived_difficulty: [ 5, integer ], weight: [ 100, integer ]
    Rep 6, perceived_difficulty: [ 5, integer ], weight: [ 90, integer ]
    REST 60s
    Rep 7, perceived_difficulty: [ 5, integer ], weight: [ 69.69, float ]
    Rep 8, perceived_difficulty: [ 5, integer ], weight: [ 69.69, float ]
    Rep 9, perceived_difficulty: [ 5, integer ], weight: [ 69.69, float ]
    Rep 10, perceived_difficulty: [ 5, integer ], weight: [ 69.69, float ]
  REST 150s
  Set 2 
    Rep 1, perceived_difficulty: [ 5, integer ], weight: [ 90, integer ]
    Rep 2, perceived_difficulty: [ 5, integer ], weight: [ 90, integer ]
    Rep 3, perceived_difficulty: [ 5, integer ], weight: [ 90, integer ]
    Rep 4, perceived_difficulty: [ 5, integer ], weight: [ 90, integer ]
    Rep 5, perceived_difficulty: [ 5, integer ], weight: [ 90, integer ]
    Rep 6, perceived_difficulty: [ 5, integer ], weight: [ 90, integer ]
    Rep 7, perceived_difficulty: [ 5, integer ], weight: [ 90, integer ]
    Rep 8, perceived_difficulty: [ 5, integer ], weight: [ 90, integer ]
    Rep 9, perceived_difficulty: [ 9, integer ], weight: [ 90, integer ]
  REST 150s
  Set 3 
    Rep 1, perceived_difficulty: [ 7, integer ], weight: [ 80, integer ]
    Rep 2, perceived_difficulty: [ 7, integer ], weight: [ 69, integer ]
    Rep 3, perceived_difficulty: [ 7, integer ], weight: [ 69, integer ]
    Rep 4, perceived_difficulty: [ 7, integer ], weight: [ 69, integer ]
    Rep 5, perceived_difficulty: [ 7, integer ], weight: [ 69, integer ]
    Rep 6, perceived_difficulty: [ 7, integer ], weight: [ 69, integer ]
    Rep 7, perceived_difficulty: [ 7, integer ], weight: [ 69, integer ]
    Rep 8, perceived_difficulty: [ 7, integer ], weight: [ 69, integer ]
    Rep 9, perceived_difficulty: [ 7, integer ], weight: [ 69, integer ]
    Rep 10, perceived_difficulty: [ 7, integer ], weight: [ 69, integer ]
  REST 180s


Constants: 
    date = "16/10/2024"

```

