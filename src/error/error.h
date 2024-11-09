#ifndef ERROR_H
#define ERROR_H

#include <iostream>
#include <vector>
#include <string>

void printErrorMessage(int lineNumber, std::string errorType, std::string errorMessage, int column=0, int length=0);
std::vector<std::string> extractExpectedTokens(const std::string& s);

std::string getLine(std::string& path, int lineNumber);


#endif