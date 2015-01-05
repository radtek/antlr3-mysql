all: 
	gcc -c -o MySQLLexer.o MySQLLexer.c -I./include -L./lib -lantlr3c
	gcc -c -o MySQLParser.o MySQLParser.c -I./include -L./lib -lantlr3c
	ar -r libtoken.a MySQLParser.o MySQLLexer.o
	gcc -o main main.c  -I./include -I. -L. -ltoken -L./lib -lantlr3c

clean:
	rm -rf *.o *.a
