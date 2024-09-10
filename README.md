# 🏋️ W Language

The **W Language**, is a domain-specific language (DSL) designed to define and track workout routines. With the ability to define exercises, sets, reps, and custom fields, W Language aims to be a powerful tool for fitness enthusiasts and developers alike. 

## 🚧 Development Status

**Currently in active development!** 🚀 I am building out the features and continuously improving the syntax. As this project evolves, expect changes and new capabilities to be introduced. <br>
⚠️ **This project is still in its embryonic stage and is not yet ready for production.** ⚠️

## 🌟 Key Features

- **Structure and Organize Your Workouts**: Transform your fitness routine into a well-organized plan! With W Language, you can effortlessly define exercises, sets, and reps, creating a clear structure for every workout. Whether you're planning a simple routine or a complex regimen, W Language makes it easy to keep everything in order.

- **Unleash the Power of Custom Fields**: Personalize your workout tracking by using custom fields with default values and optional aliases. Whether it's tracking rest time, tempo, or any other variable that matters to you, W Language lets you tailor your workout data to your unique fitness goals. It's all about flexibility and focusing on what you care about most in your fitness journey.

- **Unlock Data-Driven Insights**: Go beyond just tracking reps and sets. By capturing your workout data in a structured format, W Language enables powerful data analysis. Monitor your progress, identify trends, and even predict your next personal bests. Turn your workout logs into actionable insights to take your performance to the next level.

- **Perfect for Journaling Enthusiasts**: Keep a comprehensive and detailed record of your workouts. W Language is perfect for fitness enthusiasts who love to journal their progress. It provides a clear, organized format to log every session, helping you stay on track, reflect on your journey, and celebrate your achievements.

## 🔥 Why C++?

The original prototype of the W Language, built in 2022, was developed entirely in Python, including its lexer and parser. However, I have now transitioned to C++ for a **major overhaul**. This move is driven by the need for:

- **Performance Improvements**: C++ offers enhanced speed and efficiency, essential for processing complex workout routines quickly and effectively.
- **Scalability**: With C++, the W Language can handle more complex parsing tasks and larger datasets, preparing for future enhancements.

## 🛠️ Technologies Used

- **C++**: The main language used for implementing the parser and interpreter.
- **Bison**: A powerful parser generator for defining the grammar and creating the parser.
- **Flex**: A lexical analyzer generator for tokenizing the input.
- **Custom C++ AST**: Abstract Syntax Tree (AST) for representing the parsed structure of the DSL.

## 📜 Example of W Language Syntax

Here's a sneak peek at how you can define a workout using W Language:
**(Note: Some of the features have not yet been implemented and some aspects of the syntax might change in the future)**

```plaintext

// W supports both in-line and block comments

/*
Lower Body Workout 
September 10, 2024
*/

field weight type float default 0 as w // 'w' is an alias for weight

workout {
    exercise "squats" sets 3 reps 10 weight 100 {
        set 1 {
            reps 1-5 weight 100
            rep 6 w 90 // using alias 'w' instead of 'weight'
            rest 1m
            reps 7-10 weight 69.69
        }
        rest 2m30s

        set 2 {
            rep 8 weight 90
        }

        rest 2m30s

        set 3 {
            rep 1 weight 80
            reps 2-10 weight 69
        }

        rest 3m
    }
}
