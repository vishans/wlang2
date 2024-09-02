
all:
	flex -o src/lexer.cpp src/lexer.l  
	bison -d --debug -o src/parser.tab.cpp src/parser.y  
	g++ -c -o obj/parser.tab.o src/parser.tab.cpp
	g++ -c -o obj/lexer.o src/lexer.cpp
	g++ -c -o obj/ast.o src/ast.cpp
	g++ -c -o obj/main.o src/main.cpp
	g++ -c -o obj/error.o src/error.cpp
	g++ -o w obj/parser.tab.o obj/lexer.o obj/ast.o obj/main.o obj/error.o
