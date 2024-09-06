CXXFLAGS = -std=c++11 -Wall -Wextra

all2:
	flex -o src/lexer.cpp src/lexer.l  
	bison -d --debug -o src/parser.tab.cpp src/parser.y  
	g++ -c -o obj/parser.tab.o src/parser.tab.cpp
	g++ -c -o obj/lexer.o src/lexer.cpp
	g++ -c -o obj/ast.o src/ast.cpp
	g++ -c -o obj/main.o src/main.cpp
	g++ -c -o obj/error.o src/error.cpp
	g++ -c -o obj/helper.o src/helper.cpp
	g++ -c -o obj/time.o  src/time.cpp
	g++ -c -o obj/timeError.o src/timeError.cpp

	g++ -o w obj/parser.tab.o obj/lexer.o obj/ast.o obj/main.o obj/error.o obj/helper.o obj/time.o obj/timeError.o


all:
	flex -o src/lexer.cpp src/lexer.l  
	bison -d --debug -o src/parser.tab.cpp src/parser.y  
	g++ $(CXXFLAGS) -c -o obj/parser.tab.o src/parser.tab.cpp
	g++ $(CXXFLAGS) -c -o obj/lexer.o src/lexer.cpp
	g++ $(CXXFLAGS) -c -o obj/ast.o src/ast.cpp
	g++ $(CXXFLAGS) -c -o obj/main.o src/main.cpp
	g++ $(CXXFLAGS) -c -o obj/error.o src/error.cpp
	g++ $(CXXFLAGS) -c -o obj/helper.o src/helper.cpp
	g++ $(CXXFLAGS) -c -o obj/time.o  src/time.cpp
	g++ $(CXXFLAGS) -c -o obj/timeError.o src/timeError.cpp

	g++ $(CXXFLAGS) -o w obj/parser.tab.o obj/lexer.o obj/ast.o obj/main.o obj/error.o obj/helper.o obj/time.o obj/timeError.o


run2: all2
	./w workout.txt


run: all
	./w workout.txt
