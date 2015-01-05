#include "MySQLLexer.h"

#include "MySQLParser.h"

int main(int argc, char *argv[])
{
    pANTLR3_INPUT_STREAM input;
    pMySQLLexer lex;
    pANTLR3_COMMON_TOKEN_STREAM tokens;
    pMySQLParser parser;

    input = antlr3AsciiFileStreamNew((pANTLR3_UINT8)argv[1]);
    lex = MySQLLexerNew(input);
    tokens = antlr3CommonTokenStreamSourceNew  (ANTLR3_SIZE_HINT, TOKENSOURCE(lex));
    parser = MySQLParserNew(tokens);

    parser->root_statement(parser);
    
    parser->free(parser);
    tokens->free(tokens);
    lex->free(lex);
    input->close(input);
    return 0;
}
