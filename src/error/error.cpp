#include "error.h"
#include <iostream>
#include <fstream>
#include <string>
#include <algorithm>
#include <vector>

extern std::string fp;

void printErrorMessage(int lineNumber,  std::string errorType, std::string errorMessage, int column, int length){
    std::string message = fp +":" + std::to_string(lineNumber) +":"+ std::to_string(column)+  ": Error: "+ errorType + ". " + errorMessage;

    std::cout << message << std::endl << std::endl;
    std::cout << '\t' << getLine(fp, lineNumber) << std::endl;
    std::cout << '\t' <<std::string(std::max(column - 1, 0), ' ') << std::string(std::max(length, 0), '^') << std::endl;

    //std::cout << "Column was " << column << std::endl;
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

std::string getLine(std::string& path, int lineNumber){
    std::ifstream file(path); // Open the file
    std::string line;
    int currentLine = 1; // Start at the first line

    if (file.is_open()) {
        while (std::getline(file, line)) { // Read each line
            if (currentLine == lineNumber) {
                return line; // Return the desired line
            }
            currentLine++;
        }
        file.close(); // Close the file after reading
    } else {
        std::cerr << "Could not open the file." << std::endl;
    }
    return ""; // Return empty if line number doesn't exist
}
