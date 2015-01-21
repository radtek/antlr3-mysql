cmake_minimum_required(VERSION 2.8)

# Generate the parser files during configure
message("Generating mysql.parser files...")
execute_process(COMMAND "${CMAKE_CURRENT_SOURCE_DIR}/build-parser"
                WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}" RESULT_VARIABLE res_var 
)

if(NOT "${res_var}" STREQUAL "0")
  message(FATAL_ERROR "Generating mysql.parser files failed with result='${res_var}'")
endif()

# Update the parser files when needed
add_custom_target(generate_parser
                  ALL
                  "${CMAKE_CURRENT_SOURCE_DIR}/build-parser"
                  WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
                  COMMENT "Checking if we should regenerate mysql.parser files..."
)

add_definitions(-Wno-sign-compare -Wno-type-limits -Wno-unused
-Wno-missing-field-initializers)

include_directories(.
    ${ANTLR3C_INCLUDE_DIRS}
    ${GTK2_INCLUDE_DIRS}
)

add_library(mysqlparser
    MySQLLexer.c
    MySQLParser.c
    MySQLSimpleParser.c
    mysql-parser.cpp
    mysql-parser-common.cpp
    mysql-scanner.cpp
    mysql-syntax-check.cpp
    file_functions.cpp
    string_utilities.cpp
    log.cpp
    file_utilities.cpp
)

add_dependencies(mysqlparser
    antlr-wb
)

if (SKIP_BUNDLED_ANTLR)
else ()
    link_directories(${PROJECT_BINARY_DIR}/antlr-wb)
endif ()

target_link_libraries(mysqlparser ${ANTLR3C_LIBRARIES} ${GLIB_LIBRARIES})

install(TARGETS mysqlparser DESTINATION ${INSTALL_LIB_DIR})

install(DIRECTORY ${PROJECT_BINARY_DIR}/antlr-wb/ DESTINATION ${INSTALL_LIB_DIR} )
