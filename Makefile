CXXFLAGS = -std=c++11 -Wall -Wextra 

# Windows-specific CXXFLAGS (with -static)
WINDOWS_CXXFLAGS = -std=c++11 -Wall -Wextra -static

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

# Target for native build
all:
	mkdir -p obj/
	w

# Parser and lexer targets
$(PARSER)/parser.tab.cpp $(PARSER)/parser.tab.hpp: $(PARSER)/parser.y
	bison -d --debug -o $(PARSER)/parser.tab.cpp $(PARSER)/parser.y

$(LEXER)/lexer.cpp: $(LEXER)/lexer.l
	flex -o $(LEXER)/lexer.cpp $(LEXER)/lexer.l

# Object files
$(OBJ)/parser.tab.o: $(PARSER)/parser.tab.cpp $(PARSER)/parser.tab.hpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OBJ)/lexer.o: $(LEXER)/lexer.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OBJ)/ast.o: $(AST)/ast.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OBJ)/main.o: $(MAIN)/main.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OBJ)/error.o: $(ERROR)/error.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OBJ)/helper.o: $(HELPER)/helper.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OBJ)/time.o: $(TIME)/time.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OBJ)/timeError.o: $(TIME)/timeError.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OBJ)/errorMessage.o: $(ERRORMSG)/errorMessage.cpp
	$(CXX) $(CXXFLAGS) -c -o $@ $<

# Link all object files to create the executable
w: $(OBJ_FILES)
	$(CXX) $(CXXFLAGS) -o $@ $(OBJ_FILES)

# Target for cross-compiling to Windows
windows: $(OBJ_FILES)
	$(WINDOWS_CXX) $(WINDOWS_CXXFLAGS) -o w.exe $(OBJ_FILES)

clean:
	rm -f $(OBJ)/*.o w w.exe

run: w
	./w meg.w -p