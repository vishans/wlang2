
all:
	flex -o src/lexer.cpp src/lexer.l  
	bison -d -o src/parser.tab.cpp src/parser.y  
	g++ -c -o obj/parser.tab.o src/parser.tab.cpp
	g++ -c -o obj/lexer.o src/lexer.cpp
	g++ -c -o obj/ast.o src/ast.cpp
	g++ -c -o obj/main.o src/main.cpp
