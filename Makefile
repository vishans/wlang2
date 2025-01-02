# Default compiler and flags
CXX = g++
CXXFLAGS = -std=c++11 -Wall -Wextra

# Windows-specific compiler and flags
WINDOWS_CXX = x86_64-w64-mingw32-g++
WINDOWS_CXXFLAGS = -std=c++11 -Wall -Wextra -static

SRC = src
OBJ = obj
WIN_OBJ = win_obj

AST = $(SRC)/ast
ERROR = $(SRC)/error
HELPER = $(SRC)/helper
LEXER = $(SRC)/lexer
MAIN = $(SRC)/main
PARSER = $(SRC)/parser
TIME = $(SRC)/time
ERRORMSG = $(SRC)/errorMessage

OBJ_FILES = $(OBJ)/parser.tab.o $(OBJ)/lexer.o $(OBJ)/ast.o $(OBJ)/main.o $(OBJ)/error.o $(OBJ)/helper.o $(OBJ)/time.o $(OBJ)/timeError.o $(OBJ)/errorMessage.o
WIN_OBJ_FILES = $(WIN_OBJ)/parser.tab.o $(WIN_OBJ)/lexer.o $(WIN_OBJ)/ast.o $(WIN_OBJ)/main.o $(WIN_OBJ)/error.o $(WIN_OBJ)/helper.o $(WIN_OBJ)/time.o $(WIN_OBJ)/timeError.o $(WIN_OBJ)/errorMessage.o

# Target for native build
all: obj w

obj:
	mkdir -p $(OBJ)

win_obj:
	mkdir -p $(WIN_OBJ)

# Parser and lexer targets
$(PARSER)/parser.tab.cpp $(PARSER)/parser.tab.hpp: $(PARSER)/parser.y
	bison -d --debug -o $(PARSER)/parser.tab.cpp $(PARSER)/parser.y

$(LEXER)/lexer.cpp: $(LEXER)/lexer.l
	flex -o $(LEXER)/lexer.cpp $(LEXER)/lexer.l

# Object files for native build
$(OBJ)/parser.tab.o: $(PARSER)/parser.tab.cpp $(PARSER)/parser.tab.hpp | obj
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OBJ)/lexer.o: $(LEXER)/lexer.cpp | obj
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OBJ)/ast.o: $(AST)/ast.cpp | obj
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OBJ)/main.o: $(MAIN)/main.cpp | obj
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OBJ)/error.o: $(ERROR)/error.cpp | obj
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OBJ)/helper.o: $(HELPER)/helper.cpp | obj
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OBJ)/time.o: $(TIME)/time.cpp | obj
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OBJ)/timeError.o: $(TIME)/timeError.cpp | obj
	$(CXX) $(CXXFLAGS) -c -o $@ $<

$(OBJ)/errorMessage.o: $(ERRORMSG)/errorMessage.cpp | obj
	$(CXX) $(CXXFLAGS) -c -o $@ $<

# Windows object files
$(WIN_OBJ)/parser.tab.o: $(PARSER)/parser.tab.cpp $(PARSER)/parser.tab.hpp | win_obj
	$(WINDOWS_CXX) $(WINDOWS_CXXFLAGS) -c -o $@ $<

$(WIN_OBJ)/lexer.o: $(LEXER)/lexer.cpp | win_obj
	$(WINDOWS_CXX) $(WINDOWS_CXXFLAGS) -c -o $@ $<

$(WIN_OBJ)/ast.o: $(AST)/ast.cpp | win_obj
	$(WINDOWS_CXX) $(WINDOWS_CXXFLAGS) -c -o $@ $<

$(WIN_OBJ)/main.o: $(MAIN)/main.cpp | win_obj
	$(WINDOWS_CXX) $(WINDOWS_CXXFLAGS) -c -o $@ $<

$(WIN_OBJ)/error.o: $(ERROR)/error.cpp | win_obj
	$(WINDOWS_CXX) $(WINDOWS_CXXFLAGS) -c -o $@ $<

$(WIN_OBJ)/helper.o: $(HELPER)/helper.cpp | win_obj
	$(WINDOWS_CXX) $(WINDOWS_CXXFLAGS) -c -o $@ $<

$(WIN_OBJ)/time.o: $(TIME)/time.cpp | win_obj
	$(WINDOWS_CXX) $(WINDOWS_CXXFLAGS) -c -o $@ $<

$(WIN_OBJ)/timeError.o: $(TIME)/timeError.cpp | win_obj
	$(WINDOWS_CXX) $(WINDOWS_CXXFLAGS) -c -o $@ $<

$(WIN_OBJ)/errorMessage.o: $(ERRORMSG)/errorMessage.cpp | win_obj
	$(WINDOWS_CXX) $(WINDOWS_CXXFLAGS) -c -o $@ $<

# Link all object files to create the native executable
w: $(OBJ_FILES)
	$(CXX) $(CXXFLAGS) -o $@ $(OBJ_FILES)

# Target for cross-compiling to Windows
windows: win_obj $(WIN_OBJ_FILES)
	$(WINDOWS_CXX) $(CXXFLAGS) -o w.exe $(WIN_OBJ_FILES)

clean:
	rm -f $(OBJ)/*.o $(WIN_OBJ)/*.o w w.exe

run: w
	./w chad.w -p