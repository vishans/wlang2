#include <map>
#include <string>


std::map<std::string, std::string> expectedToken2ErrorMessage;

void initializeErrorMessageMap(){
    expectedToken2ErrorMessage[""] = "Unexpected token '";
    expectedToken2ErrorMessage["$end"] = "You cannot have any statements after the workout clause.";
    expectedToken2ErrorMessage["end of file"] = "You cannot have any statements after the workout clause.";

    expectedToken2ErrorMessage["WORKOUT FIELD CONST"] = "Expected either a field declaration, a constant declaration or a workout clause.";
    expectedToken2ErrorMessage["EXERCISE REST"]= "Expected an exercise clause or 'rest'.";
    expectedToken2ErrorMessage["'{'"]= "Expected an opening curly brackets '{'.";
    expectedToken2ErrorMessage["'}'"]= "Expected a closing curly brackets '}'.";
    expectedToken2ErrorMessage["STRING"]= "Expected an exercise name as a string. ";
    expectedToken2ErrorMessage["SETS"]= "Expected 'sets'.";
    expectedToken2ErrorMessage["INTEGER_LITERAL"]= "Expected an integer.";







}
