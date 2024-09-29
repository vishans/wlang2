CXXFLAGS = -std=c++11 -Wall -Wextra

SRC = src
OBJ = obj

AST = $(SRC)/ast
ERROR = $(SRC)/error
HELPER = $(SRC)/helper
LEXER = $(SRC)/lexer
MAIN = $(SRC)/main
PARSER = $(SRC)/parser
TIME = $(SRC)/time

OBJ_FILES = $(OBJ)/parser.tab.o $(OBJ)/lexer.o $(OBJ)/ast.o $(OBJ)/main.o $(OBJ)/error.o $(OBJ)/helper.o $(OBJ)/time.o $(OBJ)/timeError.o



all:
	flex -o $(LEXER)/lexer.cpp $(LEXER)/lexer.l  
	bison -d --debug -o $(PARSER)/parser.tab.cpp $(PARSER)/parser.y  
	g++ $(CXXFLAGS) -c -o $(OBJ)/parser.tab.o $(PARSER)/parser.tab.cpp
	g++ $(CXXFLAGS) -c -o $(OBJ)/lexer.o $(LEXER)/lexer.cpp
	g++ $(CXXFLAGS) -c -o $(OBJ)/ast.o $(AST)/ast.cpp
	g++ $(CXXFLAGS) -c -o $(OBJ)/main.o $(MAIN)/main.cpp
	g++ $(CXXFLAGS) -c -o $(OBJ)/error.o $(ERROR)/error.cpp
	g++ $(CXXFLAGS) -c -o $(OBJ)/helper.o $(HELPER)/helper.cpp
	g++ $(CXXFLAGS) -c -o $(OBJ)/time.o  $(TIME)/time.cpp
	g++ $(CXXFLAGS) -c -o $(OBJ)/timeError.o $(TIME)/timeError.cpp

	g++ $(CXXFLAGS) -o w $(OBJ_FILES)



run: all
	./w test.txt
