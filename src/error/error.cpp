#include "error.h"
#include <iostream>
#include <string>

void printErrorMessage(int lineNumber,  std::string errorType, std::string errorMessage, int column){
    std::string message = "Line " + std::to_string(lineNumber) +": "+ std::to_string(column)+ "." + "Error: "+ errorType + ". " + errorMessage;

    std::cout << message << std::endl;
}

std::vector<std::string> extractExpectedTokens(const std::string& s) {
    std::vector<std::string> expectedTokens;

    size_t expectingPos = s.find("expecting");
    if (expectingPos == std::string::npos) return expectedTokens;

    // Get the substring after "expecting "
    std::string expectedPart = s.substr(expectingPos + 10);  // Skip "expecting "

    // Split by " or " to get each expected token
    size_t start = 0;
    size_t end = expectedPart.find(" or ");
    while (end != std::string::npos) {
        expectedTokens.push_back(expectedPart.substr(start, end - start));
        start = end + 4;  // Move past " or "
        end = expectedPart.find(" or ", start);
    }
    // Add the last token after the final " or "
    expectedTokens.push_back(expectedPart.substr(start));

    return expectedTokens;
}