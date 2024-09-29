#include "error.h"
#include <iostream>
#include <string>

void printErrorMessage(int lineNumber, std::string errorType, std::string errorMessage){
    std::string message = "Line " + std::to_string(lineNumber) +": " + "Error: "+ errorType + ". " + errorMessage;

    std::cout << message << std::endl;
}
