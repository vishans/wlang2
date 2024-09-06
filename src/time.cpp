#include "time.h"
#include "timeError.h"
#include <iostream>

Time::Time(std::string time){
    size_t hourIndex = time.find("h");
    if( hourIndex != std::string::npos){
        // e.g 10h 
        hour(time, hourIndex);
       
    }

    size_t minIndex = time.find("m");

    if(minIndex != std::string::npos){
        // e.g 10h30m
        min(time, hourIndex, minIndex);
        
    }

    size_t secIndex = time.find("s");
    if(secIndex != std::string::npos){
        // e.g 10h30m14s
        sec(time, hourIndex, minIndex, secIndex);

    }

          
}

void Time::hour(std::string &time, size_t &hourIndex){
    std::string hourString = time.substr(0, hourIndex+1);
    h = std::stoi(hourString);

    // Validate hour (0 <= h <= 23)
    if(h < 0 || h > 23){
        throw InvalidHour(hourString + " is outside the valid hour range (0 <= hour <= 23).");
    }

}

void Time::min(std::string &time,size_t &hourIndex ,size_t &minIndex){
    std::string minString = time.substr(hourIndex + 1, minIndex - hourIndex - 1);
    m = std::stoi(minString);

    // Validate minutes (0 <= m  <= 59)
    if(m < 0 || m > 59){
        throw InvalidMinute(minString + " is outside the valid hour range (0 <= minute <= 59).");
    }

}

void Time::sec(std::string &time, std::size_t &hourIndex, std::size_t &minIndex, std::size_t &secIndex){
    std::string secString = time.substr(minIndex + 1, hourIndex - secIndex - 1);
    s = std::stoi(secString);

    // Validate seconds (0 <= s <= 59)
    if(s < 0 || s > 59){
        throw InvalidSecond(secString + " is outside the valid second range (0 <= second <= 59).");
    }

}

long Time::convertIntoSeconds(){
    return (h * 3600) + (m * 60) + s;
}

void Time::print(){
    std::cout << "h is " << h << std::endl;
    std::cout << "m is " << m << std::endl;
    std::cout << "s is " << s << std::endl;

}