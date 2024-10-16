#include "helper.h"
#include <string>
#include <iostream>
#include <fstream>

std::string fp; // Filepath given to main; parsed by cli11

/*
Flex seems to consume newlines very greedily which lead to my line_number counter or even
yylineno to be incremented. Sometimes during errors, reported line number might not be accurate.
The line number given is always >= the actual line number.

The function below opens the workout file and goes to the line number given by Flex (which might  not be accurate). Since the actual number is less or equal than line_number (or yylineno, given by Flex), the algorithm walks backwards until it finds a line with the substring keyword in it and then returns that line number, which is probably the right one. 

The algorithm does not consider spaces while searching for the substring in the line. 
Make sure keyword does not contain any spaces. 
For e.g "reps 1 - 7"          -> "reps1-7" 
        "reps   1  -     7"   -> "reps1-7" 

*/
int getActualLineNumber(int lineNumber, std::string keyword){
    std::ifstream file(fp);

    if(!file.is_open()){
        return -1;
    }

    int lineno = 1;
    std::string line;
    std::streampos checkpoint;

    // Go to approximate line hint (given by Flex)
    while(std::getline(file, line)){
        if(lineno == lineNumber){
            checkpoint = file.tellg();
            break;
        }

        lineno++;
    }

    // Move away 1 position from the newline
    // At first the get pointer is at a newline (it points to the end of line, lineNumber)
    // So we move in 1 position backwards so that the condition for the inner while loop to be true
    // -2 moves the cursor backwards, ultimately
    // When using file.get it always advaces the pointer before getting the char
    // So we move 2 position backwards, get will advace one position before reading,
    // effectively reading the -1th character.
    
    file.seekg(-2, std::ios::cur);
    char currentChar;
    file.get(currentChar);
    int currentLine = lineNumber;

    while(lineNumber > 0){
        // std::cout << "Inspecting line " << lineNumber << std::endl;

        std::string temp;
        while(currentChar != '\n' && file.tellg() != -1){
            // std::cout << "inl" << std::endl;
            if(currentChar != ' ' && currentChar != '\t')
                temp = currentChar + temp;

            // std::cout << "current char is " << currentChar << std::endl;
            // std::cout << "tellg is " << file.tellg() << std::endl;
            // std::cout << "Pointer is" << pointer << std::endl;
            file.seekg(-2, std::ios::cur);
            file.get(currentChar);
            // std::cin.get();

        }
        file.seekg(-2, std::ios::cur);
        file.get(currentChar);

        if(temp.find(keyword) != std::string::npos){
            // std::cout << temp << std::endl;
            return lineNumber;
        }
        // std::cin.get();

        lineNumber--;

    }

    return -1;
}