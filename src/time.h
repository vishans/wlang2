#ifndef TIME_HPP
#define TIME_HPP

#include <string>

class Time {
protected:
    int h;
    int m;
    int s;

public:
    Time(std::string time);
    Time();
    long convertIntoSeconds();
    void print();

private:
    void sec(std::string &time, std::size_t &hourIndex, std::size_t &minIndex, std::size_t &secIndex);
    void min(std::string &time, std::size_t &hourIndex, std::size_t &minIndex);
    void hour(std::string &time, std::size_t &hourIndex);


};


#endif