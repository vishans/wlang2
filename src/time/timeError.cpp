#include "timeError.h"

// Constructor definition
InvalidHour::InvalidHour(const std::string& msg) : message(msg) {}

// Overriding the what() function from std::exception
const char* InvalidHour::what() const noexcept {
    return message.c_str();
}

InvalidMinute::InvalidMinute(const std::string& msg) : message(msg) {}


const char* InvalidMinute::what() const noexcept {
    return message.c_str();
}

InvalidSecond::InvalidSecond(const std::string& msg) : message(msg) {}


const char* InvalidSecond::what() const noexcept {
    return message.c_str();
}