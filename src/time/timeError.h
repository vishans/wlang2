#ifndef TIME_ERROR
#define TIME_ERROR

#include <string>
#include <exception>

class InvalidHour : public std::exception {
private:
    std::string message;
public:
    // Constructor to initialize the custom error message
    InvalidHour(const std::string& msg);

    // Overriding the what() function from std::exception
    const char* what() const noexcept override;
};

class InvalidMinute : public std::exception {
private:
    std::string message;
public:
    // Constructor to initialize the custom error message
    InvalidMinute(const std::string& msg);

    // Overriding the what() function from std::exception
    const char* what() const noexcept override;
};

class InvalidSecond : public std::exception {
private:
    std::string message;
public:
    // Constructor to initialize the custom error message
    InvalidSecond(const std::string& msg);

    // Overriding the what() function from std::exception
    const char* what() const noexcept override;
};


#endif