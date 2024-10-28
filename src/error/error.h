#ifndef ERROR_H
#define ERROR_H

#include <iostream>
#include <string>

void printErrorMessage(int lineNumber, std::string errorType, std::string errorMessage);
std::vector<std::string> extractExpectedTokens(const std::string& s);


#endif