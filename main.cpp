#include "mysql-syntax-check.h"
#include "mysql-parser-common.h"

#include <stdio.h>
#include <stdlib.h>

#include <set>
#include <string>
#include <iostream>

void testParseSQL(const char* line);

void testSet() {
//    testParseSQL("set @uservar=\"str\"");
//    testParseSQL("set @@global.sysvar=123");

//    testParseSQL("set @@sysvar = 123");
    
    testParseSQL(std::string("SET GLOBAL sysvar = 123; ").c_str());
    testParseSQL("SET SESSION sysvar = 123;");
    
    
    testParseSQL("set autocommit=1;");

    testParseSQL("SET CHARACTER SET utf8");
    testParseSQL("set character set 'utf8'");
    testParseSQL("set names 'utf8'");
    testParseSQL("set names utf8");
}

void testSelect() {
    testParseSQL("select * from db.table;");
}

void testAlert() {
    testParseSQL("alter database dbname UPGRADE DATA DIRECTORY NAME");
}

struct my_tests_st
{
    const char *name;
    void       (*function)();
};

static struct my_tests_st my_tests[]= {
    {"testSet", testSet},
    {"testSelect", testSelect},
    {"testAlert", testAlert},
    {0, 0}
};

std::set<std::string> charset ;

void testParseSQL(const char* line) {
    MySQLSyntaxChecker* reg = new MySQLSyntaxChecker(50600, std::string("STRICT_TRANS_TABLES"), charset);

    reg->parse(line, strlen(line), false, QtUnknown);
    // std::cout << reg->dump_tree();

    delete reg;
}


int main(int argc, char *argv[])
{

    charset.insert("utf8");
    int i = 0;
    while (my_tests[i].function != NULL) {
        my_tests[i].function();
        ++i;
    }
    return 0;
}
