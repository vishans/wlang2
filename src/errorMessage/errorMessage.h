#ifndef ERROR_MSG_H
#define ERROR_MSG_H

#include <map>
#include <string>

extern std::map<std::string, std::string> expectedToken2ErrorMessage;
void initializeErrorMessageMap();

#endif