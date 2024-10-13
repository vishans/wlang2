#include <map>
#include <string>


std::map<std::string, std::string> unexpectedToken2ErrorMessage;

void initializeErrorMessageMap(){
    unexpectedToken2ErrorMessage[""] = "Expected field or const declarations or workout clause";
}
