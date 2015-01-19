PROJECT (MySQL)
SET(SRC_LIST MySQL_AdminStatement.c  MySQL_Function.c    MySQL_ShowStatement.c MySQL_Charset.c         MySQL_Identifier.c  MySQL_TransactionStatement.c MySQL_DDLStatement.c    MySQLLexer.c        MySQL_UtilityStatement.c MySQL_DMLStatement.c    MySQL_Literal.c MySQL_Expression.c      MySQLParser.c)

SET(LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/lib)

INCLUDE_DIRECTORIES(.)
ADD_LIBRARY(mysql STATIC ${SRC_LIST})
