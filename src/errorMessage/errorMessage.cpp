#include <map>
#include <string>


std::map<std::string, std::string> expectedToken2ErrorMessage;

void initializeErrorMessageMap(){
    expectedToken2ErrorMessage[""] = "Expected field or const declarations or workout clause";
    expectedToken2ErrorMessage["$end"] = "You cannot have any statements after the workout clause.";

}
