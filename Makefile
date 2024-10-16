CXXFLAGS = -std=c++11 -Wall -Wextra -static

SRC = src
OBJ = obj

AST = $(SRC)/ast
ERROR = $(SRC)/error
HELPER = $(SRC)/helper
LEXER = $(SRC)/lexer
MAIN = $(SRC)/main
PARSER = $(SRC)/parser
TIME = $(SRC)/time
ERRORMSG = $(SRC)/errorMessage


OBJ_FILES = $(OBJ)/parser.tab.o $(OBJ)/lexer.o $(OBJ)/ast.o $(OBJ)/main.o $(OBJ)/error.o $(OBJ)/helper.o $(OBJ)/time.o $(OBJ)/timeError.o $(OBJ)/errorMessage.o

# Compiler (for native macOS build); Apple Silicon
CXX = g++

WINDOWS_CXX = x86_64-w64-mingw32-g++


all:
	flex -o $(LEXER)/lexer.cpp $(LEXER)/lexer.l  
	bison -d --debug -o $(PARSER)/parser.tab.cpp $(PARSER)/parser.y  
	$(CXX) $(CXXFLAGS) -c -o $(OBJ)/parser.tab.o $(PARSER)/parser.tab.cpp
	$(CXX) $(CXXFLAGS) -c -o $(OBJ)/lexer.o $(LEXER)/lexer.cpp
	$(CXX) $(CXXFLAGS) -c -o $(OBJ)/ast.o $(AST)/ast.cpp
	$(CXX) $(CXXFLAGS) -c -o $(OBJ)/main.o $(MAIN)/main.cpp
	$(CXX) $(CXXFLAGS) -c -o $(OBJ)/error.o $(ERROR)/error.cpp
	$(CXX) $(CXXFLAGS) -c -o $(OBJ)/helper.o $(HELPER)/helper.cpp
	$(CXX) $(CXXFLAGS) -c -o $(OBJ)/time.o  $(TIME)/time.cpp
	$(CXX) $(CXXFLAGS) -c -o $(OBJ)/timeError.o $(TIME)/timeError.cpp
	$(CXX) $(CXXFLAGS) -c -o $(OBJ)/errorMessage.o $(ERRORMSG)/errorMessage.cpp

	$(CXX) $(CXXFLAGS) -o w $(OBJ_FILES)


# Target for cross-compiling to Windows
windows:
	flex -o $(LEXER)/lexer.cpp $(LEXER)/lexer.l  
	bison -d --debug -o $(PARSER)/parser.tab.cpp $(PARSER)/parser.y  
	$(WINDOWS_CXX) $(CXXFLAGS) -c -o $(OBJ)/parser.tab.o $(PARSER)/parser.tab.cpp
	$(WINDOWS_CXX) $(CXXFLAGS) -c -o $(OBJ)/lexer.o $(LEXER)/lexer.cpp
	$(WINDOWS_CXX) $(CXXFLAGS) -c -o $(OBJ)/ast.o $(AST)/ast.cpp
	$(WINDOWS_CXX) $(CXXFLAGS) -c -o $(OBJ)/main.o $(MAIN)/main.cpp
	$(WINDOWS_CXX) $(CXXFLAGS) -c -o $(OBJ)/error.o $(ERROR)/error.cpp
	$(WINDOWS_CXX) $(CXXFLAGS) -c -o $(OBJ)/helper.o $(HELPER)/helper.cpp
	$(WINDOWS_CXX) $(CXXFLAGS) -c -o $(OBJ)/time.o  $(TIME)/time.cpp
	$(WINDOWS_CXX) $(CXXFLAGS) -c -o $(OBJ)/timeError.o $(TIME)/timeError.cpp
	$(WINDOWS_CXX) $(CXXFLAGS) -c -o $(OBJ)/errorMessage.o $(ERRORMSG)/errorMessage.cpp

	$(WINDOWS_CXX) $(CXXFLAGS) -o w.exe $(OBJ_FILES)



run: all
	./w meg.w
