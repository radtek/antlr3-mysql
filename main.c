#include "MySQLLexer.h"

#include "MySQLParser.h"

#include <stdio.h>
#include <stdlib.h>

void testParseSQL(char* line);

void testSet() {
    testParseSQL("set @uservar=\"str\"");
    testParseSQL("set @@global.sysvar=123");
    
    testParseSQL("set global sysvar=123");
    testParseSQL("set session sysvar=123");
    
    
    testParseSQL("set autocommit=1");

    testParseSQL("set character set utf8");
    testParseSQL("set character set 'utf8'");
    testParseSQL("set names 'utf8'");
    testParseSQL("set names utf8");
}

struct my_tests_st
{
    const char *name;
    void       (*function)();
};

static struct my_tests_st my_tests[]= {
    {"testSet", testSet},
    {0, 0}
};

void testParseSQL(char* line) {

    pANTLR3_INPUT_STREAM input;
    pMySQLLexer lex;
    pANTLR3_COMMON_TOKEN_STREAM tokens;
    pMySQLParser parser;

    input = antlr3NewAsciiStringInPlaceStream((pANTLR3_UINT8) line, (ANTLR3_UINT32) strlen(line), (pANTLR3_UINT8) line);

    lex = MySQLLexerNew(input);
    tokens = antlr3CommonTokenStreamSourceNew  (ANTLR3_SIZE_HINT, TOKENSOURCE(lex));
    parser = MySQLParserNew(tokens);

    parser->root_statement(parser);
    
    parser->free(parser);
    tokens->free(tokens);
    lex->free(lex);
    input->close(input);
}

int main(int argc, char *argv[])
{

    int i = 0;
    while (my_tests[i].function != NULL) {
        my_tests[i].function();
        ++i;
    }
    return 0;
}
