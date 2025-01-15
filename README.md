# The W Language

> [!WARNING]
> Albeit being fully functional, the column location in case of errors might be inconsistent or contain discrepancies. Line numbers are however accurate.
> I am aware of this bug. I plan on re-writing part of the compiler and fix it altogether.
> I plan on doing so during reading week as I am busy with school and work at the moment.

The **W Language**, is a domain-specific language (DSL) designed to define and track workout routines. With the ability to define exercises, sets, reps, and custom fields, W Language aims to be a powerful tool for fitness enthusiasts and developers alike. 

## Key Features

- **Structure and Organize Your Workouts**: Transform your fitness routine into a well-organized plan! With W Language, you can effortlessly define exercises, sets, and reps, creating a clear structure for every workout. Whether you're planning a simple routine or a complex regimen, W Language makes it easy to keep everything in order.

- **Unleash the Power of Custom Fields**: Personalize your workout tracking by using custom fields with default values and optional aliases. Whether it's tracking rest time, tempo, or any other variable that matters to you, W Language lets you tailor your workout data to your unique fitness goals. It's all about flexibility and focusing on what you care about most in your fitness journey.

- **Unlock Data-Driven Insights**: Go beyond just tracking reps and sets. By capturing your workout data in a structured format, W Language enables powerful data analysis. Monitor your progress, identify trends, and even predict your next personal bests. Turn your workout logs into actionable insights to take your performance to the next level.

- **Perfect for Journaling Enthusiasts**: Keep a comprehensive and detailed record of your workouts. W Language is perfect for fitness enthusiasts who love to journal their progress. It provides a clear, organized format to log every session, helping you stay on track, reflect on your journey, and celebrate your achievements.


## Technologies Used

- **C++**: The main language used for implementing the parser and compiler.
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
// Sample workout
// Janauary 15 2025

field weight type float default 10 as w
field resistance_type type string default "dumbbel" as rt 
field percentage_execution type float default 1 as pe

const date "15/01/2025" 

workout {

	exercise "squats" sets 5 reps 5 rt "barbel" w ++19{ // adds 19 to the previous value of w (which is 10)
		set 1 {
			reps 1-5 w +5 // using alias 'w' instead of full 'weight'
		}

		set 2 w 10{
			rep 1 w 29 
			rest 1m
			reps 2-5 w --5 // cumulatively subtracts 5 for each rep because of double -
		}
		
		set 3 w 10 {}

		set 4 rt "bb" w ++59{
			reps 3-5 w -5 // only subtracts 5 once and keeps that result because of single -
		}

		set 5 {
			rep 1 rt "body"
		}
	}

	exercise "pull ups" sets 3 reps 3 w +20 rt "weight vest" {
		set 3 w 0
	}
}
```

## Default CSV Output

By default, the compiler generates a CSV file when no additional options are provided. The output file will have the same name as the input file but with a `.csv` extension.

Generated output for the example above:

```plaintext

Exercise: "squats", Sets: 5, Reps: 5, resistance_type: "barbel",string, weight: 29.000,float
  Set 1 
    Rep 1, percentage_execution: [ 1, float ], resistance_type: [ "barbel", string ], weight: [ 34.000, float ]
    Rep 2, percentage_execution: [ 1, float ], resistance_type: [ "barbel", string ], weight: [ 34.000, float ]
    Rep 3, percentage_execution: [ 1, float ], resistance_type: [ "barbel", string ], weight: [ 34.000, float ]
    Rep 4, percentage_execution: [ 1, float ], resistance_type: [ "barbel", string ], weight: [ 34.000, float ]
    Rep 5, percentage_execution: [ 1, float ], resistance_type: [ "barbel", string ], weight: [ 34.000, float ]
  Set 2 
    Rep 1, percentage_execution: [ 1, float ], resistance_type: [ "barbel", string ], weight: [ 29.000, float ]
    REST 60s
    Rep 2, percentage_execution: [ 1, float ], resistance_type: [ "barbel", string ], weight: [ 24.000, float ]
    Rep 3, percentage_execution: [ 1, float ], resistance_type: [ "barbel", string ], weight: [ 19.000, float ]
    Rep 4, percentage_execution: [ 1, float ], resistance_type: [ "barbel", string ], weight: [ 14.000, float ]
    Rep 5, percentage_execution: [ 1, float ], resistance_type: [ "barbel", string ], weight: [ 9.000, float ]
  Set 3 
    Rep 1, percentage_execution: [ 1, float ], resistance_type: [ "barbel", string ], weight: [ 10.000, float ]
    Rep 2, percentage_execution: [ 1, float ], resistance_type: [ "barbel", string ], weight: [ 10.000, float ]
    Rep 3, percentage_execution: [ 1, float ], resistance_type: [ "barbel", string ], weight: [ 10.000, float ]
    Rep 4, percentage_execution: [ 1, float ], resistance_type: [ "barbel", string ], weight: [ 10.000, float ]
    Rep 5, percentage_execution: [ 1, float ], resistance_type: [ "barbel", string ], weight: [ 10.000, float ]
  Set 4 
    Rep 1, percentage_execution: [ 1, float ], resistance_type: [ "bb", string ], weight: [ 69.000, float ]
    Rep 2, percentage_execution: [ 1, float ], resistance_type: [ "bb", string ], weight: [ 69.000, float ]
    Rep 3, percentage_execution: [ 1, float ], resistance_type: [ "bb", string ], weight: [ 64.000, float ]
    Rep 4, percentage_execution: [ 1, float ], resistance_type: [ "bb", string ], weight: [ 64.000, float ]
    Rep 5, percentage_execution: [ 1, float ], resistance_type: [ "bb", string ], weight: [ 64.000, float ]
  Set 5 
    Rep 1, percentage_execution: [ 1, float ], resistance_type: [ "body", string ], weight: [ 29.000, float ]
    Rep 2, percentage_execution: [ 1, float ], resistance_type: [ "barbel", string ], weight: [ 29.000, float ]
    Rep 3, percentage_execution: [ 1, float ], resistance_type: [ "barbel", string ], weight: [ 29.000, float ]
    Rep 4, percentage_execution: [ 1, float ], resistance_type: [ "barbel", string ], weight: [ 29.000, float ]
    Rep 5, percentage_execution: [ 1, float ], resistance_type: [ "barbel", string ], weight: [ 29.000, float ]

Exercise: "pull ups", Sets: 3, Reps: 3, resistance_type: "weight vest",string, weight: 30.000,float
  Set 1 
    Rep 1, percentage_execution: [ 1, float ], resistance_type: [ "weight vest", string ], weight: [ 30.000, float ]
    Rep 2, percentage_execution: [ 1, float ], resistance_type: [ "weight vest", string ], weight: [ 30.000, float ]
    Rep 3, percentage_execution: [ 1, float ], resistance_type: [ "weight vest", string ], weight: [ 30.000, float ]
  Set 2 
    Rep 1, percentage_execution: [ 1, float ], resistance_type: [ "weight vest", string ], weight: [ 30.000, float ]
    Rep 2, percentage_execution: [ 1, float ], resistance_type: [ "weight vest", string ], weight: [ 30.000, float ]
    Rep 3, percentage_execution: [ 1, float ], resistance_type: [ "weight vest", string ], weight: [ 30.000, float ]
  Set 3 
    Rep 1, percentage_execution: [ 1, float ], resistance_type: [ "weight vest", string ], weight: [ 0.000, float ]
    Rep 2, percentage_execution: [ 1, float ], resistance_type: [ "weight vest", string ], weight: [ 0.000, float ]
    Rep 3, percentage_execution: [ 1, float ], resistance_type: [ "weight vest", string ], weight: [ 0.000, float ]


Constants: 
    date: [ "15/01/2025", string ]


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

