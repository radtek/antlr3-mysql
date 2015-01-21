grammar MySQL;

/*
 * Copyright (c) 2012, 2014, Oracle and/or its affiliates. All rights reserved.
 *
 * This program is free software; you can redistribute it and/or
 * modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; version 2 of the
 * License.
 * 
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA
 * 02110-1301  USA
 */

/*
 * Merged in all changes up to mysql-trunk rev. 8454.
 *
 * MySQL grammar for ANTLR 3.4 with language features from MySQL 4.0 up to MySQL 5.7 (except for
 * internal function names which were reduced significantly in 5.1, we only use the reduced set).
 * The server version in the generated parser can be switched at runtime, making it so possible
 * to switch the supported feature set dynamically.
 *
 * This grammar has completely been written from scratch. The MySQL server grammar file (sql_yacc.y)
 * was constantly consulted to ensure conformity, however.
 * The coverage of the MySQL language should be 100%, but there might still be bugs or omissions.
 *
 * This grammar assumes that the lexer/input stream is set to ignore casing, so we can simplify
 * keyword definition here and make the parser smaller (and faster). The code target is plain C
 * and requires a number of functions to be implemented by the user of the parser. These are:
 * 
 *  ANTLR3_UINT32 check_charset(void *payload, pANTLR3_STRING text);
 *  ANTLR3_UINT32 check_null(pANTLR3_STRING text);
 *  void on_parse_error(struct ANTLR3_BASE_RECOGNIZER_struct *recognizer, pANTLR3_UINT8 *tokenNames);
 *
 * See descriptions below for their meaning. Here's a typical setup and run of lexer and parser:
 *
 *   _input = antlr3StringStreamNew((pANTLR3_UINT8)_text, _input_encoding, _text_length, (pANTLR3_UINT8)"mysql-script");
 *   _input->setUcaseLA(_input, ANTLR3_TRUE); // Make input case-insensitive. String literals must all be upper case in the grammar!
 *
 *   _lexer = MySQLLexerNew(_input);
 *   _lexer->pLexer->rec->state->userp = &_context;
 *   _tokens = antlr3CommonTokenStreamSourceNew(ANTLR3_SIZE_HINT, TOKENSOURCE(_lexer));
 *   _parser = MySQLParserNew(_tokens);
 *   _parser->pParser->rec->state->userp = &_context;
 *
 *   _ast = _parser->query(_parser);
 *
 *   ANTLR3_UINT32 error_count = _parser->pParser->rec->getNumberOfSyntaxErrors(_parser->pParser->rec);
 *   if (error_count > 0)
 *     log_debug3("%i errors found\n", error_count);
 *
 *
 * Written by Mike Lischke. Direct all bug reports, omissions etc. to mike.lischke@oracle.com.
 */

//-------------------------------------------------------------------------------------------------

options {
  tokenVocab = predefined; // A set of tokens with ids that aid searching in ranges (e.g. for keywords allowed as identifier).
  language = C;
  output = AST;
  ASTLabelType = pANTLR3_BASE_TREE;
  k = 2;  // Leave it at that. Two tokens lookahead is the minimum. Higher values increase the parser size significantly.
}

tokens {
	SELECT_EXPR_TOKEN;
	SUBQUERY_TOKEN;
	JOIN_EXPR_TOKEN;
	INDEX_HINT_LIST_TOKEN;
	VERSION_COMMENT_START_TOKEN;
	STRING_TOKEN; // Several consecutive single or double quoted text tokens (can even be mixed).

	SCHEMA_NAME_TOKEN;
	TABLE_NAME_TOKEN;
	FIELD_NAME_TOKEN;
	VIEW_NAME_TOKEN;
	TRIGGER_NAME_TOKEN;
	PROCEDURE_NAME_TOKEN;
	FUNCTION_NAME_TOKEN;
	TABLESPACE_NAME_TOKEN;
	LOGFILE_GROUP_NAME_TOKEN;
	UDF_NAME_TOKEN;
	XA_ID_TOKEN;
	
	// Subparts of more complex statements.
	ALTER_TABLE_ITEM_TOKEN;
	COLUMN_ASSIGNMENT_LIST_TOKEN;
	LOGFILE_GROUP_OPTIONS_TOKEN;
	CHANGE_MASTER_OPTIONS_TOKEN;
	SLAVE_THREAD_OPTIONS_TOKEN;
	PRIVILEGE_TARGET_TOKEN;
	KEY_CACHE_LIST_TOKEN;
	KEY_CACHE_PARTITION_TOKEN;
	LABEL_TOKEN;
	DATA_TYPE_TOKEN;

	// Tokens for expressions.
	EXPRESSION_TOKEN;
	PAR_EXPRESSION_TOKEN;
	FUNCTION_CALL_TOKEN;
	
	// Tokens for complexer optional subparts.
	ROUTINE_CREATE_OPTIONS;
	ROUTINE_ALTER_OPTIONS;
}

//-------------------------------------------------------------------------------------------------

@lexer::includes {

// This structure carries important values that are needed to make the lexer + parser work properly, as they
// provide context information. The code which creates parser and lexer must set a reference to such a structure
// initialized to the proper values in the shared lexer/parser state userp member.
typedef struct {
	long version;
	unsigned sql_mode; // A collection of flags indicating which of relevant SQL modes are active.
	void *payload;     // Since we use the usercp for this struct we need another way to pass around other arbitrary data.
} RecognitionContext;

// SQL modes that control parsing behavior.
#define SQL_MODE_ANSI_QUOTES            1
#define SQL_MODE_HIGH_NOT_PRECEDENCE    2
#define SQL_MODE_PIPES_AS_CONCAT        4
#define SQL_MODE_IGNORE_SPACE           8
#define SQL_MODE_NO_BACKSLASH_ESCAPES  16

#define PAYLOAD ((RecognitionContext*)RECOGNIZER->state->userp)->payload
#define SERVER_VERSION ((RecognitionContext*)RECOGNIZER->state->userp)->version
#define TYPE_FROM_VERSION(version, type) (SERVER_VERSION >= version ? type : IDENTIFIER)
#define DEPRECATED_TYPE_FROM_VERSION(version, type) (SERVER_VERSION < version ? type : IDENTIFIER)
#define SQL_MODE_ACTIVE(mode) (((RecognitionContext*)RECOGNIZER->state->userp)->sql_mode & mode) != 0

}

@lexer::header {

#define ANTLR3_HUGE
#ifndef _WIN32
// Usually suppressing such warnings is wrong, but here we got to do with generated code,
// so it's ok for this specific case.
#pragma GCC diagnostic ignored "-Wunused-variable"
#pragma GCC diagnostic ignored "-Wparentheses"
#ifdef __APPLE__
// Comparison of unsigned expression >= 0 is always true.
#pragma GCC diagnostic ignored "-Wtautological-compare"
#else
#if __GNUC__ > 4 || (__GNUC__ == 4 && __GNUC_MINOR__ > 6 )
#pragma GCC diagnostic ignored "-Wtype-limits"
#endif
#endif
#else
#pragma warning(disable:4296) // Condition is always true.
#endif

}

@parser::header {

#define ANTLR3_HUGE
#ifndef _WIN32
#pragma GCC diagnostic ignored "-Wunused-variable"
#pragma GCC diagnostic ignored "-Wparentheses"
#ifdef __APPLE__
// Comparison of unsigned expression >= 0 is always true.
#pragma GCC diagnostic ignored "-Wtautological-compare"
#else
#if __GNUC__ > 4 || (__GNUC__ == 4 && __GNUC_MINOR__ > 6 )
#pragma GCC diagnostic ignored "-Wtype-limits"
#endif
#endif
#endif

#include "MySQLLexer.h" // Not automatically included by the generator.
}

@lexer::postinclude {
#ifdef __cplusplus
extern "C" { 
#endif

  // Custom error reporting function.
  void on_parse_error(struct ANTLR3_BASE_RECOGNIZER_struct *recognizer, pANTLR3_UINT8 *tokenNames); 

  // Checks if the given text corresponds to a charset defined in the server (text is preceded by an underscore).
  // Returns UNDERSCORE_CHARSET if so, otherwise IDENTIFIER.
  ANTLR3_UINT32 check_charset(void *payload, pANTLR3_STRING text);
  
  // Checks the given text if it is equal to "\N" (w/o quotes and in uppercase). We need this extra
  // check as our lexer is case insensitive.
  ANTLR3_UINT32 check_null(pANTLR3_STRING text);
  
  // Checks if the given text is a keyword that is allowed as identifier too (includes sp label keywords).
  ANTLR3_BOOLEAN is_keyword(pANTLR3_STRING text);

#ifdef __cplusplus
};
#endif
}

@lexer::members {
  ANTLR3_BOOLEAN matched_version = ANTLR3_FALSE; // True if a given version number is less than that of the server.
  ANTLR3_BOOLEAN in_version_comment = ANTLR3_FALSE; // True if we are in a version comment (/*!12345 ... */).

  // Checks if the version number, given by the token, is less than or equal to the current server version.
  // Returns ANTRL3_TRUE if so, otherwise ANTLR3_FALSE.
  ANTLR3_BOOLEAN check_version_token(long server_version, pANTLR3_COMMON_TOKEN token)
  {
    pANTLR3_STRING text = token->getText(token);
    long version = strtoul((const char*)text->chars, NULL, 10);
    return version <= server_version ? ANTLR3_TRUE : ANTLR3_FALSE;
  }

  // Called when a keyword was consumed that represents an internal MySQL function and checks if that
  // keyword is followed by an open parenthesis. If not then it is not considered a keyword but
  // treated like a normal identifier.
  ANTLR3_UINT32 determine_function(pMySQLLexer ctx, ANTLR3_UINT32 proposed)
  {
    // Skip any whitespace character if the sql mode says they should be ignored,
    // before actually trying to match the open parenthesis.
    if (SQL_MODE_ACTIVE(SQL_MODE_IGNORE_SPACE))
    {
      int input = LA(1);
      while ((((input >= '\t') && (input <= '\n')) || (input >= '\f') && (input <= '\r')) || input == ' ' )
      {
        CONSUME();
        LEXSTATE->channel = HIDDEN;
        LEXSTATE->type = WS;
        
        input = LA(1);
      }
    }
    
    return LA(1) == '(' ? proposed : IDENTIFIER;
  }
}

@lexer::apifuncs
{
	// Install custom error collector for the front end.
	RECOGNIZER->displayRecognitionError = on_parse_error;
}

@parser::postinclude {
#ifdef __cplusplus
extern "C" { 
#endif

  // Custom error reporting function.
  void on_parse_error(struct ANTLR3_BASE_RECOGNIZER_struct *recognizer, pANTLR3_UINT8 *tokenNames); 

#ifdef __cplusplus
};
#endif
}

@parser::members {
  // Skips over any open parenthesis to see what comes next after them. If that is a SELECT then we are in a subquery.
  static ANTLR3_BOOLEAN is_subquery(pMySQLParser ctx)
  {
    int input = LA(1);
    int k = 2;
    while (input == OPEN_PAR_SYMBOL)
      input = LA(k++);
    return input == SELECT_SYMBOL ? ANTLR3_TRUE : ANTLR3_FALSE;
  }
}

@parser::apifuncs
{
	// Install custom error collector for the front end.
	RECOGNIZER->displayRecognitionError = on_parse_error;
}

//-------------------------------------------------------------------------------------------------

query:
	(statement SEMICOLON_SYMBOL?)? EOF
;

statement:
	// DDL
	alter_statement
	| create_statement
	| drop_statement
	| rename_table_statement
	| truncate_table_statement
	
	// DML
	| call_statement
	| delete_statement
	| do_statement
	| handler_statement
	| insert_statement
	| load_statement
	| replace_statement
	| select_statement
	| update_statement

	| partitioning // Cannot be used standalone.
		
	| transaction_or_locking_statement
	
	| replication_statement
	
	| prepared_statement
	
	// Database administration
	| account_management_statement
	| table_administration_statement
	| install_uninstall_statment
	| {LA(1) == SET_SYMBOL && LA(2) != PASSWORD_SYMBOL}? set_statement // SET PASSWORD is handled in account_management_statement.
	| show_statement
	| miscellaneous_statement
	
	// MySQL utilitity statements
	| utility_statement
;

//----------------- DDL statements -----------------------------------------------------------------

alter_statement:
  ALTER_SYMBOL^
  (
	alter_database
	| alter_log_file_group
	| FUNCTION_SYMBOL function_identifier routine_alter_options?
	| PROCEDURE_SYMBOL procedure_identifier routine_alter_options?
	| alter_server
	| alter_table
	| alter_tablespace
	| {SERVER_VERSION >= 50100}? => alter_event
	| alter_view
  )
;

alter_database:
	DATABASE_SYMBOL
	(
		identifier? database_option+
		| identifier UPGRADE_SYMBOL DATA_SYMBOL DIRECTORY_SYMBOL NAME_SYMBOL
	)
;

alter_event:
	definer_clause?
		EVENT_SYMBOL identifier
		(ON_SYMBOL SCHEDULE_SYMBOL schedule)?
		(ON_SYMBOL COMPLETION_SYMBOL NOT_SYMBOL? PRESERVE_SYMBOL)?
		(RENAME_SYMBOL TO_SYMBOL identifier)?
		(ENABLE_SYMBOL | DISABLE_SYMBOL (ON_SYMBOL SLAVE_SYMBOL)?)?
		(COMMENT_SYMBOL string_literal)?
		(DO_SYMBOL compound_statement)?
;

alter_log_file_group:
	LOGFILE_SYMBOL GROUP_SYMBOL identifier ADD_SYMBOL UNDOFILE_SYMBOL string_literal
		(INITIAL_SIZE_SYMBOL EQUAL_OPERATOR? size_number)? WAIT_SYMBOL? ENGINE_SYMBOL EQUAL_OPERATOR? IDENTIFIER
;

alter_server:
	SERVER_SYMBOL text_or_identifier server_options
;

alter_table:
	online_option? IGNORE_SYMBOL? TABLE_SYMBOL table_identifier alter_table_commands?
;

alter_table_commands:
	DISCARD_SYMBOL TABLESPACE_SYMBOL
	| IMPORT_SYMBOL TABLESPACE_SYMBOL
	| alter_table_list_item (COMMA_SYMBOL alter_table_list_item)* (partitioning? | remove_partitioning)
	| remove_partitioning
	| partitioning
	| {SERVER_VERSION >= 50100}? => alter_partition
;

alter_table_list_item:
	alter_table_list_entry -> ^(ALTER_TABLE_ITEM_TOKEN alter_table_list_entry)
;

alter_table_list_entry:
	alter_table_options
	| ADD_SYMBOL COLUMN_SYMBOL?
		(
			column_definition (FIRST_SYMBOL | AFTER_SYMBOL identifier)?
			| OPEN_PAR_SYMBOL column_definition (COMMA_SYMBOL column_definition)* CLOSE_PAR_SYMBOL
		)
	| ADD_SYMBOL (INDEX_SYMBOL | KEY_SYMBOL) identifier? index_type? index_columns index_option*
	| ADD_SYMBOL (CONSTRAINT_SYMBOL identifier?)?
		(
			PRIMARY_SYMBOL KEY_SYMBOL index_type? index_columns index_option*
			| UNIQUE_SYMBOL (INDEX_SYMBOL | KEY_SYMBOL)? identifier? index_type? index_columns index_option*
			| FOREIGN_SYMBOL KEY_SYMBOL identifier? index_columns reference_definition
		)
	| ADD_SYMBOL FULLTEXT_SYMBOL (INDEX_SYMBOL | KEY_SYMBOL)? identifier? index_columns index_option*
	| ADD_SYMBOL SPATIAL_SYMBOL (INDEX_SYMBOL | KEY_SYMBOL)? identifier? index_columns index_option*
	| ALTER_SYMBOL COLUMN_SYMBOL? identifier (SET_SYMBOL DEFAULT_SYMBOL signed_literal | DROP_SYMBOL DEFAULT_SYMBOL)
	| CHANGE_SYMBOL COLUMN_SYMBOL? identifier field_spec (FIRST_SYMBOL | AFTER_SYMBOL identifier)?
	| MODIFY_SYMBOL COLUMN_SYMBOL? identifier field_spec (FIRST_SYMBOL | AFTER_SYMBOL identifier)?
	| DROP_SYMBOL
		(
			(INDEX_SYMBOL | KEY_SYMBOL) field_name
			| COLUMN_SYMBOL? identifier
			| PRIMARY_SYMBOL KEY_SYMBOL
			| FOREIGN_SYMBOL KEY_SYMBOL
				(
					// This part no longer is optional starting with 5.7.
					{SERVER_VERSION >= 50700}? => field_name
					| {SERVER_VERSION < 50700}? => field_name?
				)
		)
	| DISABLE_SYMBOL KEYS_SYMBOL
	| ENABLE_SYMBOL KEYS_SYMBOL
	| RENAME_SYMBOL (TO_SYMBOL | AS_SYMBOL)? table_identifier
	| {SERVER_VERSION >= 50700}? => RENAME_SYMBOL (INDEX_SYMBOL | KEY_SYMBOL) field_name TO_SYMBOL field_name
	| alter_order_by
	| CONVERT_SYMBOL TO_SYMBOL CHAR_SYMBOL SET_SYMBOL charset_name_or_default (COLLATE_SYMBOL collation_name_or_default)?
	| FORCE_SYMBOL
	| {SERVER_VERSION >= 50600}? => alter_algorithm_option
	| {SERVER_VERSION >= 50600}? => alter_lock_option
;

alter_order_by:
	ORDER_SYMBOL BY_SYMBOL identifier direction (options { greedy = true; }: COMMA_SYMBOL identifier direction)*
;

alter_algorithm_option:
	ALGORITHM_SYMBOL EQUAL_OPERATOR? ( DEFAULT_SYMBOL | identifier )
;

alter_lock_option:
	LOCK_SYMBOL EQUAL_OPERATOR? (DEFAULT_SYMBOL | identifier)
;

index_lock_algorithm:
	{SERVER_VERSION >= 50600}? => 
		(
			alter_algorithm_option alter_lock_option?
			| alter_lock_option alter_algorithm_option?
		)
;

alter_partition:
	{LA(1) == ADD_SYMBOL && LA(2) == PARTITION_SYMBOL}? => ADD_SYMBOL PARTITION_SYMBOL no_write_to_bin_log?
		(
			OPEN_PAR_SYMBOL partition_definition CLOSE_PAR_SYMBOL
			| PARTITIONS_SYMBOL INTEGER
		)
	| DROP_SYMBOL PARTITION_SYMBOL identifier_list
	| REBUILD_SYMBOL PARTITION_SYMBOL no_write_to_bin_log? all_or_partition_name_list
	| OPTIMIZE_SYMBOL PARTITION_SYMBOL no_write_to_bin_log? all_or_partition_name_list no_write_to_bin_log? // yes, twice "no write to bin log".
	| ANALYZE_SYMBOL PARTITION_SYMBOL no_write_to_bin_log? all_or_partition_name_list
	| CHECK_SYMBOL PARTITION_SYMBOL all_or_partition_name_list check_option*
	| REPAIR_SYMBOL PARTITION_SYMBOL no_write_to_bin_log? all_or_partition_name_list repair_option*
	| COALESCE_SYMBOL PARTITION_SYMBOL no_write_to_bin_log? INTEGER
	| {SERVER_VERSION >= 50500}? => TRUNCATE_SYMBOL PARTITION_SYMBOL all_or_partition_name_list
	| EXCHANGE_SYMBOL PARTITION_SYMBOL identifier WITH_SYMBOL TABLE_SYMBOL table_identifier
	| REORGANIZE_SYMBOL PARTITION_SYMBOL no_write_to_bin_log? (identifier_list INTO_SYMBOL partition_definitions)?
	| {SERVER_VERSION >= 50704}? => DISCARD_SYMBOL PARTITION_SYMBOL all_or_partition_name_list TABLESPACE_SYMBOL
	| {SERVER_VERSION >= 50704}? => IMPORT_SYMBOL PARTITION_SYMBOL all_or_partition_name_list TABLESPACE_SYMBOL
;

remove_partitioning:
	{SERVER_VERSION >= 50100}? => REMOVE_SYMBOL PARTITIONING_SYMBOL
;

all_or_partition_name_list:
	ALL_SYMBOL
	| identifier_list
;

alter_tablespace:
	TABLESPACE_SYMBOL tablespace_name
	(
		(ADD_SYMBOL | DROP_SYMBOL) DATAFILE_SYMBOL string_literal (alter_tablespace_option (COMMA_SYMBOL? alter_tablespace_option)*)?
		// The alternatives listed below are not documented but appear in the server grammar file.
		| CHANGE_SYMBOL DATAFILE_SYMBOL string_literal (change_tablespace_option (COMMA_SYMBOL? change_tablespace_option)*)?
		| READ_ONLY_SYMBOL
		| READ_WRITE_SYMBOL
		| NOT_SYMBOL ACCESSIBLE_SYMBOL
	)
;

alter_tablespace_option:
	INITIAL_SIZE_SYMBOL EQUAL_OPERATOR? size_number
	| AUTOEXTEND_SIZE_SYMBOL EQUAL_OPERATOR? size_number
	| MAX_SIZE_SYMBOL EQUAL_OPERATOR? size_number
	| STORAGE_SYMBOL? ENGINE_SYMBOL EQUAL_OPERATOR? text_or_identifier
	| (WAIT_SYMBOL | NO_WAIT_SYMBOL)
;

change_tablespace_option:
	INITIAL_SIZE_SYMBOL EQUAL_OPERATOR? size_number
	| AUTOEXTEND_SIZE_SYMBOL EQUAL_OPERATOR? size_number
	| MAX_SIZE_SYMBOL EQUAL_OPERATOR? size_number
;

alter_view:
	(ALGORITHM_SYMBOL EQUAL_OPERATOR (UNDEFINED_SYMBOL | MERGE_SYMBOL | TEMPTABLE_SYMBOL))?
		definer_clause?
		(SQL_SYMBOL SECURITY_SYMBOL (DEFINER_SYMBOL | INVOKER_SYMBOL))?
		VIEW_SYMBOL view_identifier identifier_list_with_parentheses? AS_SYMBOL select_statement
		(WITH_SYMBOL (CASCADED_SYMBOL | LOCAL_SYMBOL)? CHECK_SYMBOL OPTION_SYMBOL)?
;

//--------------------------------------------------------------------------------------------------

// This is an optimized collector rule for all create statements so that we don't have disambiguities.
// In addition we have rules not referenced anywhere to parse individual create statements. These are used
// in object editors when parsing create statements only.
create_statement:
	CREATE_SYMBOL^
	(
		create_table_tail
		| create_index_tail
		| create_database_tail
		| definer_clause?
			(
				{SERVER_VERSION >= 50100}? => create_event_tail
				| create_view_tail
				| create_routine_or_udf
				| create_trigger_tail
			)
		| view_replace_or_algorithm definer_clause? create_view_tail
		| create_logfile_group_tail
		| create_server_tail
		| create_tablespace_tail
	)
;

create_database: // For external use only. Don't reference this in the normal grammar.
	CREATE_SYMBOL^ create_database_tail SEMICOLON_SYMBOL? EOF
;

create_database_tail:
	DATABASE_SYMBOL if_not_exists? identifier database_option*
;

create_with_definer:
	CREATE_SYMBOL^ definer_clause?
;

create_event: // For external use only. Don't reference this in the normal grammar.
	create_with_definer create_event_tail SEMICOLON_SYMBOL? EOF
;

create_event_tail:
	EVENT_SYMBOL if_not_exists? identifier ON_SYMBOL SCHEDULE_SYMBOL schedule
		(ON_SYMBOL COMPLETION_SYMBOL NOT_SYMBOL? PRESERVE_SYMBOL)?
		(ENABLE_SYMBOL | DISABLE_SYMBOL (ON_SYMBOL SLAVE_SYMBOL)?)?
		(COMMENT_SYMBOL string_literal)?
		DO_SYMBOL compound_statement
;

create_routine: // For external use only. Don't reference this in the normal grammar.
	create_with_definer create_routine_or_udf SEMICOLON_SYMBOL? EOF
;

create_procedure: // For external use only. Don't reference this in the normal grammar.
	create_with_definer procedure_body SEMICOLON_SYMBOL? EOF
;

create_function: // For external use only. Don't reference this in the normal grammar.
	create_with_definer function_body SEMICOLON_SYMBOL? EOF
;

create_routine_or_udf:
	procedure_body
	| function_body
;

procedure_body:
	PROCEDURE_SYMBOL procedure_identifier OPEN_PAR_SYMBOL (procedure_parameter (COMMA_SYMBOL procedure_parameter)*)? CLOSE_PAR_SYMBOL
		routine_create_options? compound_statement
;

function_body: // Both built-in functions and UDFs.
	FUNCTION_SYMBOL
	(
		function_identifier OPEN_PAR_SYMBOL (function_parameter (COMMA_SYMBOL function_parameter)*)? CLOSE_PAR_SYMBOL RETURNS_SYMBOL
			data_type routine_create_options? compound_statement
		| udf_tail
	)
	| AGGREGATE_SYMBOL FUNCTION_SYMBOL udf_tail // AGGREGATE is optional and in order to avoid ambiquities we have two udf paths.
;

udf_tail:
	udf_name RETURNS_SYMBOL (STRING_SYMBOL | INT_SYMBOL | REAL_SYMBOL | DECIMAL_SYMBOL) SONAME_SYMBOL string_literal
;

routine_create_options:
	routine_create_option+ -> ^(ROUTINE_CREATE_OPTIONS routine_create_option+)
;
	
routine_create_option:
	routine_option
	| NOT_SYMBOL? DETERMINISTIC_SYMBOL
;

routine_alter_options:
	routine_create_option+ -> ^(ROUTINE_ALTER_OPTIONS routine_create_option+)
;
	
routine_option:
	COMMENT_SYMBOL string_literal
	| LANGUAGE_SYMBOL SQL_SYMBOL
	| NO_SYMBOL SQL_SYMBOL
	| CONTAINS_SYMBOL SQL_SYMBOL
	| READS_SYMBOL SQL_SYMBOL DATA_SYMBOL
	| MODIFIES_SYMBOL SQL_SYMBOL DATA_SYMBOL
	| SQL_SYMBOL SECURITY_SYMBOL (DEFINER_SYMBOL | INVOKER_SYMBOL)
;

create_index: // For external use only. Don't reference this in the normal grammar.
	CREATE_SYMBOL^ create_index_tail SEMICOLON_SYMBOL? EOF
;

create_index_tail:
	online_option?
	(
		UNIQUE_SYMBOL? INDEX_SYMBOL identifier index_type? create_index_target index_option* index_lock_algorithm?
		| FULLTEXT_SYMBOL INDEX_SYMBOL identifier create_index_target fulltext_index_option* index_lock_algorithm?
		| SPATIAL_SYMBOL INDEX_SYMBOL identifier create_index_target spatial_index_option* index_lock_algorithm?
	)
;

create_index_target:
	ON_SYMBOL^ table_identifier index_columns
;

create_logfile_group: // For external use only. Don't reference this in the normal grammar.
	CREATE_SYMBOL^ create_logfile_group_tail SEMICOLON_SYMBOL? EOF
;

create_logfile_group_tail:
	LOGFILE_SYMBOL GROUP_SYMBOL identifier ADD_SYMBOL (UNDOFILE_SYMBOL | REDOFILE_SYMBOL) string_literal
		logfile_group_options?
;

logfile_group_options:
	(logfile_group_option (COMMA_SYMBOL? logfile_group_option)*)
		-> ^(LOGFILE_GROUP_OPTIONS_TOKEN logfile_group_option (COMMA_SYMBOL? logfile_group_option)*)
;

logfile_group_option:
	INITIAL_SIZE_SYMBOL EQUAL_OPERATOR? size_number
	| (UNDO_BUFFER_SIZE_SYMBOL | REDO_BUFFER_SIZE_SYMBOL) EQUAL_OPERATOR? size_number
	| NODEGROUP_SYMBOL EQUAL_OPERATOR? (INTEGER | HEXNUMBER)
	| (WAIT_SYMBOL | NO_WAIT_SYMBOL)
	| COMMENT_SYMBOL EQUAL_OPERATOR? string_literal
	| STORAGE_SYMBOL? ENGINE_SYMBOL EQUAL_OPERATOR? text_or_identifier
;
	
create_server: // For external use only. Don't reference this in the normal grammar.
	CREATE_SYMBOL^ create_server_tail SEMICOLON_SYMBOL? EOF
;

create_server_tail:
	SERVER_SYMBOL text_or_identifier
		FOREIGN_SYMBOL DATA_SYMBOL WRAPPER_SYMBOL text_or_identifier server_options
;

server_options:
	OPTIONS_SYMBOL^ OPEN_PAR_SYMBOL server_option (COMMA_SYMBOL server_option)* CLOSE_PAR_SYMBOL
;

// Options for CREATE/ALTER SERVER, used for the federated storage engine.
server_option:
	HOST_SYMBOL string_literal
	| DATABASE_SYMBOL string_literal
	| USER_SYMBOL string_literal
	| PASSWORD_SYMBOL string_literal
	| SOCKET_SYMBOL string_literal
	| OWNER_SYMBOL string_literal
	| PORT_SYMBOL INTEGER
;

create_table: // For external use only. Don't reference this in the normal grammar.
	CREATE_SYMBOL^ create_table_tail SEMICOLON_SYMBOL? EOF
;

create_table_tail:
	TEMPORARY_SYMBOL? TABLE_SYMBOL if_not_exists? table_identifier
		(
			OPEN_PAR_SYMBOL
				(
					create_field_list CLOSE_PAR_SYMBOL create_table_options? partitioning? table_creation_source?
					| partitioning create_select CLOSE_PAR_SYMBOL union_clause?
				)
			| create_table_options? partitioning? table_creation_source
			| LIKE_SYMBOL table_identifier
			| OPEN_PAR_SYMBOL LIKE_SYMBOL table_identifier CLOSE_PAR_SYMBOL
		)
;

create_field_list:
	create_field_list_item (COMMA_SYMBOL create_field_list_item)*
;

create_field_list_item:
	column_definition
	| (CONSTRAINT_SYMBOL identifier?)?
		(
			PRIMARY_SYMBOL KEY_SYMBOL index_type? index_columns index_option*
			| FOREIGN_SYMBOL KEY_SYMBOL pure_identifier? index_columns reference_definition
			| UNIQUE_SYMBOL (INDEX_SYMBOL | KEY_SYMBOL)? identifier? index_type? index_columns index_option*
		)
	| (INDEX_SYMBOL | KEY_SYMBOL) identifier? index_type? index_columns index_option*
	| (FULLTEXT_SYMBOL | SPATIAL_SYMBOL) (INDEX_SYMBOL | KEY_SYMBOL)? identifier? index_columns index_option*
	| CHECK_SYMBOL OPEN_PAR_SYMBOL expression CLOSE_PAR_SYMBOL
;

table_creation_source: // create3 in sql_yacc.yy
	(REPLACE_SYMBOL | IGNORE_SYMBOL)? AS_SYMBOL?
	(
		create_select union_clause?
		| OPEN_PAR_SYMBOL create_select CLOSE_PAR_SYMBOL union_or_order_by_or_limit?
	)
;

// The select statement allowed for CREATE TABLE (and certain others) differs from the standard select statement.
create_select:
	SELECT_SYMBOL ( options { greedy = true; }: select_option)* select_item_list table_expression
;

create_tablespace: // For external use only. Don't reference this in the normal grammar.
	CREATE_SYMBOL^ create_tablespace_tail SEMICOLON_SYMBOL? EOF
;

create_tablespace_tail:
	TABLESPACE_SYMBOL tablespace_name ADD_SYMBOL DATAFILE_SYMBOL string_literal
		(USE_SYMBOL LOGFILE_SYMBOL GROUP_SYMBOL identifier)? (create_tablespace_option (COMMA_SYMBOL? create_tablespace_option)*)?
;

create_tablespace_option:
	INITIAL_SIZE_SYMBOL EQUAL_OPERATOR? size_number
	| AUTOEXTEND_SIZE_SYMBOL EQUAL_OPERATOR? size_number
	| MAX_SIZE_SYMBOL EQUAL_OPERATOR? size_number
	| EXTENT_SIZE_SYMBOL EQUAL_OPERATOR? size_number
	| NODEGROUP_SYMBOL EQUAL_OPERATOR? (INTEGER | HEXNUMBER)
	| STORAGE_SYMBOL? ENGINE_SYMBOL EQUAL_OPERATOR? text_or_identifier
	| (WAIT_SYMBOL | NO_WAIT_SYMBOL)
	| COMMENT_SYMBOL EQUAL_OPERATOR? string_literal
;

create_trigger: // For external use only. Don't reference this in the normal grammar.
	create_with_definer create_trigger_tail SEMICOLON_SYMBOL? EOF
;

create_trigger_tail:
	TRIGGER_SYMBOL trigger_identifier (BEFORE_SYMBOL | AFTER_SYMBOL) (INSERT_SYMBOL | UPDATE_SYMBOL | DELETE_SYMBOL)
		ON_SYMBOL table_identifier FOR_SYMBOL EACH_SYMBOL ROW_SYMBOL trigger_follows_precedes_clause? compound_statement
;

trigger_follows_precedes_clause:
	{SERVER_VERSION >= 50700}? => (FOLLOWS_SYMBOL | PRECEDES_SYMBOL) text_or_identifier // not a trigger reference!
;
	
create_view: // For external use only. Don't reference this in the normal grammar.
	CREATE_SYMBOL^ (OR_SYMBOL REPLACE_SYMBOL)? view_algorithm?  definer_clause? create_view_tail SEMICOLON_SYMBOL? EOF
;

create_view_tail:
	(SQL_SYMBOL SECURITY_SYMBOL (DEFINER_SYMBOL | INVOKER_SYMBOL))?
		VIEW_SYMBOL view_identifier identifier_list_with_parentheses?
		AS_SYMBOL select_statement
		(WITH_SYMBOL (CASCADED_SYMBOL | LOCAL_SYMBOL)? CHECK_SYMBOL OPTION_SYMBOL)?
;

view_replace_or_algorithm:
	OR_SYMBOL REPLACE_SYMBOL view_algorithm?
	| view_algorithm
;

view_algorithm:
	ALGORITHM_SYMBOL EQUAL_OPERATOR (UNDEFINED_SYMBOL | MERGE_SYMBOL | TEMPTABLE_SYMBOL)
;

//--------------------------------------------------------------------------------------------------

drop_statement:
	DROP_SYMBOL^
	(
		DATABASE_SYMBOL if_exists?  identifier
		| {SERVER_VERSION >= 50100}? => EVENT_SYMBOL if_exists? qualified_identifier
		| (FUNCTION_SYMBOL | PROCEDURE_SYMBOL) if_exists? qualified_identifier // UDF, stored procedure and stored function
		| online_option? INDEX_SYMBOL identifier ON_SYMBOL table_identifier index_lock_algorithm?
		| LOGFILE_SYMBOL GROUP_SYMBOL identifier (drop_logfile_group_option (COMMA_SYMBOL? drop_logfile_group_option)*)?
		| SERVER_SYMBOL if_exists? text_or_identifier
		| TEMPORARY_SYMBOL? (TABLE_SYMBOL | TABLES_SYMBOL) if_exists? table_identifier_list (RESTRICT_SYMBOL | CASCADE_SYMBOL)?
		| TABLESPACE_SYMBOL identifier (drop_logfile_group_option (COMMA_SYMBOL? drop_logfile_group_option)*)?
		| TRIGGER_SYMBOL if_exists? qualified_identifier
		| VIEW_SYMBOL if_exists? table_identifier_list (RESTRICT_SYMBOL | CASCADE_SYMBOL)?
	)
;

drop_logfile_group_option:
	(WAIT_SYMBOL | NO_WAIT_SYMBOL)
	| STORAGE_SYMBOL? ENGINE_SYMBOL EQUAL_OPERATOR? text_or_identifier;

//--------------------------------------------------------------------------------------------------

rename_table_statement:
	RENAME_SYMBOL^ (TABLE_SYMBOL | TABLES_SYMBOL)
		table_identifier TO_SYMBOL table_identifier (COMMA_SYMBOL table_identifier TO_SYMBOL table_identifier)*
;
	
//--------------------------------------------------------------------------------------------------

truncate_table_statement:
	TRUNCATE_SYMBOL^ TABLE_SYMBOL? table_identifier
;

//--------------- DML statements -------------------------------------------------------------------

call_statement:
	CALL_SYMBOL^ qualified_identifier (OPEN_PAR_SYMBOL expression_list? CLOSE_PAR_SYMBOL)?
;

delete_statement:
	DELETE_SYMBOL^ ( options { greedy = true; }: delete_option)*
		(
			FROM_SYMBOL
				// Both alternatives can start with identifier DOT, so we either need a predicate (which adds backtracking) or,
				// as we actually do, an extended lookahead.
				( options { k = 4; }:
					table_name_list_with_wildcards USING_SYMBOL table_references where_clause? // Multi table variant 1.
					| table_identifier partition_delete? where_clause? order_by_clause? (LIMIT_SYMBOL limit_option)? // Single table delete.
				)
			|  table_name_list_with_wildcards FROM_SYMBOL table_references where_clause? // Multi table variant 2.
		)
;

partition_delete:
	{SERVER_VERSION >= 50602}? => PARTITION_SYMBOL OPEN_PAR_SYMBOL identifier_list CLOSE_PAR_SYMBOL
;

delete_option:
	LOW_PRIORITY_SYMBOL | QUICK_SYMBOL | IGNORE_SYMBOL
;

table_name_list_with_wildcards:
	target_table_with_optional_wildcard (COMMA_SYMBOL target_table_with_optional_wildcard)*
;

do_statement:
	DO_SYMBOL^ expression_list
;

handler_statement:
	HANDLER_SYMBOL^
	(
		table_identifier OPEN_SYMBOL (AS_SYMBOL? identifier)?
		| identifier CLOSE_SYMBOL
		| identifier READ_SYMBOL
			(
				(FIRST_SYMBOL | NEXT_SYMBOL)
				| identifier
					(
						(FIRST_SYMBOL | NEXT_SYMBOL | PREV_SYMBOL | LAST_SYMBOL)
						| (EQUAL_OPERATOR | LESS_THAN_OPERATOR | GREATER_THAN_OPERATOR | LESS_OR_EQUAL_OPERATOR | GREATER_OR_EQUAL_OPERATOR)
							values
					)
			)
			where_clause? limit_clause?
	)
;

//--------------------------------------------------------------------------------------------------

insert_statement:
	INSERT_SYMBOL^ insert_option? IGNORE_SYMBOL? INTO_SYMBOL? table_identifier use_partition? insert_field_spec duplicate_key_update?
;

insert_option:
	LOW_PRIORITY_SYMBOL
	| DELAYED_SYMBOL		// Only allowed if no select is used. Check in the semantic phase.
	| HIGH_PRIORITY_SYMBOL
;

insert_field_spec:
	(OPEN_PAR_SYMBOL fields? CLOSE_PAR_SYMBOL)? insert_values
	| SET_SYMBOL column_assignment_list_with_default
;

fields:
	insert_identifier (COMMA_SYMBOL insert_identifier)*
;

insert_identifier:
	insert_identifier_ref -> ^(FIELD_NAME_TOKEN insert_identifier_ref)
;

// Extra rule to simplify AST rewriting in insert_identifier.
insert_identifier_ref:
	(identifier DOT_SYMBOL (identifier DOT_SYMBOL)?)? (identifier | MULT_OPERATOR)
;

insert_values:
	(VALUES_SYMBOL | VALUE_SYMBOL) insert_value_list
	| create_select union_clause?
	| OPEN_PAR_SYMBOL create_select CLOSE_PAR_SYMBOL union_or_order_by_or_limit?
;

insert_value_list:
	values (COMMA_SYMBOL values)*
;

// The number of expressions within the parentheses is the same as that of the column list. Check in semantic phase.
values:
	OPEN_PAR_SYMBOL ((expression | DEFAULT_SYMBOL) (COMMA_SYMBOL (expression | DEFAULT_SYMBOL))*)? CLOSE_PAR_SYMBOL
;

duplicate_key_update:
	ON_SYMBOL DUPLICATE_SYMBOL KEY_SYMBOL UPDATE_SYMBOL column_assignment (COMMA_SYMBOL column_assignment)*
;

//--------------------------------------------------------------------------------------------------

load_statement:
	LOAD_SYMBOL^ data_or_xml (LOW_PRIORITY_SYMBOL | CONCURRENT_SYMBOL)? LOCAL_SYMBOL? INFILE_SYMBOL string_literal
		(REPLACE_SYMBOL | IGNORE_SYMBOL)? INTO_SYMBOL TABLE_SYMBOL table_identifier
		use_partition? charset_clause?
		xml_rows_identified_by?
		fields_clause? lines_clause?
		load_data_file_tail
;

data_or_xml:
	DATA_SYMBOL
	| {SERVER_VERSION >= 50500}? => XML_SYMBOL
;

xml_rows_identified_by:
	{SERVER_VERSION >= 50500}? => ROWS_SYMBOL IDENTIFIED_SYMBOL BY_SYMBOL string_literal
;

load_data_file_tail:
	(IGNORE_SYMBOL INTEGER (LINES_SYMBOL | ROWS_SYMBOL))? load_data_file_target_list? (SET_SYMBOL column_assignment_list_with_default)?
;

load_data_file_target_list:
	OPEN_PAR_SYMBOL field_or_variable_list? CLOSE_PAR_SYMBOL
;

field_or_variable_list:
	(field_name | user_variable) (COMMA_SYMBOL (field_name | user_variable))*
;

//--------------------------------------------------------------------------------------------------

replace_statement:
	REPLACE_SYMBOL^ (LOW_PRIORITY_SYMBOL | DELAYED_SYMBOL)? INTO_SYMBOL? table_identifier
		use_partition? insert_field_spec
;

//--------------------------------------------------------------------------------------------------

select_statement:
	SELECT_SYMBOL^ select_part2 union_clause?
	| OPEN_PAR_SYMBOL select_paren CLOSE_PAR_SYMBOL union_or_order_by_or_limit?
;

select_paren:
	SELECT_SYMBOL^ select_part2
	| OPEN_PAR_SYMBOL select_paren CLOSE_PAR_SYMBOL
;

select_part2: // This is an optimized variant of the same rule form sql_yacc.yy.
	( options { greedy = true; }: select_option)* select_item_list select_source_and_options? select_lock_type?
;

table_expression:
	( options { greedy = true; }: from_clause)?
	( options { greedy = true; }: where_clause)?
	( options { greedy = true; }: group_by_clause)?
	( options { greedy = true; }: having_clause)?
	( options { greedy = true; }: order_by_clause)?
	( options { greedy = true; }: limit_clause)?
	( options { greedy = true; }: procedure_analyse_clause)?
	( options { greedy = true; }: select_lock_type)?
;

subquery: // subselect in sql_yacc.yy, this is always wrapped by parentheses so I moved them into this rule.
	OPEN_PAR_SYMBOL query_expression_body CLOSE_PAR_SYMBOL
		-> ^(SUBQUERY_TOKEN OPEN_PAR_SYMBOL query_expression_body CLOSE_PAR_SYMBOL)
;

query_expression_body:
	query_specification (UNION_SYMBOL union_option query_specification)*
;

select_part2_derived: // select_part2 equivalent for sub queries.
	( options { greedy = true; }:
		query_spec_option
		| {SERVER_VERSION <= 50100}? => (SQL_NO_CACHE_SYMBOL | SQL_CACHE_SYMBOL)
	)* select_item_list
;

select_option:
	query_spec_option
	| SQL_NO_CACHE_SYMBOL
	| SQL_CACHE_SYMBOL
	| {SERVER_VERSION >= 50704}? => MAX_STATEMENT_TIME_SYMBOL EQUAL_OPERATOR number
;

query_spec_option:
	(ALL_SYMBOL | DISTINCT_SYMBOL)
	| STRAIGHT_JOIN_SYMBOL
	| HIGH_PRIORITY_SYMBOL
	| SQL_SMALL_RESULT_SYMBOL
	| SQL_BIG_RESULT_SYMBOL
	| SQL_BUFFER_RESULT_SYMBOL
	| SQL_CALC_FOUND_ROWS_SYMBOL
;

select_item_list:
	(select_item | MULT_OPERATOR) ( options { greedy = true; }: COMMA_SYMBOL select_item)*
;

select_item:
	(qualified_identifier_with_wildcard) => qualified_identifier_with_wildcard -> ^(FIELD_NAME_TOKEN qualified_identifier_with_wildcard)
	| expression select_alias? -> ^(SELECT_EXPR_TOKEN expression select_alias?)
;

select_alias:
	AS_SYMBOL? text_or_identifier
;         

select_source_and_options:
	limit_clause
	| into_clause select_from?
	| select_from into_clause?
;

limit_clause:
	LIMIT_SYMBOL limit_options
;

limit_options:
	limit_option ( options { greedy = true; }: (COMMA_SYMBOL | OFFSET_SYMBOL) limit_option)?
;

limit_option:
	PARAM_MARKER
	| INTEGER
	| identifier // Used in stored programs.
;

into_clause:
	INTO_SYMBOL
	(
		OUTFILE_SYMBOL string_literal charset_clause? fields_clause? lines_clause?
		| DUMPFILE_SYMBOL string_literal
		| AT_SIGN_SYMBOL? text_or_identifier (COMMA_SYMBOL AT_SIGN_SYMBOL? text_or_identifier)*
		| AT_TEXT_SUFFIX (COMMA_SYMBOL AT_TEXT_SUFFIX)*
	)
;

select_from:
	FROM_SYMBOL^
	(
		DUAL_SYMBOL ( options { greedy = true; }: where_clause)? ( options { greedy = true; }: limit_clause)?
		| table_references
			( options { greedy = true; }: where_clause)?
			( options { greedy = true; }: group_by_clause)?
			( options { greedy = true; }: having_clause)?
			( options { greedy = true; }: order_by_clause)?
			( options { greedy = true; }: limit_clause)?
			( options { greedy = true; }: procedure_analyse_clause)?
	)
;

procedure_analyse_clause:
	PROCEDURE_SYMBOL^ ANALYSE_SYMBOL OPEN_PAR_SYMBOL (INTEGER (COMMA_SYMBOL INTEGER)?)? CLOSE_PAR_SYMBOL
;

having_clause:
	HAVING_SYMBOL^ expression
;

group_by_clause:
	GROUP_SYMBOL^ BY_SYMBOL expression_list_with_direction olap_option?
;

olap_option:
	WITH_SYMBOL CUBE_SYMBOL
	| WITH_SYMBOL ROLLUP_SYMBOL
;

order_by_clause:
	ORDER_SYMBOL^ BY_SYMBOL expression_list_with_direction
;

order_by_or_limit:
	order_by_clause limit_clause?
	| limit_clause
;

direction:
	ASC_SYMBOL
	| DESC_SYMBOL
;

from_clause:
	FROM_SYMBOL table_references
;

where_clause:
	WHERE_SYMBOL^ expression
;

table_references: // derived_table_list in sql_yacc.yy
	 escaped_table_reference ( options { greedy = true; }: COMMA_SYMBOL escaped_table_reference)*
;

// For the ODBC OJ syntax we do as the server does. This is what the server grammar says about it:
//   The ODBC escape syntax for Outer Join is: '{' OJ join_table '}'
//   The parser does not define OJ as a token, any ident is accepted
//   instead in $2 (ident). Also, all productions from table_ref can
//   be escaped, not only join_table. Both syntax extensions are safe
//   and are ignored.
escaped_table_reference:
	table_reference
	| OPEN_CURLY_SYMBOL identifier table_reference CLOSE_CURLY_SYMBOL
;

table_reference:
	table_factor ( options { greedy = true; }: join)*
;

join:
	join_table -> ^(JOIN_EXPR_TOKEN join_table)
;

table_factor:
	SELECT_SYMBOL ( options { greedy = true; }: select_option)* select_item_list table_expression
	| OPEN_PAR_SYMBOL select_table_factor_union CLOSE_PAR_SYMBOL table_alias?
	| table_identifier use_partition? table_alias? index_hint_list?
;

table_factor_select_tail:
	select_from ( options { greedy = true; }: select_lock_type)?
	| limit_clause
;

select_table_factor_union:
	(table_references order_by_or_limit?) (UNION_SYMBOL union_option? query_specification)*
;

query_specification:
	SELECT_SYMBOL select_part2_derived table_expression
	| OPEN_PAR_SYMBOL query_specification CLOSE_PAR_SYMBOL order_by_or_limit?
;

join_table:
	(INNER_SYMBOL | CROSS_SYMBOL)? JOIN_SYMBOL table_reference ( options {greedy = true;}: join_condition)?
	| STRAIGHT_JOIN_SYMBOL table_factor ( options {greedy = true;}: ON_SYMBOL expression)?
	| (LEFT_SYMBOL | RIGHT_SYMBOL) OUTER_SYMBOL? JOIN_SYMBOL table_reference join_condition
	| NATURAL_SYMBOL ((LEFT_SYMBOL | RIGHT_SYMBOL) OUTER_SYMBOL?)? JOIN_SYMBOL table_factor
;

join_condition:
	ON_SYMBOL expression
	| USING_SYMBOL identifier_list_with_parentheses
;

union_clause:
  UNION_SYMBOL^ union_option? select_statement
 ;

union_option:
	DISTINCT_SYMBOL
	| ALL_SYMBOL
;

union_or_order_by_or_limit: // union_opt in sql_yacc.yy
	union_clause
	| order_by_or_limit
;

select_lock_type:
	FOR_SYMBOL UPDATE_SYMBOL
	| LOCK_SYMBOL IN_SYMBOL SHARE_SYMBOL MODE_SYMBOL
;

table_alias:
	(AS_SYMBOL | EQUAL_OPERATOR)? identifier
;

index_hint_list:
	index_hint (COMMA_SYMBOL index_hint)* -> ^(INDEX_HINT_LIST_TOKEN index_hint (COMMA_SYMBOL index_hint)*)
;

index_hint:
	index_hint_type key_or_index index_hint_clause? OPEN_PAR_SYMBOL index_list CLOSE_PAR_SYMBOL
	| USE_SYMBOL key_or_index index_hint_clause? OPEN_PAR_SYMBOL index_list? CLOSE_PAR_SYMBOL
;
index_hint_type:
	FORCE_SYMBOL
	| IGNORE_SYMBOL
;

key_or_index:
	KEY_SYMBOL
	| INDEX_SYMBOL
;

index_hint_clause:
	FOR_SYMBOL (JOIN_SYMBOL | ORDER_SYMBOL BY_SYMBOL | GROUP_SYMBOL BY_SYMBOL)
;

index_list:
	index_list_element (COMMA_SYMBOL index_list_element)*
;

index_list_element:
	identifier
	| PRIMARY_SYMBOL
;

//--------------------------------------------------------------------------------------------------

update_statement:
	UPDATE_SYMBOL^ LOW_PRIORITY_SYMBOL? IGNORE_SYMBOL? table_references
		SET_SYMBOL column_assignment_list_with_default where_clause? order_by_clause? limit_clause?
;

//--------------------------------------------------------------------------------------------------

transaction_or_locking_statement:
	transaction_statement
	| savepoint_statement
	| lock_statement
	| xa_statement
;

transaction_statement:
	START_SYMBOL^ TRANSACTION_SYMBOL transaction_characteristic*
	| BEGIN_SYMBOL^ WORK_SYMBOL?
	| COMMIT_SYMBOL^ WORK_SYMBOL? (AND_SYMBOL NO_SYMBOL? CHAIN_SYMBOL)? (NO_SYMBOL? RELEASE_SYMBOL)?
	| ROLLBACK_SYMBOL^ WORK_SYMBOL?
		(
			(AND_SYMBOL NO_SYMBOL? CHAIN_SYMBOL)? (NO_SYMBOL? RELEASE_SYMBOL)?
			| TO_SYMBOL SAVEPOINT_SYMBOL? identifier // Belongs to the savepoint_statement, but this way we don't need a predicate.
		)
	// In order to avoid needing a predicate to solve ambiquity between this and general SET statements with global/session variables the following
	// alternative is moved to the set_statement rule.
	//| SET_SYMBOL option_type? TRANSACTION_SYMBOL set_transaction_characteristic (COMMA_SYMBOL set_transaction_characteristic)*
;

transaction_characteristic:
	WITH_SYMBOL CONSISTENT_SYMBOL SNAPSHOT_SYMBOL
	| {SERVER_VERSION >= 50605}? => READ_SYMBOL (WRITE_SYMBOL | ONLY_SYMBOL)
;

set_transaction_characteristic:
	ISOLATION_SYMBOL LEVEL_SYMBOL isolation_level
	| {SERVER_VERSION >= 50605}? => READ_SYMBOL (WRITE_SYMBOL | ONLY_SYMBOL)
;

isolation_level:
	REPEATABLE_SYMBOL READ_SYMBOL
	| READ_SYMBOL (COMMITTED_SYMBOL | UNCOMMITTED_SYMBOL)
	| SERIALIZABLE_SYMBOL
;

savepoint_statement:
	SAVEPOINT_SYMBOL^ identifier
	| RELEASE_SYMBOL^ SAVEPOINT_SYMBOL identifier
;

lock_statement:
	LOCK_SYMBOL^ (TABLES_SYMBOL | TABLE_SYMBOL) lock_item (COMMA_SYMBOL lock_item)*
	| UNLOCK_SYMBOL^ (TABLES_SYMBOL | TABLE_SYMBOL)
;

lock_item:
	table_identifier table_alias? lock_option
;
lock_option:
	READ_SYMBOL LOCAL_SYMBOL?
	| LOW_PRIORITY_SYMBOL? WRITE_SYMBOL // low priority deprecated since 5.7
;

xa_statement:
	XA_SYMBOL^
		(
			(START_SYMBOL | BEGIN_SYMBOL) xid (JOIN_SYMBOL | RESUME_SYMBOL)?
			| END_SYMBOL xid (SUSPEND_SYMBOL (FOR_SYMBOL MIGRATE_SYMBOL)?)?
			| PREPARE_SYMBOL xid
			| COMMIT_SYMBOL xid (ONE_SYMBOL PHASE_SYMBOL)?
			| ROLLBACK_SYMBOL xid
			| RECOVER_SYMBOL xa_convert?
		)
;

xa_convert:
	{SERVER_VERSION >= 50704}? => CONVERT_SYMBOL XID_SYMBOL
;

xid:
	string_literal (COMMA_SYMBOL string_literal (COMMA_SYMBOL INTEGER)?)?
		-> ^(XA_ID_TOKEN string_literal (COMMA_SYMBOL string_literal (COMMA_SYMBOL INTEGER)?)?)
;

//--------------------------------------------------------------------------------------------------

replication_statement:
	PURGE_SYMBOL^ (BINARY_SYMBOL | MASTER_SYMBOL) LOGS_SYMBOL (TO_SYMBOL string_literal | BEFORE_SYMBOL expression)
	| change_master
	| {SERVER_VERSION >= 50700}? => change_replication
	/* Defined in the miscellaneous statement to avoid ambiguities.
	| RESET_SYMBOL MASTER_SYMBOL
	| RESET_SYMBOL SLAVE_SYMBOL ALL_SYMBOL
	*/
	| start_slave
	| stop_slave
	| {SERVER_VERSION < 50500}? => replication_load
;

replication_load:
	LOAD_SYMBOL^ (DATA_SYMBOL | TABLE_SYMBOL table_identifier) FROM_SYMBOL MASTER_SYMBOL
;

change_master:
	CHANGE_SYMBOL^ MASTER_SYMBOL TO_SYMBOL change_master_options
;

change_master_options:
	master_option (COMMA_SYMBOL master_option)* -> ^(CHANGE_MASTER_OPTIONS_TOKEN master_option (COMMA_SYMBOL master_option)*)
;

master_option:
	MASTER_BIND_SYMBOL EQUAL_OPERATOR string_literal
	| MASTER_HOST_SYMBOL EQUAL_OPERATOR string_literal
	| MASTER_USER_SYMBOL EQUAL_OPERATOR string_literal
	| MASTER_PASSWORD_SYMBOL EQUAL_OPERATOR string_literal
	| MASTER_PORT_SYMBOL EQUAL_OPERATOR INTEGER
	| MASTER_CONNECT_RETRY_SYMBOL EQUAL_OPERATOR INTEGER
	| MASTER_RETRY_COUNT_SYMBOL EQUAL_OPERATOR INTEGER
	| MASTER_DELAY_SYMBOL EQUAL_OPERATOR INTEGER
	| MASTER_HEARTBEAT_PERIOD_SYMBOL EQUAL_OPERATOR INTEGER
	| MASTER_LOG_FILE_SYMBOL EQUAL_OPERATOR string_literal
	| MASTER_LOG_POS_SYMBOL EQUAL_OPERATOR INTEGER
	| MASTER_AUTO_POSITION_SYMBOL EQUAL_OPERATOR INTEGER
	| RELAY_LOG_FILE_SYMBOL EQUAL_OPERATOR string_literal
	| RELAY_LOG_POS_SYMBOL EQUAL_OPERATOR INTEGER
	| MASTER_SSL_SYMBOL EQUAL_OPERATOR INTEGER
	| MASTER_SSL_CA_SYMBOL EQUAL_OPERATOR string_literal
	| MASTER_SSL_CAPATH_SYMBOL EQUAL_OPERATOR string_literal
	| MASTER_SSL_CERT_SYMBOL EQUAL_OPERATOR string_literal
	| MASTER_SSL_CRL_SYMBOL EQUAL_OPERATOR string_literal
	| MASTER_SSL_CRLPATH_SYMBOL EQUAL_OPERATOR string_literal
	| MASTER_SSL_KEY_SYMBOL EQUAL_OPERATOR string_literal
	| MASTER_SSL_CIPHER_SYMBOL EQUAL_OPERATOR string_literal
	| MASTER_SSL_VERIFY_SERVER_CERT_SYMBOL EQUAL_OPERATOR INTEGER
	| IGNORE_SERVER_IDS_SYMBOL EQUAL_OPERATOR server_id_list
;

server_id_list:
	OPEN_PAR_SYMBOL integer_list? CLOSE_PAR_SYMBOL
;

change_replication:
	CHANGE_SYMBOL^ REPLICATION_SYMBOL FILTER_SYMBOL filter_definition (COMMA_SYMBOL filter_definition)*
;

filter_definition:
	REPLICATE_DO_DB_SYMBOL EQUAL_OPERATOR OPEN_PAR_SYMBOL filter_db_list? CLOSE_PAR_SYMBOL
	| REPLICATE_IGNORE_DB_SYMBOL EQUAL_OPERATOR OPEN_PAR_SYMBOL filter_db_list? CLOSE_PAR_SYMBOL
	| REPLICATE_DO_TABLE_SYMBOL EQUAL_OPERATOR OPEN_PAR_SYMBOL filter_table_list? CLOSE_PAR_SYMBOL
	| REPLICATE_IGNORE_TABLE_SYMBOL EQUAL_OPERATOR OPEN_PAR_SYMBOL filter_table_list? CLOSE_PAR_SYMBOL
	| REPLICATE_WILD_DO_TABLE_SYMBOL EQUAL_OPERATOR OPEN_PAR_SYMBOL filter_string_list? CLOSE_PAR_SYMBOL
	| REPLICATE_WILD_IGNORE_TABLE_SYMBOL EQUAL_OPERATOR OPEN_PAR_SYMBOL filter_string_list? CLOSE_PAR_SYMBOL
	| REPLICATE_REWRITE_DB_SYMBOL EQUAL_OPERATOR OPEN_PAR_SYMBOL filter_db_pair_list? CLOSE_PAR_SYMBOL
;

filter_db_list:
	schema_name (COMMA_SYMBOL schema_name)*
;

filter_table_list:
	qualified_table_identifier (COMMA_SYMBOL qualified_table_identifier)*
;

filter_string_list:
	string_literal (COMMA_SYMBOL string_literal)* // In server grammar: text without a line break.
;

filter_db_pair_list:
	schema_identifier_pair (COMMA_SYMBOL schema_identifier_pair)*
;

start_slave:
	START_SYMBOL^ SLAVE_SYMBOL slave_thread_options? (UNTIL_SYMBOL slave_until_options)? slave_connection_options		
;

slave_until_options:
	(
		master_file_def
		| {SERVER_VERSION >= 50606}? => (SQL_BEFORE_GTIDS_SYMBOL | SQL_AFTER_GTIDS_SYMBOL) EQUAL_OPERATOR gtid_set
		| {SERVER_VERSION >= 50606}? => SQL_AFTER_MTS_GAPS_SYMBOL
	)
	(COMMA_SYMBOL master_file_def)*
;

master_file_def:
	MASTER_LOG_FILE_SYMBOL EQUAL_OPERATOR string_literal
	| MASTER_LOG_POS_SYMBOL EQUAL_OPERATOR INTEGER
	| RELAY_LOG_FILE_SYMBOL EQUAL_OPERATOR string_literal
	| RELAY_LOG_POS_SYMBOL EQUAL_OPERATOR INTEGER
;

slave_connection_options:
	{SERVER_VERSION >= 50604}? => (USER_SYMBOL EQUAL_OPERATOR string_literal)? (PASSWORD_SYMBOL EQUAL_OPERATOR string_literal)?
		(DEFAULT_AUTH_SYMBOL EQUAL_OPERATOR string_literal)? (PLUGIN_DIR_SYMBOL EQUAL_OPERATOR string_literal)?
	| // Intentionally left empty for the gated predicate.
;

stop_slave:
	STOP_SYMBOL^ SLAVE_SYMBOL slave_thread_options?
;

slave_thread_options:
	slave_thread_option (COMMA_SYMBOL slave_thread_option)* -> ^(SLAVE_THREAD_OPTIONS_TOKEN slave_thread_option (COMMA_SYMBOL slave_thread_option)*)
;

slave_thread_option:
	RELAY_THREAD_SYMBOL | SQL_THREAD_SYMBOL
;

gtid_set:
	string_literal // uuid:first_transaction_id[-last_transaction_id]
;

//--------------------------------------------------------------------------------------------------

prepared_statement:
	PREPARE_SYMBOL^ identifier FROM_SYMBOL (string_literal | user_variable)
	| execute_statement
	| (DEALLOCATE_SYMBOL | DROP_SYMBOL)^ PREPARE_SYMBOL identifier
;

execute_statement:
	EXECUTE_SYMBOL^ identifier (USING_SYMBOL execute_var_list)?
;

execute_var_list:
	user_variable (COMMA_SYMBOL user_variable)*
;

//--------------------------------------------------------------------------------------------------

account_management_statement:
	{SERVER_VERSION >= 50606}? => alter_user_list
	| create_user
	| drop_user
	| {SERVER_VERSION >= 50500}? => grant_proxy
	| grant
	| rename_user
	| revoke_statement
	| set_password
;

alter_user_list:
	ALTER_SYMBOL^ USER_SYMBOL alter_user (COMMA_SYMBOL alter_user)*
;

alter_user:
	user PASSWORD_SYMBOL EXPIRE_SYMBOL alter_user_expire_interval?
;

alter_user_expire_interval:
	{SERVER_VERSION >= 50704}? => (
		INTERVAL_SYMBOL number DAY_SYMBOL
		| NEVER_SYMBOL
		| DEFAULT_SYMBOL
	)
;

create_user:
	CREATE_SYMBOL^ USER_SYMBOL user_specification
;

drop_user:
	DROP_SYMBOL^ USER_SYMBOL user_list
;

grant:
	GRANT_SYMBOL^ grant_privileges privilege_target
		TO_SYMBOL user_specification (COMMA_SYMBOL user_specification)*
		(REQUIRE_SYMBOL
			(
				NONE_SYMBOL
				| SSL_SYMBOL
				| X509_SYMBOL
				| require_list (AND_SYMBOL? require_list)*
			)
		)?
		(WITH_SYMBOL grant_option+)?
;

grant_proxy:
	GRANT_SYMBOL^ PROXY_SYMBOL ON_SYMBOL user_specification TO_SYMBOL user_specification (COMMA_SYMBOL user_specification)*
		(WITH_SYMBOL GRANT_SYMBOL OPTION_SYMBOL)?
;

rename_user:
	RENAME_SYMBOL^ USER_SYMBOL user TO_SYMBOL user (COMMA_SYMBOL user TO_SYMBOL user)*
;

revoke_statement:
	REVOKE_SYMBOL^
	(
		{LA(1) == ALL_SYMBOL}? => ALL_SYMBOL PRIVILEGES_SYMBOL? COMMA_SYMBOL GRANT_SYMBOL OPTION_SYMBOL FROM_SYMBOL user_list
		| grant_privileges privilege_target FROM_SYMBOL user_list
		| {SERVER_VERSION >= 50500}? => PROXY_SYMBOL ON_SYMBOL user FROM_SYMBOL user_list
	)
;

privilege_target:
	ON_SYMBOL grant_object_type privilege_level -> ^(PRIVILEGE_TARGET_TOKEN ON_SYMBOL grant_object_type privilege_level)
;

set_password:
	SET_SYMBOL^ PASSWORD_SYMBOL (FOR_SYMBOL user)? equal
	(
		PASSWORD_SYMBOL OPEN_PAR_SYMBOL string_literal CLOSE_PAR_SYMBOL
		| OLD_PASSWORD_SYMBOL OPEN_PAR_SYMBOL string_literal CLOSE_PAR_SYMBOL
		| string_literal
	)
;

grant_object_type:
	(TABLE_SYMBOL? | FUNCTION_SYMBOL | PROCEDURE_SYMBOL)
;

grant_privileges:
	ALL_SYMBOL PRIVILEGES_SYMBOL?
	| privilege_type (COMMA_SYMBOL privilege_type)*
;

privilege_type:
	ALTER_SYMBOL ROUTINE_SYMBOL?
	| CREATE_SYMBOL (ROUTINE_SYMBOL | TABLESPACE_SYMBOL | TEMPORARY_SYMBOL TABLES_SYMBOL | USER_SYMBOL | VIEW_SYMBOL)?
	| DELETE_SYMBOL
	| DROP_SYMBOL
	| EVENT_SYMBOL
	| EXECUTE_SYMBOL
	| FILE_SYMBOL
	| GRANT_SYMBOL OPTION_SYMBOL
	| INDEX_SYMBOL
	| INSERT_SYMBOL identifier_list_with_parentheses?
	| LOCK_SYMBOL TABLES_SYMBOL
	| PROCESS_SYMBOL
	| PROXY_SYMBOL
	| REFERENCES_SYMBOL identifier_list_with_parentheses?
	| RELOAD_SYMBOL
	| REPLICATION_SYMBOL (CLIENT_SYMBOL | SLAVE_SYMBOL)
	| SELECT_SYMBOL identifier_list_with_parentheses?
	| SHOW_SYMBOL DATABASES_SYMBOL
	| SHOW_SYMBOL VIEW_SYMBOL
	| SHUTDOWN_SYMBOL
	| SUPER_SYMBOL
	| TRIGGER_SYMBOL
	| UPDATE_SYMBOL identifier_list_with_parentheses?
	| USAGE_SYMBOL
;

privilege_level:
	MULT_OPERATOR (DOT_SYMBOL MULT_OPERATOR)?
	| identifier (DOT_SYMBOL (MULT_OPERATOR | identifier))?
;

require_list:
	CIPHER_SYMBOL string_literal
	| ISSUER_SYMBOL string_literal
	| SUBJECT_SYMBOL string_literal
;

grant_option:
	GRANT_SYMBOL OPTION_SYMBOL
	| MAX_QUERIES_PER_HOUR_SYMBOL INTEGER
	| MAX_UPDATES_PER_HOUR_SYMBOL INTEGER
	| MAX_CONNECTIONS_PER_HOUR_SYMBOL INTEGER
	| MAX_USER_CONNECTIONS_SYMBOL INTEGER
;

//--------------------------------------------------------------------------------------------------

table_administration_statement:
	ANALYZE_SYMBOL^ no_write_to_bin_log? TABLE_SYMBOL qualified_identifier_list
	| CHECK_SYMBOL^ TABLE_SYMBOL qualified_identifier_list check_option*
	| CHECKSUM_SYMBOL^ TABLE_SYMBOL qualified_identifier_list (QUICK_SYMBOL | EXTENDED_SYMBOL)?
	| OPTIMIZE_SYMBOL^ no_write_to_bin_log? TABLE_SYMBOL qualified_identifier_list
	| REPAIR_SYMBOL^ no_write_to_bin_log? TABLE_SYMBOL qualified_identifier_list repair_option*
	| {SERVER_VERSION < 50500}? => BACKUP_SYMBOL^ TABLE_SYMBOL table_identifier_list TO_SYMBOL string_literal
	| {SERVER_VERSION < 50500}? => RESTORE_SYMBOL^ TABLE_SYMBOL table_identifier_list FROM_SYMBOL string_literal
;

check_option:
	FOR_SYMBOL UPGRADE_SYMBOL | QUICK_SYMBOL | FAST_SYMBOL | MEDIUM_SYMBOL | EXTENDED_SYMBOL | CHANGED_SYMBOL
;

repair_option:
	QUICK_SYMBOL | EXTENDED_SYMBOL | USE_FRM_SYMBOL
;

//--------------------------------------------------------------------------------------------------

install_uninstall_statment:
	INSTALL_SYMBOL^ PLUGIN_SYMBOL identifier SONAME_SYMBOL string_literal
	| UNINSTALL_SYMBOL^ PLUGIN_SYMBOL identifier
;

//--------------------------------------------------------------------------------------------------

set_statement:
	SET_SYMBOL^
		( options { k = 3; }:
			 option_type? TRANSACTION_SYMBOL set_transaction_characteristic
			| ONE_SHOT_SYMBOL? option_value_no_option_type (COMMA_SYMBOL option_value_list)?
			// ONE_SHOT is available only until 5.6. We don't need a predicate here, however. Handling it in the lexer is enough.
			| option_type option_value_following_option_type (COMMA_SYMBOL option_value_list)?
			
			// SET PASSWORD is handled in an own rule.
		)
;

option_value_no_option_type:
	{LA(1) == NAMES_SYMBOL}? NAMES_SYMBOL
		(
			equal expression
			| charset_name_or_default (COLLATE_SYMBOL collation_name_or_default)?
		)
	| variable_name equal set_expression_or_default
	| user_variable equal expression
	| system_variable equal set_expression_or_default
	| charset_clause
;

option_value_following_option_type:
	variable_name equal set_expression_or_default
;
	
set_expression_or_default:
	expression
	| DEFAULT_SYMBOL
	| ON_SYMBOL
	| ALL_SYMBOL
	| BINARY_SYMBOL
;

option_value_list:
	option_value (COMMA_SYMBOL option_value)*
;

option_value:
	option_type variable_name equal set_expression_or_default
	| option_value_no_option_type
;

//--------------------------------------------------------------------------------------------------

show_statement:
	SHOW_SYMBOL^
	(
		{SERVER_VERSION < 50700}? => AUTHORS_SYMBOL
		| BINARY_SYMBOL LOGS_SYMBOL
		| (BINLOG_SYMBOL | RELAYLOG_SYMBOL) EVENTS_SYMBOL (IN_SYMBOL string_literal)? (FROM_SYMBOL INTEGER)? limit_clause?
		| (CHAR_SYMBOL SET_SYMBOL | CHARSET_SYMBOL) like_or_where?
		| COLLATION_SYMBOL like_or_where?
		| FULL_SYMBOL? COLUMNS_SYMBOL (FROM_SYMBOL | IN_SYMBOL) table_identifier in_db? like_or_where?
		| {SERVER_VERSION < 50700}? => CONTRIBUTORS_SYMBOL
		| COUNT_SYMBOL OPEN_PAR_SYMBOL MULT_OPERATOR CLOSE_PAR_SYMBOL (WARNINGS_SYMBOL | ERRORS_SYMBOL)
		| CREATE_SYMBOL (DATABASE_SYMBOL | EVENT_SYMBOL | FUNCTION_SYMBOL | PROCEDURE_SYMBOL | TABLE_SYMBOL | TRIGGER_SYMBOL | VIEW_SYMBOL) qualified_identifier
		| DATABASES_SYMBOL like_clause?
		| ENGINE_SYMBOL text_or_identifier (STATUS_SYMBOL | MUTEX_SYMBOL)
		| STORAGE_SYMBOL? ENGINES_SYMBOL
		| ERRORS_SYMBOL limit_clause?
		| EVENTS_SYMBOL
		| FUNCTION_SYMBOL CODE_SYMBOL qualified_identifier
		| FUNCTION_SYMBOL STATUS_SYMBOL like_or_where?
		| GRANTS_SYMBOL FOR_SYMBOL user
		| (INDEX_SYMBOL | INDEXES_SYMBOL | KEYS_SYMBOL) from_or_in table_identifier in_db? where_clause?
		| {SERVER_VERSION < 50500}? => INNODB_SYMBOL STATUS_SYMBOL // Deprecated in 5.5.
		| MASTER_SYMBOL STATUS_SYMBOL
		| OPEN_SYMBOL TABLES_SYMBOL in_db? like_or_where?
		| {(SERVER_VERSION >= 50105) && (SERVER_VERSION < 50500)}? => PLUGIN_SYMBOL // Supported between 5.1.5 and 5.5.
		| {SERVER_VERSION >= 50500}? => PLUGINS_SYMBOL
		| PROCEDURE_SYMBOL STATUS_SYMBOL like_or_where?
		| PROCEDURE_SYMBOL CODE_SYMBOL qualified_identifier
		| PRIVILEGES_SYMBOL
		| FULL_SYMBOL? PROCESSLIST_SYMBOL
		| PROFILE_SYMBOL (profile_type (COMMA_SYMBOL profile_type)*)? (FOR_SYMBOL QUERY_SYMBOL INTEGER)? limit_clause?
		| PROFILES_SYMBOL
		| SLAVE_SYMBOL
			(
				HOSTS_SYMBOL
				| STATUS_SYMBOL non_blocking?
			)
		| option_type? (STATUS_SYMBOL | VARIABLES_SYMBOL) like_or_where?
		| TABLE_SYMBOL STATUS_SYMBOL in_db? like_or_where?
		| FULL_SYMBOL? TABLES_SYMBOL in_db? like_or_where?
		| FULL_SYMBOL? TRIGGERS_SYMBOL in_db? like_or_where?
		| WARNINGS_SYMBOL limit_clause?
	)
;

non_blocking:
	{SERVER_VERSION >= 50700}? => NONBLOCKING_SYMBOL
;

from_or_in:
	FROM_SYMBOL | IN_SYMBOL
;

in_db:
	from_or_in identifier
;

profile_type:
	ALL_SYMBOL
	| BLOCK_SYMBOL IO_SYMBOL
	| CONTEXT_SYMBOL SWITCHES_SYMBOL
	| CPU_SYMBOL
	| IPC_SYMBOL
	| MEMORY_SYMBOL
	| PAGE_SYMBOL FAULTS_SYMBOL
	| SOURCE_SYMBOL
	| SWAPS_SYMBOL
;

//--------------------------------------------------------------------------------------------------

miscellaneous_statement:
	BINLOG_SYMBOL^ string_literal
	| CACHE_SYMBOL^ INDEX_SYMBOL key_cache_list_or_parts IN_SYMBOL (identifier | DEFAULT_SYMBOL)
	| FLUSH_SYMBOL^ no_write_to_bin_log? flush_option (COMMA_SYMBOL flush_option)*
	| KILL_SYMBOL^ (CONNECTION_SYMBOL | QUERY_SYMBOL)? INTEGER
	| LOAD_SYMBOL^ INDEX_SYMBOL INTO_SYMBOL CACHE_SYMBOL load_table_index_list
	| RESET_SYMBOL^ reset_option (COMMA_SYMBOL reset_option)*
;

key_cache_list_or_parts options { k = 4; }:
	key_cache_list -> ^(KEY_CACHE_LIST_TOKEN key_cache_list)
	| assign_to_keycache_partition -> ^(KEY_CACHE_PARTITION_TOKEN assign_to_keycache_partition)
;

key_cache_list:
	assign_to_keycache (COMMA_SYMBOL assign_to_keycache)*
;

assign_to_keycache:
	table_identifier cache_keys_spec?
;

assign_to_keycache_partition:
	table_identifier PARTITION_SYMBOL OPEN_PAR_SYMBOL (ALL_SYMBOL | identifier_list) CLOSE_PAR_SYMBOL cache_keys_spec?
;

cache_keys_spec:
	(KEY_SYMBOL | INDEX_SYMBOL) OPEN_PAR_SYMBOL (key_usage_element (COMMA_SYMBOL key_usage_element)*)? CLOSE_PAR_SYMBOL
;

key_usage_element:
	identifier
	| PRIMARY_SYMBOL
;

flush_option:
	DES_KEY_FILE_SYMBOL
	| HOSTS_SYMBOL
	| log_type? LOGS_SYMBOL
	| PRIVILEGES_SYMBOL
	| QUERY_SYMBOL CACHE_SYMBOL
	| STATUS_SYMBOL
	| flush_tables
	| USER_RESOURCES_SYMBOL
;

log_type:
	BINARY_SYMBOL
	| ENGINE_SYMBOL
	| ERROR_SYMBOL
	| GENERAL_SYMBOL
	| RELAY_SYMBOL
	| SLOW_SYMBOL
;

flush_tables:
	(TABLES_SYMBOL | TABLE_SYMBOL)
	(
		WITH_SYMBOL READ_SYMBOL LOCK_SYMBOL
		| identifier_list flush_tables_options?
	)?
;

flush_tables_options:
	{SERVER_VERSION >= 50606}? => FOR_SYMBOL EXPORT_SYMBOL
	| WITH_SYMBOL READ_SYMBOL LOCK_SYMBOL
;

load_table_index_list:
	table_identifier load_table_index_partion?
		((INDEX_SYMBOL | KEY_SYMBOL)? identifier_list_with_parentheses)? (IGNORE_SYMBOL LEAVES_SYMBOL)?
;

load_table_index_partion:
	{SERVER_VERSION >= 50500}? => (PARTITION_SYMBOL OPEN_PAR_SYMBOL (identifier_list | ALL_SYMBOL) CLOSE_PAR_SYMBOL)
;

reset_option:
	MASTER_SYMBOL | QUERY_SYMBOL CACHE_SYMBOL | SLAVE_SYMBOL
;

//--------------------------------------------------------------------------------------------------

utility_statement:
	describe_command
		(
			table_identifier text_or_identifier?
			|
				(
					// The format specifier is defined here like in the server grammar but actually defined are only
					// traditional and json, anything else results in a server error.
					EXTENDED_SYMBOL // deprecated since 5.7
					| {SERVER_VERSION >= 50105}? => PARTITIONS_SYMBOL // deprecated since 5.7
					| {SERVER_VERSION >= 50605}? => FORMAT_SYMBOL EQUAL_OPERATOR text_or_identifier
				)? explainable_statement
		)
	| HELP_SYMBOL^ text_or_identifier
	| USE_SYMBOL^ identifier
;

describe_command:
	DESCRIBE_SYMBOL^ | DESC_SYMBOL^
;

// Before server version 5.6 only select statements were explainable.
explainable_statement:
	select_statement
	| {SERVER_VERSION >= 50603}? =>
		(
			delete_statement
			| insert_statement
			| replace_statement
			| update_statement
		)
	| {SERVER_VERSION >= 50700}? => FOR_SYMBOL CONNECTION_SYMBOL INTEGER
;

//----------------- Expression support -------------------------------------------------------------

// The expression grammar here is completely different to that of the server parser due to the way operator
// precedence is implemented there (by custom tree writing). We do it the classical way here.

expression:
	logical_or_expression
;

logical_or_expression:
	logical_xor_expression ( options { greedy = true; }: (LOGICAL_OR_OPERATOR | OR_SYMBOL)^ logical_xor_expression)*
;

logical_xor_expression:
	logical_and_expression ( options { greedy = true; }: XOR_SYMBOL^ logical_and_expression)*
;

logical_and_expression:
	logical_not_expression ( options { greedy = true; }: (LOGICAL_AND_OPERATOR | AND_SYMBOL)^ logical_not_expression)*
;

logical_not_expression:
	NOT_SYMBOL^ logical_not_expression
	| boolean_primary_expression
;

boolean_primary_expression:
	predicate
		( options { greedy = true; }: 
			comparison_operator^
			(
				{LA(1) == ALL_SYMBOL || LA(1) == ANY_SYMBOL}? (ALL_SYMBOL | ANY_SYMBOL) subquery
				| predicate
			)
	    	| ( options { greedy = true; }: IS_SYMBOL^ NOT_SYMBOL? ( null_literal | FALSE_SYMBOL | TRUE_SYMBOL | UNKNOWN_SYMBOL))+
		)*
;

predicate:
	bitwise_or_expression
		( options { greedy = true; }:
			NOT_SYMBOL?
				(
					BETWEEN_SYMBOL^ bitwise_or_expression AND_SYMBOL predicate
					| LIKE_SYMBOL^ unary_expression ( options { greedy = true; }: ESCAPE_SYMBOL primary)?
					| REGEXP_SYMBOL^ bitwise_or_expression
					| IN_SYMBOL predicate_in
	    		)
	    	| SOUNDS_SYMBOL^ LIKE_SYMBOL bitwise_or_expression
		)?
;

// One of the 2 rules were 2 sub rules with unlimited nesting come together (and we need backtracking)
predicate_in:
	{is_subquery(ctx)}? => subquery
	| expression_list_with_parentheses
;

bitwise_or_expression:
	bitwise_and_expression ( options { greedy = true; }: BITWISE_OR_OPERATOR^ bitwise_and_expression)*
;

bitwise_and_expression:
	shift_expression ( options { greedy = true; }: BITWISE_AND_OPERATOR^ shift_expression)*
;

shift_expression:
	additive_expression ( options { greedy = true; }: (SHIFT_LEFT_OPERATOR | SHIFT_RIGHT_OPERATOR)^ additive_expression)*
;

additive_expression:
	multiplicative_expression ( options{ greedy = true; }: (PLUS_OPERATOR | MINUS_OPERATOR)^ multiplicative_expression)*
;

multiplicative_expression:
	bitwise_xor_expression ( options { greedy = true; }: multiplication_operator^ bitwise_xor_expression)*
;

bitwise_xor_expression:
	concat_expression ( options { greedy = true; }: BITWISE_XOR_OPERATOR^ concat_expression)*
;

// The concat expression is only active if SQL_MODE_PIPES_AS_CONCAT is set (then || switches semantic from logical or to concat pipes).
concat_expression:
	unary_expression ( options { greedy = true; }: CONCAT_PIPES_SYMBOL^ unary_expression)*
;

unary_expression:
	(PLUS_OPERATOR | MINUS_OPERATOR | BITWISE_NOT_OPERATOR) unary_expression
	| not_expression
;

not_expression:
	not2_rule? interval_expression
;

interval_expression:
	INTERVAL_SYMBOL!
		(
			// There are two forms using INTERVAL as keyword. Both can use INTERVAL OPEN_PAR expression... .
			// We disambiguate like the server parser does: if there is a second expression after the first separated
			// by comma then it's a function call, otherwise a time span.
			(OPEN_PAR_SYMBOL expression COMMA_SYMBOL) => interval_function
			| interval_time_span
		)
	| primary
;

interval_function:
	OPEN_PAR_SYMBOL expression (COMMA_SYMBOL expression)+ CLOSE_PAR_SYMBOL
		-> ^(FUNCTION_CALL_TOKEN INTERVAL_SYMBOL OPEN_PAR_SYMBOL expression (COMMA_SYMBOL expression)+ CLOSE_PAR_SYMBOL)
;

interval_time_span:
	interval -> ^(INTERVAL_SYMBOL interval)
;

primary:
    (
		literal
		| function_call_expression
		| (qualified_identifier OPEN_PAR_SYMBOL) => generic_function_call
		| field_name
		| PARAM_MARKER
		| variable
		| EXISTS_SYMBOL subquery
		| expression_with_nested_parentheses
		| OPEN_CURLY_SYMBOL identifier expression CLOSE_CURLY_SYMBOL
		| match_expression
		| case_expression
		| cast_expression
	)
	// Consume any collation expression locally to avoid ambiguities with the recursive cast_expression.
	( options { greedy = true; }: COLLATE_SYMBOL text_or_identifier)*
;

// This part is tricky, because all alternatives can have an unlimited nesting within parentheses.
// Best results by using a custom semantic predicate.
expression_with_nested_parentheses:
	{is_subquery(ctx)}? => subquery
	| expression_list_with_parentheses
	| ROW_SYMBOL OPEN_PAR_SYMBOL expression (COMMA_SYMBOL expression)+ CLOSE_PAR_SYMBOL
;

comparison_operator:
	EQUAL_OPERATOR | GREATER_OR_EQUAL_OPERATOR | GREATER_THAN_OPERATOR | LESS_OR_EQUAL_OPERATOR | LESS_THAN_OPERATOR | NOT_EQUAL_OPERATOR | NOT_EQUAL2_OPERATOR
		| NULL_SAFE_EQUAL_OPERATOR
;

multiplication_operator:
	MULT_OPERATOR | DIV_OPERATOR | DIV_SYMBOL | MOD_OPERATOR | MOD_SYMBOL
;

// This separate rule for a function_call exist only to work around a bug in the parser generator when doing rule rewriting
// in an alternative.
function_call_expression:
	function_call -> ^(FUNCTION_CALL_TOKEN function_call)
;

function_call:
	// Function names that are keywords.
	CHAR_SYMBOL OPEN_PAR_SYMBOL expression_list (USING_SYMBOL charset_name)? CLOSE_PAR_SYMBOL
	| CURRENT_USER_SYMBOL parentheses?
	| DATE_SYMBOL OPEN_PAR_SYMBOL expression CLOSE_PAR_SYMBOL
	| DAY_SYMBOL OPEN_PAR_SYMBOL expression CLOSE_PAR_SYMBOL
	| HOUR_SYMBOL OPEN_PAR_SYMBOL expression CLOSE_PAR_SYMBOL
	| INSERT_SYMBOL OPEN_PAR_SYMBOL expression COMMA_SYMBOL expression COMMA_SYMBOL expression COMMA_SYMBOL expression CLOSE_PAR_SYMBOL
	// | INTERVAL_SYMBOL OPEN_PAR_SYMBOL expression (COMMA_SYMBOL expression)+ CLOSE_PAR_SYMBOL => handled in interval_expression.
	| LEFT_SYMBOL OPEN_PAR_SYMBOL expression COMMA_SYMBOL expression CLOSE_PAR_SYMBOL
	| MINUTE_SYMBOL OPEN_PAR_SYMBOL expression CLOSE_PAR_SYMBOL
	| MONTH_SYMBOL OPEN_PAR_SYMBOL expression CLOSE_PAR_SYMBOL
	| RIGHT_SYMBOL OPEN_PAR_SYMBOL expression COMMA_SYMBOL expression CLOSE_PAR_SYMBOL
	| SECOND_SYMBOL OPEN_PAR_SYMBOL expression CLOSE_PAR_SYMBOL
	| TIME_SYMBOL OPEN_PAR_SYMBOL expression CLOSE_PAR_SYMBOL
	| TIMESTAMP_SYMBOL OPEN_PAR_SYMBOL expression (COMMA_SYMBOL expression)? CLOSE_PAR_SYMBOL
	| trim_function
	| USER_SYMBOL parentheses
	| VALUES_SYMBOL OPEN_PAR_SYMBOL expression CLOSE_PAR_SYMBOL
	| YEAR_SYMBOL OPEN_PAR_SYMBOL expression CLOSE_PAR_SYMBOL

	// Function names that are not keywords.
	| (ADDDATE_SYMBOL | SUBDATE_SYMBOL) OPEN_PAR_SYMBOL expression COMMA_SYMBOL expression CLOSE_PAR_SYMBOL
	| CURDATE_SYMBOL parentheses?
	| CURTIME_SYMBOL time_function_parameters?
	| (DATE_ADD_SYMBOL | DATE_SUB_SYMBOL) OPEN_PAR_SYMBOL expression COMMA_SYMBOL INTERVAL_SYMBOL interval CLOSE_PAR_SYMBOL
	| EXTRACT_SYMBOL OPEN_PAR_SYMBOL interval_unit FROM_SYMBOL expression CLOSE_PAR_SYMBOL
	| GET_FORMAT_SYMBOL OPEN_PAR_SYMBOL date_time_type  COMMA_SYMBOL expression CLOSE_PAR_SYMBOL
	| NOW_SYMBOL time_function_parameters?
	| POSITION_SYMBOL OPEN_PAR_SYMBOL bitwise_or_expression IN_SYMBOL expression CLOSE_PAR_SYMBOL
	| substring_function
	| SYSDATE_SYMBOL time_function_parameters?
	| (TIMESTAMP_ADD_SYMBOL | TIMESTAMP_DIFF_SYMBOL) OPEN_PAR_SYMBOL interval_timestamp_unit COMMA_SYMBOL expression COMMA_SYMBOL expression CLOSE_PAR_SYMBOL
	| UTC_DATE_SYMBOL parentheses?
	| UTC_TIME_SYMBOL time_function_parameters?
	| UTC_TIMESTAMP_SYMBOL time_function_parameters?

	// Function calls with other conflicts.
	| ASCII_SYMBOL OPEN_PAR_SYMBOL expression CLOSE_PAR_SYMBOL
	| CHARSET_SYMBOL OPEN_PAR_SYMBOL expression CLOSE_PAR_SYMBOL
	| COALESCE_SYMBOL expression_list_with_parentheses
	| COLLATION_SYMBOL OPEN_PAR_SYMBOL expression CLOSE_PAR_SYMBOL
	| DATABASE_SYMBOL parentheses
	| IF_SYMBOL OPEN_PAR_SYMBOL expression COMMA_SYMBOL expression COMMA_SYMBOL expression CLOSE_PAR_SYMBOL
	| FORMAT_SYMBOL OPEN_PAR_SYMBOL expression COMMA_SYMBOL expression (COMMA_SYMBOL expression)? CLOSE_PAR_SYMBOL
	| MICROSECOND_SYMBOL OPEN_PAR_SYMBOL expression CLOSE_PAR_SYMBOL
	| MOD_SYMBOL OPEN_PAR_SYMBOL expression COMMA_SYMBOL expression CLOSE_PAR_SYMBOL
	| OLD_PASSWORD_SYMBOL OPEN_PAR_SYMBOL expression CLOSE_PAR_SYMBOL
	| PASSWORD_SYMBOL OPEN_PAR_SYMBOL expression CLOSE_PAR_SYMBOL
	| QUARTER_SYMBOL OPEN_PAR_SYMBOL expression CLOSE_PAR_SYMBOL
	| REPEAT_SYMBOL OPEN_PAR_SYMBOL expression COMMA_SYMBOL expression CLOSE_PAR_SYMBOL
	| REPLACE_SYMBOL OPEN_PAR_SYMBOL expression COMMA_SYMBOL expression COMMA_SYMBOL expression CLOSE_PAR_SYMBOL
	| REVERSE_SYMBOL OPEN_PAR_SYMBOL expression CLOSE_PAR_SYMBOL
	| ROW_COUNT_SYMBOL parentheses
	| TRUNCATE_SYMBOL OPEN_PAR_SYMBOL expression COMMA_SYMBOL expression CLOSE_PAR_SYMBOL
	| WEEK_SYMBOL OPEN_PAR_SYMBOL expression (COMMA_SYMBOL expression)? CLOSE_PAR_SYMBOL
	| {SERVER_VERSION >= 50600}? => WEIGHT_STRING_SYMBOL OPEN_PAR_SYMBOL expression
		(
			(AS_SYMBOL CHAR_SYMBOL field_length)? weight_string_levels?
			| AS_SYMBOL BINARY_SYMBOL field_length
			| COMMA_SYMBOL INTEGER COMMA_SYMBOL INTEGER COMMA_SYMBOL INTEGER
		)
		CLOSE_PAR_SYMBOL
	| geometry_function
	| aggregate_function
;

time_function_parameters:
	OPEN_PAR_SYMBOL fractional_precision? CLOSE_PAR_SYMBOL
;

fractional_precision:
	{SERVER_VERSION >= 50604}? => INTEGER
;

weight_string_levels:
	LEVEL_SYMBOL
		(
			INTEGER MINUS_OPERATOR INTEGER
			| weight_string_level_list_item (COMMA_SYMBOL weight_string_level_list_item)*
		)
;

weight_string_level_list_item:
	INTEGER
		(
			(ASC_SYMBOL	| DESC_SYMBOL) REVERSE_SYMBOL?
			| REVERSE_SYMBOL
		)?
;

generic_function_call:
	qualified_identifier OPEN_PAR_SYMBOL expression_list? CLOSE_PAR_SYMBOL
		 -> ^(FUNCTION_CALL_TOKEN qualified_identifier OPEN_PAR_SYMBOL expression_list? CLOSE_PAR_SYMBOL)
;

date_time_type:
	DATE_SYMBOL
	| TIME_SYMBOL
	| DATETIME_SYMBOL
	| TIMESTAMP_SYMBOL
;

trim_function:
	TRIM_SYMBOL OPEN_PAR_SYMBOL
	(
		expression (FROM_SYMBOL expression)?
		| LEADING_SYMBOL expression? FROM_SYMBOL expression
		| TRAILING_SYMBOL expression? FROM_SYMBOL expression
		| BOTH_SYMBOL expression? FROM_SYMBOL expression
	)
	CLOSE_PAR_SYMBOL
;

substring_function:
	SUBSTRING_SYMBOL OPEN_PAR_SYMBOL expression
	(
		COMMA_SYMBOL expression (COMMA_SYMBOL expression)?
		| FROM_SYMBOL expression (FOR_SYMBOL expression)?
	)
	CLOSE_PAR_SYMBOL
;
	
geometry_function:
	CONTAINS_SYMBOL OPEN_PAR_SYMBOL expression COMMA_SYMBOL expression CLOSE_PAR_SYMBOL
	| GEOMETRYCOLLECTION_SYMBOL expression_list_with_parentheses
	| LINESTRING_SYMBOL expression_list_with_parentheses
	| MULTILINESTRING_SYMBOL expression_list_with_parentheses
	| MULTIPOINT_SYMBOL expression_list_with_parentheses
	| MULTIPOLYGON_SYMBOL expression_list_with_parentheses
	| POINT_SYMBOL OPEN_PAR_SYMBOL expression COMMA_SYMBOL expression CLOSE_PAR_SYMBOL
	| POLYGON_SYMBOL expression_list_with_parentheses
;

aggregate_function:
	AVG_SYMBOL OPEN_PAR_SYMBOL DISTINCT_SYMBOL? in_aggregate_expression CLOSE_PAR_SYMBOL
	| BIT_AND_SYMBOL OPEN_PAR_SYMBOL in_aggregate_expression CLOSE_PAR_SYMBOL
	| BIT_OR_SYMBOL OPEN_PAR_SYMBOL in_aggregate_expression CLOSE_PAR_SYMBOL
	| BIT_XOR_SYMBOL OPEN_PAR_SYMBOL in_aggregate_expression CLOSE_PAR_SYMBOL
	| count_function
	| MIN_SYMBOL OPEN_PAR_SYMBOL DISTINCT_SYMBOL? in_aggregate_expression CLOSE_PAR_SYMBOL
	| MAX_SYMBOL OPEN_PAR_SYMBOL DISTINCT_SYMBOL? in_aggregate_expression CLOSE_PAR_SYMBOL
	| STD_SYMBOL OPEN_PAR_SYMBOL in_aggregate_expression CLOSE_PAR_SYMBOL
	| VARIANCE_SYMBOL OPEN_PAR_SYMBOL in_aggregate_expression CLOSE_PAR_SYMBOL
	| STDDEV_SAMP_SYMBOL OPEN_PAR_SYMBOL in_aggregate_expression CLOSE_PAR_SYMBOL
	| VAR_SAMP_SYMBOL OPEN_PAR_SYMBOL in_aggregate_expression CLOSE_PAR_SYMBOL
	| SUM_SYMBOL OPEN_PAR_SYMBOL DISTINCT_SYMBOL? in_aggregate_expression CLOSE_PAR_SYMBOL
	| GROUP_CONCAT_SYMBOL OPEN_PAR_SYMBOL DISTINCT_SYMBOL? expression_list order_by_clause? (SEPARATOR_SYMBOL string_literal)? CLOSE_PAR_SYMBOL
;

in_aggregate_expression:
	ALL_SYMBOL? expression
;

count_function:
	COUNT_SYMBOL OPEN_PAR_SYMBOL
	(
		ALL_SYMBOL? MULT_OPERATOR
		| in_aggregate_expression
		| DISTINCT_SYMBOL expression_list
	)
	CLOSE_PAR_SYMBOL
;

aliased_expression_list:
	aliased_expression (COMMA_SYMBOL aliased_expression)*
;

aliased_expression:
	expression select_alias?
;

variable options { greedy = true; }:
	user_variable (ASSIGN_OPERATOR^ expression)?
	| system_variable
;

user_variable:
	(AT_SIGN_SYMBOL text_or_identifier) -> AT_TEXT_SUFFIX AT_SIGN_SYMBOL text_or_identifier
	| AT_TEXT_SUFFIX
;

// System variables as used in expressions. SET has another variant of this (SET GLOBAL/LOCAL varname).
system_variable:
	AT_AT_SIGN_SYMBOL ( options { greedy = true; }: option_type DOT_SYMBOL)? variable_name
;

variable_name:
	identifier (DOT_SYMBOL identifier)?    // Check in semantic phase that the first id is not global/local/session/default.
	| DEFAULT_SYMBOL DOT_SYMBOL identifier
;

match_expression:
	MATCH_SYMBOL^ OPEN_PAR_SYMBOL field_name_list CLOSE_PAR_SYMBOL AGAINST_SYMBOL OPEN_PAR_SYMBOL bitwise_or_expression
		(
			IN_SYMBOL BOOLEAN_SYMBOL MODE_SYMBOL
			| (IN_SYMBOL NATURAL_SYMBOL LANGUAGE_SYMBOL MODE_SYMBOL)? (WITH_SYMBOL QUERY_SYMBOL EXPANSION_SYMBOL)?
		)
		CLOSE_PAR_SYMBOL
;

// CASE expression used in (primary) expressions. There's another form used for stored programs (case_statement).
case_expression:
	CASE_SYMBOL expression? (when_expression then_expression)+ else_expression? END_SYMBOL
;

when_expression:
	WHEN_SYMBOL^ expression
;

then_expression:
	THEN_SYMBOL^ expression
;

else_expression:
	ELSE_SYMBOL^ expression
;

cast_expression:
	BINARY_SYMBOL primary
	| CAST_SYMBOL OPEN_PAR_SYMBOL expression AS_SYMBOL cast_type CLOSE_PAR_SYMBOL
	| CONVERT_SYMBOL OPEN_PAR_SYMBOL expression	(COMMA_SYMBOL cast_type	| USING_SYMBOL charset_name) CLOSE_PAR_SYMBOL
;

cast_type:
	BINARY_SYMBOL field_length?
	| CHAR_SYMBOL field_length? encoding?
	| NCHAR_SYMBOL field_length?
	| SIGNED_SYMBOL INT_SYMBOL?
	| UNSIGNED_SYMBOL INT_SYMBOL?
	| DATE_SYMBOL
	| TIME_SYMBOL type_datetime_precision?
	| DATETIME_SYMBOL type_datetime_precision?
	| DECIMAL_SYMBOL float_options?
;

encoding:
	ASCII_SYMBOL BINARY_SYMBOL?
	| BINARY_SYMBOL (ASCII_SYMBOL | UNICODE_SYMBOL | charset charset_name)?
	| UNICODE_SYMBOL BINARY_SYMBOL?
	| BYTE_SYMBOL
	| charset charset_name BINARY_SYMBOL?
;

charset:
	CHAR_SYMBOL SET_SYMBOL | CHARSET_SYMBOL
;

not_rule:
	NOT_SYMBOL
	| NOT2_SYMBOL // A NOT with a different (higher) operator precedence. 
;

not2_rule:
	LOGICAL_NOT_OPERATOR
	| NOT2_SYMBOL
;

or_rule:
	OR_SYMBOL
	| LOGICAL_OR_OPERATOR
;

xor_rule:
	XOR_SYMBOL
	| BITWISE_XOR_OPERATOR
;

and_rule:
	AND_SYMBOL
	| LOGICAL_AND_OPERATOR
;

interval:
	 expression interval_unit
;

// None of the microsecond variants can be used in schedules (e.g. events).
interval_unit:
	interval_timestamp_unit
	| SECOND_MICROSECOND_SYMBOL
	| MINUTE_MICROSECOND_SYMBOL
	| MINUTE_SECOND_SYMBOL
	| HOUR_MICROSECOND_SYMBOL
	| HOUR_SECOND_SYMBOL
	| HOUR_MINUTE_SYMBOL
	| DAY_MICROSECOND_SYMBOL
	| DAY_SECOND_SYMBOL
	| DAY_MINUTE_SYMBOL
	| DAY_HOUR_SYMBOL
	| YEAR_MONTH_SYMBOL
;

// Support for SQL_TSI_* units is added by mapping those to tokens without SQL_TSI_ prefix.
interval_timestamp_unit:
	MICROSECOND_SYMBOL
	| {SERVER_VERSION < 50503}? => FRAC_SECOND_SYMBOL
	| SECOND_SYMBOL
	| MINUTE_SYMBOL
	| HOUR_SYMBOL
	| DAY_SYMBOL   
	| WEEK_SYMBOL
	| MONTH_SYMBOL
	| QUARTER_SYMBOL
	| YEAR_SYMBOL
;

expression_list_with_parentheses:
	OPEN_PAR_SYMBOL expression_list CLOSE_PAR_SYMBOL -> ^(PAR_EXPRESSION_TOKEN OPEN_PAR_SYMBOL expression_list CLOSE_PAR_SYMBOL)
;

expression_list:
	expression (COMMA_SYMBOL expression)*
;

expression_list_with_direction:
	expression direction? ( options { greedy = true; }: COMMA_SYMBOL expression direction?)*
;

//----------------- Stored program rules -----------------------------------------------------------

// Compound syntax for stored procedures, stored functions, triggers and events.
compound_statement:
	statement
	| label?
		(
			{LA(2) != WORK_SYMBOL}? begin_end_block
			| loop_block
			| repeat_until_block
			| while_do_block
		)
	| case_statement
	| if_statement
	| iterate_statement
	| leave_statement
	| return_statement
	
	| cursor_open
	| cursor_fetch
	| cursor_close
	
	| {SERVER_VERSION >= 50600}? => get_diagnostics
	| {SERVER_VERSION >= 50500}? => signal_statement
	| {SERVER_VERSION >= 50500}? => resignal_statement
;

compound_statement_list:
	(compound_statement SEMICOLON_SYMBOL)+
;

label:
	// Block labels can only be up to 16 characters long.
	label_identifier COLON_SYMBOL -> ^(LABEL_TOKEN label_identifier COLON_SYMBOL)
;

label_identifier:
	pure_identifier | keyword_sp
;

begin_end_block: 
	BEGIN_SYMBOL^ declarations compound_statement_list? END_SYMBOL label_identifier?
;

loop_block:
	LOOP_SYMBOL^ compound_statement_list END_SYMBOL LOOP_SYMBOL label_identifier?
;

repeat_until_block:
	REPEAT_SYMBOL^ compound_statement_list UNTIL_SYMBOL expression END_SYMBOL REPEAT_SYMBOL label_identifier?
;

while_do_block:
	WHILE_SYMBOL^ expression DO_SYMBOL compound_statement_list END_SYMBOL WHILE_SYMBOL label_identifier?
;

declarations: // Order is important here.
	( options { k = 3; }: DECLARE_SYMBOL identifier (variable_declaration | condition_declaration))*
		cursor_declaration* handler_declaration*
;

variable_declaration:
	(COMMA_SYMBOL identifier)* data_type (DEFAULT_SYMBOL expression)? SEMICOLON_SYMBOL
;

condition_declaration:
	CONDITION_SYMBOL FOR_SYMBOL (INTEGER | SQLSTATE_SYMBOL VALUE_SYMBOL? string_literal) SEMICOLON_SYMBOL
;

cursor_declaration:
	DECLARE_SYMBOL identifier CURSOR_SYMBOL FOR_SYMBOL select_statement SEMICOLON_SYMBOL
;

handler_declaration:
	DECLARE_SYMBOL (CONTINUE_SYMBOL | EXIT_SYMBOL | UNDO_SYMBOL) HANDLER_SYMBOL
		FOR_SYMBOL handler_condition (COMMA_SYMBOL handler_condition)* compound_statement SEMICOLON_SYMBOL
;

handler_condition:
	INTEGER
	| SQLSTATE_SYMBOL VALUE_SYMBOL? string_literal
	| identifier
	| SQLWARNING_SYMBOL
	| NOT_SYMBOL FOUND_SYMBOL
	| SQLEXCEPTION_SYMBOL
;

// CASE rule solely for stored programs. There's another variant (case_expression) used in (primary) expressions.
case_statement:
	CASE_SYMBOL^ expression? (when_expression then_statement)+ else_statement? END_SYMBOL CASE_SYMBOL
;

then_statement:
	THEN_SYMBOL^ compound_statement_list
;

else_statement:
	ELSE_SYMBOL^ compound_statement_list
;

if_statement:
	IF_SYMBOL^ if_body END_SYMBOL IF_SYMBOL
;

if_body:
	expression then_statement (ELSEIF_SYMBOL if_body | ELSE_SYMBOL compound_statement_list)?
;

iterate_statement:
	ITERATE_SYMBOL label_identifier
;

leave_statement:
	LEAVE_SYMBOL label_identifier
;

return_statement:
	RETURN_SYMBOL expression
;

get_diagnostics:
	GET_SYMBOL
	(
		CURRENT_SYMBOL
		| {SERVER_VERSION >= 50700}? => STACKED_SYMBOL
	)? DIAGNOSTICS_SYMBOL
	(
		statement_information_item (COMMA_SYMBOL statement_information_item)*
		| CONDITION_SYMBOL INTEGER condition_information_item (COMMA_SYMBOL condition_information_item)*
	)
;

statement_information_item:
	(variable | identifier) EQUAL_OPERATOR (NUMBER_SYMBOL | ROW_COUNT_SYMBOL)
;

condition_information_item:
	(variable | identifier) EQUAL_OPERATOR (signal_information_item_name | RETURNED_SQLSTATE_SYMBOL)
;

signal_information_item_name:
	CLASS_ORIGIN_SYMBOL
	| SUBCLASS_ORIGIN_SYMBOL
	| CONSTRAINT_CATALOG_SYMBOL
	| CONSTRAINT_SCHEMA_SYMBOL
	| CONSTRAINT_NAME_SYMBOL
	| CATALOG_NAME_SYMBOL
	| SCHEMA_NAME_SYMBOL
	| TABLE_NAME_SYMBOL
	| COLUMN_NAME_SYMBOL
	| CURSOR_NAME_SYMBOL
	| MESSAGE_TEXT_SYMBOL
	| MYSQL_ERRNO_SYMBOL
;

signal_statement:
	SIGNAL_SYMBOL
		(
			identifier
			| SQLSTATE_SYMBOL VALUE_SYMBOL? text_or_identifier
		)
		(SET_SYMBOL signal_information_item (COMMA_SYMBOL signal_information_item)*)?
;

resignal_statement:
	RESIGNAL_SYMBOL (SQLSTATE_SYMBOL VALUE_SYMBOL? text_or_identifier)?
		(SET_SYMBOL signal_information_item (COMMA_SYMBOL signal_information_item)*)?
;

signal_information_item:
	signal_information_item_name EQUAL_OPERATOR (literal | variable | identifier)
;

cursor_close:
	CLOSE_SYMBOL identifier
;

cursor_fetch:
	FETCH_SYMBOL identifier INTO_SYMBOL identifier_list
;

cursor_open:
	OPEN_SYMBOL identifier
;

//----------------- Supplemental rules -------------------------------------------------------------

// Schedules in CREATE/ALTER EVENT.
schedule:
	AT_SYMBOL expression
	| EVERY_SYMBOL interval (STARTS_SYMBOL expression)? (ENDS_SYMBOL expression)?
;

database_option:
	DEFAULT_SYMBOL?
		(
			CHAR_SYMBOL SET_SYMBOL EQUAL_OPERATOR? charset_name_or_default
			| COLLATE_SYMBOL EQUAL_OPERATOR? collation_name_or_default
		)
;

column_definition:
	field_spec (reference_definition | (CHECK_SYMBOL OPEN_PAR_SYMBOL expression CLOSE_PAR_SYMBOL)?)
;

field_spec:
	identifier data_type attribute* ( options { greedy = true; }: reference_definition)?
;

attribute:
	NOT_SYMBOL? null_literal
	| DEFAULT_SYMBOL (signed_literal | NOW_SYMBOL time_function_parameters?)
	| ON_SYMBOL UPDATE_SYMBOL NOW_SYMBOL time_function_parameters?
	| AUTO_INCREMENT_SYMBOL
	| SERIAL_SYMBOL DEFAULT_SYMBOL VALUE_SYMBOL
	| {LA(2) != KEY_SYMBOL}? UNIQUE_SYMBOL
	| (PRIMARY_SYMBOL | UNIQUE_SYMBOL) KEY_SYMBOL
	| KEY_SYMBOL
	| COMMENT_SYMBOL string_literal
	| COLLATE_SYMBOL text_or_identifier
	| COLUMN_FORMAT_SYMBOL (FIXED_SYMBOL | DYNAMIC_SYMBOL | DEFAULT_SYMBOL)
	| STORAGE_SYMBOL (DISK_SYMBOL | MEMORY_SYMBOL | DEFAULT_SYMBOL)
;

reference_definition:
	REFERENCES_SYMBOL^ table_identifier (OPEN_PAR_SYMBOL index_column (COMMA_SYMBOL index_column)? CLOSE_PAR_SYMBOL)?
		(MATCH_SYMBOL (FULL_SYMBOL | PARTIAL_SYMBOL | SIMPLE_SYMBOL))?
		(ON_SYMBOL DELETE_SYMBOL reference_option)?
		(ON_SYMBOL UPDATE_SYMBOL reference_option)?
;

index_columns:
	OPEN_PAR_SYMBOL index_column (COMMA_SYMBOL index_column)* CLOSE_PAR_SYMBOL
;

index_column:
	identifier field_length? direction?
;

index_type:
	(USING_SYMBOL | TYPE_SYMBOL) (BTREE_SYMBOL | RTREE_SYMBOL | HASH_SYMBOL)
;

index_option:
	index_type
	| spatial_index_option
;

fulltext_index_option:
	WITH_SYMBOL PARSER_SYMBOL identifier
	| spatial_index_option
;

spatial_index_option:
	KEY_BLOCK_SIZE_SYMBOL EQUAL_OPERATOR? INTEGER
	| {SERVER_VERSION >= 50600}? => COMMENT_SYMBOL string_literal
;

reference_option:
	RESTRICT_SYMBOL | CASCADE_SYMBOL | SET_SYMBOL null_literal | NO_SYMBOL ACTION_SYMBOL
;

data_type:
	data_type_elements -> ^(DATA_TYPE_TOKEN data_type_elements)
;

data_type_elements:
	integer_type field_length? field_options?

	| real_literal precision? field_options?
	| FLOAT_SYMBOL float_options? field_options?
	
	| BIT_SYMBOL field_length?
	| BOOL_SYMBOL
	| BOOLEAN_SYMBOL
	
	| CHAR_SYMBOL field_length? string_binary?
	| nchar_literal field_length? BINARY_SYMBOL?
	| BINARY_SYMBOL field_length?
	| varchar_literal field_length string_binary?
	| nvarchar_literal field_length string_binary?

	| VARBINARY_SYMBOL field_length

	| YEAR_SYMBOL field_length? field_options?
	| DATE_SYMBOL
	| TIME_SYMBOL type_datetime_precision?
	| TIMESTAMP_SYMBOL type_datetime_precision?
	| DATETIME_SYMBOL type_datetime_precision?

	| TINYBLOB_SYMBOL
	| BLOB_SYMBOL field_length?
	| MEDIUMBLOB_SYMBOL
	| LONGBLOB_SYMBOL
	| LONG_SYMBOL VARBINARY_SYMBOL
	| LONG_SYMBOL varchar_literal? string_binary?

	| TINYTEXT_SYMBOL string_binary?
	| TEXT_SYMBOL field_length? string_binary?
	| MEDIUMTEXT_SYMBOL string_binary?
	| LONGTEXT_SYMBOL string_binary?
	
	| DECIMAL_SYMBOL float_options? field_options?
	| NUMERIC_SYMBOL float_options? field_options?
	| FIXED_SYMBOL float_options? field_options?
	
	| ENUM_SYMBOL string_list string_binary?
	| SET_SYMBOL string_list string_binary?
	| SERIAL_SYMBOL
	| spatial_type
;

field_length:
	OPEN_PAR_SYMBOL INTEGER CLOSE_PAR_SYMBOL
;

field_options:
	(SIGNED_SYMBOL | UNSIGNED_SYMBOL | ZEROFILL_SYMBOL)+
;

string_binary:
	ascii
	| unicode
	| BYTE_SYMBOL
	| charset charset_name BINARY_SYMBOL?
	| BINARY_SYMBOL (charset charset_name)?
;

ascii:
	ASCII_SYMBOL BINARY_SYMBOL?
	| {SERVER_VERSION >= 50500}? => BINARY_SYMBOL ASCII_SYMBOL
;

unicode:
	UNICODE_SYMBOL BINARY_SYMBOL?
	| {SERVER_VERSION >= 50500}? => BINARY_SYMBOL UNICODE_SYMBOL
;

type_datetime_precision:
	{SERVER_VERSION >= 50600}? => OPEN_PAR_SYMBOL INTEGER CLOSE_PAR_SYMBOL
;

charset_name:
	text_or_identifier
	| BINARY_SYMBOL
;

charset_name_or_default:
	charset_name
	| DEFAULT_SYMBOL
;

collation_name_or_default:
	text_or_identifier
	| DEFAULT_SYMBOL
;

spatial_type:
	GEOMETRY_SYMBOL
	| GEOMETRYCOLLECTION_SYMBOL
	| POINT_SYMBOL
	| MULTIPOINT_SYMBOL
	| LINESTRING_SYMBOL
	| MULTILINESTRING_SYMBOL
	| POLYGON_SYMBOL
	| MULTIPOLYGON_SYMBOL
;

alter_table_options:
	create_table_option+
;

create_table_options:
	create_table_option (COMMA_SYMBOL? create_table_option)*
;

create_table_option: // In the order as they appear in the server grammar.
	(ENGINE_SYMBOL | {SERVER_VERSION < 50500}? => TYPE_SYMBOL) EQUAL_OPERATOR? text_or_identifier
	| MAX_ROWS_SYMBOL EQUAL_OPERATOR? int_or_param_marker
	| MIN_ROWS_SYMBOL EQUAL_OPERATOR? int_or_param_marker
	| AVG_ROW_LENGTH_SYMBOL EQUAL_OPERATOR? int_or_param_marker
	| PASSWORD_SYMBOL EQUAL_OPERATOR? text_or_param_marker
	| COMMENT_SYMBOL EQUAL_OPERATOR? text_or_param_marker
	| AUTO_INCREMENT_SYMBOL EQUAL_OPERATOR? int_or_param_marker
	| PACK_KEYS_SYMBOL EQUAL_OPERATOR? (INTEGER | DEFAULT_SYMBOL)
	| {SERVER_VERSION >= 50600}? =>	(STATS_AUTO_RECALC_SYMBOL | STATS_PERSISTENT_SYMBOL | STATS_SAMPLE_PAGES_SYMBOL)
		EQUAL_OPERATOR? (int_or_param_marker | DEFAULT_SYMBOL)
	| (CHECKSUM_SYMBOL | TABLE_CHECKSUM_SYMBOL) EQUAL_OPERATOR? INTEGER // Actually only 0 and 1. Same is true for the other INTEGER refs in this rule.
	| DELAY_KEY_WRITE_SYMBOL EQUAL_OPERATOR? INTEGER
	| ROW_FORMAT_SYMBOL EQUAL_OPERATOR? (DEFAULT_SYMBOL | DYNAMIC_SYMBOL | FIXED_SYMBOL | COMPRESSED_SYMBOL | REDUNDANT_SYMBOL | COMPACT_SYMBOL)
	| UNION_SYMBOL EQUAL_OPERATOR? OPEN_PAR_SYMBOL qualified_identifier_list CLOSE_PAR_SYMBOL
	| DEFAULT_SYMBOL?
		(
			COLLATE_SYMBOL EQUAL_OPERATOR? collation_name_or_default
			| charset EQUAL_OPERATOR? charset_name_or_default
		)

	| INSERT_METHOD_SYMBOL EQUAL_OPERATOR? (NO_SYMBOL | FIRST_SYMBOL | LAST_SYMBOL)
	| DATA_SYMBOL DIRECTORY_SYMBOL EQUAL_OPERATOR? text_or_param_marker
	| INDEX_SYMBOL DIRECTORY_SYMBOL EQUAL_OPERATOR? text_or_param_marker
	| TABLESPACE_SYMBOL identifier
	| STORAGE_SYMBOL (DISK_SYMBOL | MEMORY_SYMBOL)
	| CONNECTION_SYMBOL EQUAL_OPERATOR? text_or_param_marker
	| KEY_BLOCK_SIZE_SYMBOL EQUAL_OPERATOR? int_or_param_marker
;

// Partition rules for CREATE/ALTER TABLE.
partitioning:
	{SERVER_VERSION >= 50100}? => PARTITION_SYMBOL^ BY_SYMBOL
	(
		LINEAR_SYMBOL? HASH_SYMBOL OPEN_PAR_SYMBOL expression CLOSE_PAR_SYMBOL
		| LINEAR_SYMBOL? KEY_SYMBOL partition_key_algorithm? identifier_list_with_parentheses
		| (RANGE_SYMBOL | LIST_SYMBOL)
			( 
				OPEN_PAR_SYMBOL expression CLOSE_PAR_SYMBOL
				| {SERVER_VERSION >= 50500}? => COLUMNS_SYMBOL identifier_list_with_parentheses
			)
	)
	(PARTITIONS_SYMBOL INTEGER)?
	(
		SUBPARTITION_SYMBOL BY_SYMBOL LINEAR_SYMBOL?
		(
			(
				 HASH_SYMBOL OPEN_PAR_SYMBOL expression CLOSE_PAR_SYMBOL
				| KEY_SYMBOL partition_key_algorithm? identifier_list_with_parentheses
			)
			(SUBPARTITIONS_SYMBOL INTEGER)?
		)?
    )?
    partition_definitions?
;

partition_key_algorithm: // Actually only 1 and 2 are allowed. Needs a semantic check.
	{SERVER_VERSION >= 50700}? => ALGORITHM_SYMBOL EQUAL_OPERATOR INTEGER
;

partition_definitions:
	OPEN_PAR_SYMBOL partition_definition (COMMA_SYMBOL partition_definition)* CLOSE_PAR_SYMBOL
;

partition_definition:
	PARTITION_SYMBOL identifier
	(
		VALUES_SYMBOL
		(
			LESS_SYMBOL THAN_SYMBOL (partition_value_list | MAXVALUE_SYMBOL)
			| IN_SYMBOL partition_value_list
		)
	)?
	(STORAGE_SYMBOL? ENGINE_SYMBOL EQUAL_OPERATOR? IDENTIFIER)?
	(COMMENT_SYMBOL EQUAL_OPERATOR? string_literal)?
	(DATA_SYMBOL DIRECTORY_SYMBOL EQUAL_OPERATOR? string_literal)?
	(INDEX_SYMBOL DIRECTORY_SYMBOL EQUAL_OPERATOR? string_literal)?
	(MAX_ROWS_SYMBOL EQUAL_OPERATOR? INTEGER)?
	(MIN_ROWS_SYMBOL EQUAL_OPERATOR? INTEGER)?
	(TABLESPACE_SYMBOL EQUAL_OPERATOR? identifier)?
	(NODEGROUP_SYMBOL EQUAL_OPERATOR? identifier)?
	(OPEN_PAR_SYMBOL subpartition_definition (COMMA_SYMBOL subpartition_definition)* CLOSE_PAR_SYMBOL)?
;

subpartition_definition:
	SUBPARTITION_SYMBOL identifier
		(STORAGE_SYMBOL? ENGINE_SYMBOL EQUAL_OPERATOR? IDENTIFIER)?
		(COMMENT_SYMBOL EQUAL_OPERATOR? string_literal)?
		(DATA_SYMBOL DIRECTORY_SYMBOL EQUAL_OPERATOR? string_literal)?
		(INDEX_SYMBOL DIRECTORY_SYMBOL EQUAL_OPERATOR? string_literal)?
		(MAX_ROWS_SYMBOL EQUAL_OPERATOR? INTEGER)?
		(MIN_ROWS_SYMBOL EQUAL_OPERATOR? INTEGER)?
		(TABLESPACE_SYMBOL EQUAL_OPERATOR? identifier)?
		(NODEGROUP_SYMBOL EQUAL_OPERATOR? identifier)?
;

partition_value_list:
	OPEN_PAR_SYMBOL (expression | MAXVALUE_SYMBOL) (COMMA_SYMBOL (expression | MAXVALUE_SYMBOL))* CLOSE_PAR_SYMBOL
;

definer_clause:
	DEFINER_SYMBOL^ EQUAL_OPERATOR user
;

if_exists:
	IF_SYMBOL EXISTS_SYMBOL
;

if_not_exists:
	IF_SYMBOL NOT_SYMBOL EXISTS_SYMBOL
;

procedure_parameter:
	(IN_SYMBOL | OUT_SYMBOL | INOUT_SYMBOL)? function_parameter
;

function_parameter:
	identifier data_type
;

schema_identifier_pair:
	OPEN_PAR_SYMBOL schema_name COMMA_SYMBOL schema_name CLOSE_PAR_SYMBOL
;

schema_name:
	identifier -> ^(SCHEMA_NAME_TOKEN identifier)
;

qualified_table_identifier: // Always qualified.
	identifier DOT_SYMBOL identifier -> ^(TABLE_NAME_TOKEN identifier DOT_SYMBOL identifier)
;

table_identifier:
	table_identifier_variants -> ^(TABLE_NAME_TOKEN table_identifier_variants)
;

table_identifier_variants:
	// In order to avoid ambiguities with following identifiers (which could be starting with a dot) we match
	// any (DOT identifier) sequence as part of this table identifier.
	identifier ( options { greedy = true; }: DOT_SYMBOL identifier)?
	| DOT_SYMBOL identifier
;

table_identifier_list:
	table_identifier (COMMA_SYMBOL table_identifier)*
;       

procedure_identifier:
	qualified_identifier -> ^(PROCEDURE_NAME_TOKEN qualified_identifier)
;

function_identifier:
	qualified_identifier -> ^(FUNCTION_NAME_TOKEN qualified_identifier)
;

trigger_identifier:
	qualified_identifier -> ^(TRIGGER_NAME_TOKEN qualified_identifier)
;

view_identifier:
	qualified_identifier -> ^(VIEW_NAME_TOKEN qualified_identifier)
;

tablespace_name:
	identifier -> ^(TABLESPACE_NAME_TOKEN identifier)
;

log_file_group_name:
	identifier -> ^(LOGFILE_GROUP_NAME_TOKEN identifier)
;

udf_name:
	identifier -> ^(UDF_NAME_TOKEN identifier)
;

qualified_identifier_list:
	qualified_identifier (COMMA_SYMBOL qualified_identifier)*
;       

qualified_identifier:
	identifier (DOT_SYMBOL identifier)?
;

qualified_identifier_with_wildcard:
	qualified_identifier DOT_SYMBOL MULT_OPERATOR
;       

// There are two table name rules: target_table and table_identifer. The latter allows a leading dot.
// So this separation is by intention.
target_table:
	qualified_identifier -> ^(TABLE_NAME_TOKEN qualified_identifier)
;
	
target_table_with_optional_wildcard:
	qualified_identifier (DOT_SYMBOL MULT_OPERATOR)? -> ^(TABLE_NAME_TOKEN qualified_identifier (DOT_SYMBOL MULT_OPERATOR)?)
;
	
column_assignment:
	field_name EQUAL_OPERATOR expression
;

field_name_list:
	field_name (COMMA_SYMBOL field_name)*
;

field_name:
	field_name_entry -> ^(FIELD_NAME_TOKEN field_name_entry)
;

// In a separate rule because otherwise it would mess up the AST (repeating the first identifier 3 times).
field_name_entry:
	identifier (DOT_SYMBOL identifier (DOT_SYMBOL identifier)?)?
;

column_assignment_list_with_default:
	column_assignment_with_default (COMMA_SYMBOL column_assignment_with_default)*
		-> ^(COLUMN_ASSIGNMENT_LIST_TOKEN column_assignment_with_default (COMMA_SYMBOL column_assignment_with_default)*)
;

column_assignment_with_default:
	field_name EQUAL_OPERATOR (expression | DEFAULT_SYMBOL)
;

charset_clause:
	charset (text_or_identifier | DEFAULT_SYMBOL | BINARY_SYMBOL)
;

fields_clause:
	COLUMNS_SYMBOL field_term+
;

field_term:
	TERMINATED_SYMBOL BY_SYMBOL string_literal
	| OPTIONALLY_SYMBOL? ENCLOSED_SYMBOL BY_SYMBOL string_literal
	| ESCAPED_SYMBOL BY_SYMBOL string_literal
;

lines_clause:
	LINES_SYMBOL line_term+
;

line_term:
	(TERMINATED_SYMBOL | STARTING_SYMBOL) BY_SYMBOL string_literal
;

user_list:
	user (COMMA_SYMBOL user)*
;

user_specification:
	user
	(
		IDENTIFIED_SYMBOL
		(
			BY_SYMBOL PASSWORD_SYMBOL? string_literal
			| WITH_SYMBOL pure_identifier (AS_SYMBOL string_literal)?
		)
	)?
;

user:
	text_or_identifier (AT_SIGN_SYMBOL text_or_identifier | AT_TEXT_SUFFIX)?
	| CURRENT_USER_SYMBOL parentheses?
;

like_clause:
	LIKE_SYMBOL text_or_param_marker
;

like_or_where:
	like_clause | where_clause
;

online_option:
	{SERVER_VERSION < 50600}? => (ONLINE_SYMBOL | OFFLINE_SYMBOL)
;

no_write_to_bin_log:
	{LA(1) == LOCAL_SYMBOL}? => LOCAL_SYMBOL // Predicate needed to direct the parser (as LOCAL can also be an identifier).
	| NO_WRITE_TO_BINLOG_SYMBOL
;

use_partition:
	{SERVER_VERSION >= 50602}? => PARTITION_SYMBOL identifier_list_with_parentheses
;

//----------------- Common basic rules -------------------------------------------------------------

// Identifiers excluding keywords (except if they are quoted).
pure_identifier:
	IDENTIFIER
	| BACK_TICK_QUOTED_ID
	| {SQL_MODE_ACTIVE(SQL_MODE_ANSI_QUOTES)}? => DOUBLE_QUOTED_TEXT
;

// Identifiers including a certain set of keywords, which are allowed also if not quoted.
identifier:
	pure_identifier
	| keyword
;

identifier_list:
	identifier ( options { greedy = true; }: COMMA_SYMBOL identifier)*
;

identifier_list_with_parentheses:
	OPEN_PAR_SYMBOL identifier_list CLOSE_PAR_SYMBOL
;

integer_list:
	INTEGER (COMMA_SYMBOL INTEGER)*
;

string_list:
	OPEN_PAR_SYMBOL string_literal (COMMA_SYMBOL string_literal)* CLOSE_PAR_SYMBOL
;

literal:
	string_literal
	| number_literal
	| hex_literal
	| bool_literal
	| {SERVER_VERSION >= 50003}? => bit_literal
	| null_literal
   	// Date, time and timestamp can be both a temporal literal or a field name, so we need a predicate.
	| {LA(1) == DATE_SYMBOL || LA(1) == TIME_SYMBOL || LA(1) == TIMESTAMP_SYMBOL}? temporal_literal
;

signed_literal:
	literal
	| PLUS_OPERATOR number_literal
	| MINUS_OPERATOR number_literal
;

// To ease post processing strings (for automatic concatenation) we use an own subtree for each string.
// Because of that already mentioned bug we need a separate rule when doing tree rewrite for a single alternative.
string_literal:
	string -> ^(STRING_TOKEN string)
;

string:
	NCHAR_TEXT
	| UNDERSCORE_CHARSET? ( options { greedy = true; }: SINGLE_QUOTED_TEXT | {!SQL_MODE_ACTIVE(SQL_MODE_ANSI_QUOTES)}? => DOUBLE_QUOTED_TEXT)+
;

number_literal:
	INTEGER
	| FLOAT
;

hex_literal:
	UNDERSCORE_CHARSET? (HEXNUMBER | HEXSTRING)
;

bool_literal:
	TRUE_SYMBOL
	| FALSE_SYMBOL
;

bit_literal:
	UNDERSCORE_CHARSET? (BITNUMBER | BITSTRING)
;

null_literal:
	NULL_SYMBOL
	| NULL2_SYMBOL
;

temporal_literal:
	DATE_SYMBOL SINGLE_QUOTED_TEXT
	| TIME_SYMBOL SINGLE_QUOTED_TEXT
	| TIMESTAMP_SYMBOL SINGLE_QUOTED_TEXT
;

// Support for INT1, INT2 etc. is added by mapping them to their explicitly named integer counter part.
// See lexer rules for INT1 etc.
integer_type:
	INT_SYMBOL
	| TINYINT_SYMBOL
	| SMALLINT_SYMBOL
	| MEDIUMINT_SYMBOL
	| BIGINT_SYMBOL
;

real_literal:
	REAL_SYMBOL | DOUBLE_SYMBOL PRECISION_SYMBOL?
;

float_options:
	// Another way to write (field_length | precision), but without ambiguity.
	OPEN_PAR_SYMBOL INTEGER (COMMA_SYMBOL INTEGER)? CLOSE_PAR_SYMBOL
;

precision:
	OPEN_PAR_SYMBOL INTEGER COMMA_SYMBOL INTEGER CLOSE_PAR_SYMBOL
;

nchar_literal:
	NCHAR_SYMBOL
	| {LA(3) != VARYING_SYMBOL}? NATIONAL_SYMBOL CHAR_SYMBOL // Predicate to solve ambiguity with nvarchar_literal.
;

varchar_literal:
	CHAR_SYMBOL VARYING_SYMBOL
	| VARCHAR_SYMBOL
;

nvarchar_literal:
	NATIONAL_SYMBOL VARCHAR_SYMBOL
	| NVARCHAR_SYMBOL
	| NCHAR_SYMBOL VARCHAR_SYMBOL
	| NATIONAL_SYMBOL CHAR_SYMBOL VARYING_SYMBOL
	| NCHAR_SYMBOL VARYING_SYMBOL
;

int_or_param_marker:
	INTEGER | PARAM_MARKER
;

text_or_param_marker:
	string_literal | PARAM_MARKER
;

text_or_identifier:
	string_literal
	| identifier
	//| USER_VARIABLE // LEX_HOSTNAME in the server grammar.
;

float_or_param:
	FLOAT | PARAM_MARKER
;

// Any integer number (no float) up to 64bits (real_ulong_num in sql_yacc.yy).
number:
	INTEGER
	| HEXNUMBER
;

size_number:
	INTEGER
	| HEXNUMBER
	| IDENTIFIER // Something like 10G. Semantic check needed for validity.
;

parentheses:
	OPEN_PAR_SYMBOL CLOSE_PAR_SYMBOL
;

equal:
	EQUAL_OPERATOR | ASSIGN_OPERATOR
;

option_type:
	GLOBAL_SYMBOL | LOCAL_SYMBOL | SESSION_SYMBOL
;

// Keyword that we allow for identifiers.
// Keywords defined only for specific server versions are handled at lexer level and so cannot match this rule
// if the current server version doesn't allow them. Hence we don't need predicates here for them.
keyword:
	keyword_sp
	| ( // Leave this list in parentheses, as this makes a difference of several MB in the resulting parser.
	    // (at least in the C target).
		ASCII_SYMBOL
		| BACKUP_SYMBOL
		| BEGIN_SYMBOL
		| BYTE_SYMBOL
		| CACHE_SYMBOL
		| CHARSET_SYMBOL
		| CHECKSUM_SYMBOL
		| CLOSE_SYMBOL
		| COMMENT_SYMBOL
		| COMMIT_SYMBOL
		| CONTAINS_SYMBOL
		| DEALLOCATE_SYMBOL
		| DO_SYMBOL
		| END_SYMBOL
		| EXECUTE_SYMBOL
		| FLUSH_SYMBOL
		| FOLLOWS_SYMBOL
		| FORMAT_SYMBOL
		| HANDLER_SYMBOL
		| HELP_SYMBOL
		| HOST_SYMBOL
		| INSTALL_SYMBOL
		| LANGUAGE_SYMBOL
		| NO_SYMBOL
		| OPEN_SYMBOL
		| OPTIONS_SYMBOL
		| OWNER_SYMBOL
		| PARSER_SYMBOL
		| PARTITION_SYMBOL
		| PORT_SYMBOL
		| PRECEDES_SYMBOL
		| PREPARE_SYMBOL
		| REMOVE_SYMBOL
		| REPAIR_SYMBOL
		| RESET_SYMBOL
		| RESTORE_SYMBOL
		| ROLLBACK_SYMBOL
		| SAVEPOINT_SYMBOL
		| SECURITY_SYMBOL
		| SERVER_SYMBOL
		| SIGNED_SYMBOL
		| SLAVE_SYMBOL
		| SOCKET_SYMBOL
		| SONAME_SYMBOL
		| START_SYMBOL
		| STOP_SYMBOL
		| TRUNCATE_SYMBOL
		| UNICODE_SYMBOL
		| UNINSTALL_SYMBOL
		| UPGRADE_SYMBOL
		| WRAPPER_SYMBOL
		| XA_SYMBOL
	)
;
finally
{
	// This part is quite ugly but there are limitations in the C target generator which prevent us
	// from using the target neutral constructs to change the token type.
	retval.start->setType(retval.start, IDENTIFIER);
}

// Comment from server yacc grammar:
//   Keywords that we allow for labels in SPs. Anything that's the beginning of a statement
//   or characteristics must be in keyword above, otherwise we get (harmful) shift/reduce conflicts.
// Additionally:
//   The keywords are only roughly sorted to stay with the same order as in sql_yacc.yy (for simpler diff'ing).
keyword_sp:
	ACTION_SYMBOL
	| ADDDATE_SYMBOL
	| AFTER_SYMBOL
	| AGAINST_SYMBOL
	| AGGREGATE_SYMBOL
	| ALGORITHM_SYMBOL
	| ANALYZE_SYMBOL
	| ANY_SYMBOL
	| AT_SYMBOL
	| AUTHORS_SYMBOL
	| AUTO_INCREMENT_SYMBOL
	| AUTOEXTEND_SIZE_SYMBOL
	| AVG_ROW_LENGTH_SYMBOL
	| AVG_SYMBOL
	| BINLOG_SYMBOL
	| BIT_SYMBOL
	| BLOCK_SYMBOL
	| BOOL_SYMBOL
	| BOOLEAN_SYMBOL
	| BTREE_SYMBOL
	| CASCADED_SYMBOL
	| CATALOG_NAME_SYMBOL
	| CHAIN_SYMBOL
	| CHANGED_SYMBOL
	| CIPHER_SYMBOL
	| CLIENT_SYMBOL
	| CLASS_ORIGIN_SYMBOL
	| COALESCE_SYMBOL
	| CODE_SYMBOL
	| COLLATION_SYMBOL
	| COLUMN_NAME_SYMBOL
	| COLUMN_FORMAT_SYMBOL
	| COLUMNS_SYMBOL
	| COMMITTED_SYMBOL
	| COMPACT_SYMBOL
	| COMPLETION_SYMBOL
	| COMPRESSED_SYMBOL
	| CONCURRENT_SYMBOL
	| CONNECTION_SYMBOL
	| CONSISTENT_SYMBOL
	| CONSTRAINT_CATALOG_SYMBOL
	| CONSTRAINT_SCHEMA_SYMBOL
	| CONSTRAINT_NAME_SYMBOL
	| CONTEXT_SYMBOL
	| CONTRIBUTORS_SYMBOL
	| CPU_SYMBOL
	| CUBE_SYMBOL
	| CURRENT_SYMBOL
	| CURSOR_NAME_SYMBOL
	| DATA_SYMBOL
	| DATAFILE_SYMBOL
	| DATETIME_SYMBOL
	| DATE_SYMBOL
	| DAY_SYMBOL
	| DEFAULT_AUTH_SYMBOL
	| DEFINER_SYMBOL
	| DELAY_KEY_WRITE_SYMBOL
	| DES_KEY_FILE_SYMBOL
	| DIAGNOSTICS_SYMBOL
	| DIRECTORY_SYMBOL
	| DISABLE_SYMBOL
	| DISCARD_SYMBOL
	| DISK_SYMBOL
	| DUMPFILE_SYMBOL
	| DUPLICATE_SYMBOL
	| DYNAMIC_SYMBOL
	| ENDS_SYMBOL
	| ENUM_SYMBOL
	| ENGINE_SYMBOL
	| ENGINES_SYMBOL
	| ERROR_SYMBOL
	| ERRORS_SYMBOL
	| ESCAPE_SYMBOL
	| EVENT_SYMBOL
	| EVENTS_SYMBOL
	| EVERY_SYMBOL
	| EXPANSION_SYMBOL
	| EXPORT_SYMBOL
	| EXTENDED_SYMBOL
	| EXTENT_SIZE_SYMBOL
	| FAULTS_SYMBOL
	| FAST_SYMBOL
	| FOUND_SYMBOL
	| ENABLE_SYMBOL
	| FULL_SYMBOL
	| FILE_SYMBOL
	| FILTER_SYMBOL
	| FIRST_SYMBOL
	| FIXED_SYMBOL
	| GENERAL_SYMBOL
	| GEOMETRY_SYMBOL
	| GEOMETRYCOLLECTION_SYMBOL
	| GET_FORMAT_SYMBOL
	| GRANTS_SYMBOL
	| GLOBAL_SYMBOL
	| HASH_SYMBOL
	| HOSTS_SYMBOL
	| HOUR_SYMBOL
	| IDENTIFIED_SYMBOL
	| IGNORE_SERVER_IDS_SYMBOL
	| INVOKER_SYMBOL
	| IMPORT_SYMBOL
	| INDEXES_SYMBOL
	| INITIAL_SIZE_SYMBOL
	| INNODB_SYMBOL // Conditionally deprecated in the lexer rule.
	| IO_SYMBOL
	| IPC_SYMBOL
	| ISOLATION_SYMBOL
	| ISSUER_SYMBOL
	| INSERT_METHOD_SYMBOL
	| KEY_BLOCK_SIZE_SYMBOL
	| LAST_SYMBOL
	| LEAVES_SYMBOL
	| LESS_SYMBOL
	| LEVEL_SYMBOL
	| LINESTRING_SYMBOL
	| LIST_SYMBOL
	| LOCAL_SYMBOL
	| LOCKS_SYMBOL
	| LOGFILE_SYMBOL
	| LOGS_SYMBOL
	| MAX_ROWS_SYMBOL
	| MASTER_SYMBOL
	| MASTER_HEARTBEAT_PERIOD_SYMBOL
	| MASTER_HOST_SYMBOL
	| MASTER_PORT_SYMBOL
	| MASTER_LOG_FILE_SYMBOL
	| MASTER_LOG_POS_SYMBOL
	| MASTER_USER_SYMBOL
	| MASTER_PASSWORD_SYMBOL
	| MASTER_SERVER_ID_SYMBOL
	| MASTER_CONNECT_RETRY_SYMBOL
	| MASTER_RETRY_COUNT_SYMBOL
	| MASTER_DELAY_SYMBOL
	| MASTER_SSL_SYMBOL
	| MASTER_SSL_CA_SYMBOL
	| MASTER_SSL_CAPATH_SYMBOL
	| MASTER_SSL_CERT_SYMBOL
	| MASTER_SSL_CIPHER_SYMBOL
	| MASTER_SSL_CRL_SYMBOL
	| MASTER_SSL_CRLPATH_SYMBOL
	| MASTER_SSL_KEY_SYMBOL
	| MASTER_AUTO_POSITION_SYMBOL
	| MAX_CONNECTIONS_PER_HOUR_SYMBOL
	| MAX_QUERIES_PER_HOUR_SYMBOL
	| MAX_STATEMENT_TIME_SYMBOL
	| MAX_SIZE_SYMBOL
	| MAX_UPDATES_PER_HOUR_SYMBOL
	| MAX_USER_CONNECTIONS_SYMBOL
	| MEDIUM_SYMBOL
	| MEMORY_SYMBOL
	| MERGE_SYMBOL
	| MESSAGE_TEXT_SYMBOL
	| MICROSECOND_SYMBOL
	| MIGRATE_SYMBOL
	| MINUTE_SYMBOL
	| MIN_ROWS_SYMBOL
	| MODIFY_SYMBOL
	| MODE_SYMBOL
	| MONTH_SYMBOL
	| MULTILINESTRING_SYMBOL
	| MULTIPOINT_SYMBOL
	| MULTIPOLYGON_SYMBOL
	| MUTEX_SYMBOL
	| MYSQL_ERRNO_SYMBOL
	| NAME_SYMBOL
	| NAMES_SYMBOL
	| NATIONAL_SYMBOL
	| NCHAR_SYMBOL
	| NDBCLUSTER_SYMBOL
	| NEVER_SYMBOL
	| NEXT_SYMBOL
	| NEW_SYMBOL
	| NO_WAIT_SYMBOL
	| NODEGROUP_SYMBOL
	| NONE_SYMBOL
	| NUMBER_SYMBOL
	| NVARCHAR_SYMBOL
	| OFFSET_SYMBOL
	| OLD_PASSWORD_SYMBOL
	| ONE_SHOT_SYMBOL
	| ONE_SYMBOL
	| PACK_KEYS_SYMBOL
	| PAGE_SYMBOL
	| PARTIAL_SYMBOL
	| PARTITIONING_SYMBOL
	| PARTITIONS_SYMBOL
	| PASSWORD_SYMBOL
	| PHASE_SYMBOL
	| PLUGIN_DIR_SYMBOL
	| PLUGIN_SYMBOL
	| PLUGINS_SYMBOL
	| POINT_SYMBOL
	| POLYGON_SYMBOL
	| PRESERVE_SYMBOL
	| PREV_SYMBOL
	| PRIVILEGES_SYMBOL
	| PROCESS_SYMBOL
	| PROCESSLIST_SYMBOL
	| PROFILE_SYMBOL
	| PROFILES_SYMBOL
	| PROXY_SYMBOL
	| QUARTER_SYMBOL
	| QUERY_SYMBOL
	| QUICK_SYMBOL
	| READ_ONLY_SYMBOL
	| REBUILD_SYMBOL
	| RECOVER_SYMBOL
	| REDO_BUFFER_SIZE_SYMBOL
	| REDOFILE_SYMBOL
	| REDUNDANT_SYMBOL
	| RELAY_SYMBOL
	| RELAYLOG_SYMBOL
	| RELAY_LOG_FILE_SYMBOL
	| RELAY_LOG_POS_SYMBOL
	| RELAY_THREAD_SYMBOL
	| RELOAD_SYMBOL
	| REORGANIZE_SYMBOL
	| REPEATABLE_SYMBOL
	| REPLICATION_SYMBOL
	| REPLICATE_DO_DB_SYMBOL
	| REPLICATE_IGNORE_DB_SYMBOL
	| REPLICATE_DO_TABLE_SYMBOL
	| REPLICATE_IGNORE_TABLE_SYMBOL
	| REPLICATE_WILD_DO_TABLE_SYMBOL
	| REPLICATE_WILD_IGNORE_TABLE_SYMBOL
	| REPLICATE_REWRITE_DB_SYMBOL
	| RESUME_SYMBOL
	| RETURNED_SQLSTATE_SYMBOL
	| RETURNS_SYMBOL
	| REVERSE_SYMBOL
	| ROLLUP_SYMBOL
	| ROUTINE_SYMBOL
	| ROWS_SYMBOL
	| ROW_COUNT_SYMBOL
	| ROW_FORMAT_SYMBOL
	| ROW_SYMBOL
	| RTREE_SYMBOL
	| SCHEDULE_SYMBOL
	| SCHEMA_NAME_SYMBOL
	| SECOND_SYMBOL
	| SERIAL_SYMBOL
	| SERIALIZABLE_SYMBOL
	| SESSION_SYMBOL
	| SIMPLE_SYMBOL
	| SHARE_SYMBOL
	| SHUTDOWN_SYMBOL
	| SLOW_SYMBOL
	| SNAPSHOT_SYMBOL
	| SOUNDS_SYMBOL
	| SOURCE_SYMBOL
	| SQL_AFTER_GTIDS_SYMBOL
	| SQL_AFTER_MTS_GAPS_SYMBOL
	| SQL_BEFORE_GTIDS_SYMBOL
	| SQL_CACHE_SYMBOL
	| SQL_BUFFER_RESULT_SYMBOL
	| SQL_NO_CACHE_SYMBOL
	| SQL_THREAD_SYMBOL
	| STACKED_SYMBOL
	| STARTS_SYMBOL
	| STATS_AUTO_RECALC_SYMBOL
	| STATS_PERSISTENT_SYMBOL
	| STATS_SAMPLE_PAGES_SYMBOL
	| STATUS_SYMBOL
	| STORAGE_SYMBOL
	| STRING_SYMBOL
	| SUBCLASS_ORIGIN_SYMBOL
	| SUBDATE_SYMBOL
	| SUBJECT_SYMBOL
	| SUBPARTITION_SYMBOL
	| SUBPARTITIONS_SYMBOL
	| SUPER_SYMBOL
	| SUSPEND_SYMBOL
	| SWAPS_SYMBOL
	| SWITCHES_SYMBOL
	| TABLE_NAME_SYMBOL
	| TABLES_SYMBOL
	| TABLE_CHECKSUM_SYMBOL
	| TABLESPACE_SYMBOL
	| TEMPORARY_SYMBOL
	| TEMPTABLE_SYMBOL
	| TEXT_SYMBOL
	| THAN_SYMBOL
	| TRANSACTION_SYMBOL
	| TRIGGERS_SYMBOL
	| TIMESTAMP_SYMBOL
	| TIMESTAMP_ADD_SYMBOL
	| TIMESTAMP_DIFF_SYMBOL
	| TIME_SYMBOL
	| TYPES_SYMBOL
	| TYPE_SYMBOL
	| UDF_RETURNS_SYMBOL
	| FUNCTION_SYMBOL
	| UNCOMMITTED_SYMBOL
	| UNDEFINED_SYMBOL
	| UNDO_BUFFER_SIZE_SYMBOL
	| UNDOFILE_SYMBOL
	| UNKNOWN_SYMBOL
	| UNTIL_SYMBOL
	| USER_RESOURCES_SYMBOL
	| USER_SYMBOL
	| USE_FRM_SYMBOL
	| VARIABLES_SYMBOL
	| VIEW_SYMBOL
	| VALUE_SYMBOL
	| WARNINGS_SYMBOL
	| WAIT_SYMBOL
	| WEEK_SYMBOL
	| WORK_SYMBOL
	| WEIGHT_STRING_SYMBOL
	| X509_SYMBOL
	| XID_SYMBOL
	| XML_SYMBOL
	| YEAR_SYMBOL
;
finally
{
	retval.start->setType(retval.start, IDENTIFIER);
}
        
//----- Lexer tokens -------------------------------------------------------------------------------

// Operators
EQUAL_OPERATOR:				'=';  // Also assign.
ASSIGN_OPERATOR:			':=';
NULL_SAFE_EQUAL_OPERATOR:	'<=>';
GREATER_OR_EQUAL_OPERATOR:	'>=';
GREATER_THAN_OPERATOR:		'>';
LESS_OR_EQUAL_OPERATOR:		'<=';
LESS_THAN_OPERATOR:			'<';
NOT_EQUAL_OPERATOR:			'!=';
NOT_EQUAL2_OPERATOR:		'<>';

PLUS_OPERATOR:				'+';
MINUS_OPERATOR:				'-';
MULT_OPERATOR:				'*';
DIV_OPERATOR:				'/';

MOD_OPERATOR:				'%';

LOGICAL_NOT_OPERATOR:		'!';
BITWISE_NOT_OPERATOR:		'~';

SHIFT_LEFT_OPERATOR:		'<<';
SHIFT_RIGHT_OPERATOR:		'>>';

LOGICAL_AND_OPERATOR:		'&&';
BITWISE_AND_OPERATOR:		'&';

BITWISE_XOR_OPERATOR:		'^';

LOGICAL_OR_OPERATOR:		'||'	{ $type = SQL_MODE_ACTIVE(SQL_MODE_PIPES_AS_CONCAT) ? CONCAT_PIPES_SYMBOL : $type; };
BITWISE_OR_OPERATOR:		'|';

DOT_SYMBOL:					'.';
COMMA_SYMBOL:				',';
SEMICOLON_SYMBOL:			';';
COLON_SYMBOL:				':';
OPEN_PAR_SYMBOL:			'(';
CLOSE_PAR_SYMBOL:			')';
OPEN_CURLY_SYMBOL:			'{';
CLOSE_CURLY_SYMBOL:			'}';
UNDERLINE_SYMBOL:			'_';

// The MySQL parser uses custom code in its lexer to allow base alphanum chars (and ._$) as variable name.
// For this it handles user variables in 2 different ways and we have to model this to match that behavior.
AT_SIGN_SYMBOL:				'@' ((SIMPLE_IDENTIFIER) => SIMPLE_IDENTIFIER { $type = AT_TEXT_SUFFIX; } )?;

AT_AT_SIGN_SYMBOL:			'@@';

NULL2_SYMBOL:				'\\N'	{ $type = check_null($text); };
PARAM_MARKER:				'?';
BACK_TICK:					'`';
SINGLE_QUOTE:				'\'';
DOUBLE_QUOTE:				'"';
ESCAPE_OPERATOR:			'\\';

// $<Keywords 

/*
   Comments for TOKENS.
   For each token, please include in the same line a comment that contains
   the following tags_SYMBOL:
   SQL-2003-R _SYMBOL: Reserved keyword as per SQL-2003
   SQL-2003-N _SYMBOL: Non Reserved keyword as per SQL-2003
   SQL-1999-R _SYMBOL: Reserved keyword as per SQL-1999
   SQL-1999-N _SYMBOL: Non Reserved keyword as per SQL-1999
   MYSQL      _SYMBOL: MySQL extention (unspecified)
   MYSQL-FUNC _SYMBOL: MySQL extention, function
   INTERNAL   _SYMBOL: Not a real token, lex optimization
   OPERATOR   _SYMBOL: SQL operator
   FUTURE-USE _SYMBOL: Reserved for futur use

   This makes the code grep-able, and helps maintenance.
*/

//ABORT_SYMBOL:	'ABORT';                     // INTERNAL (used in lex)
ACCESSIBLE_SYMBOL:						'ACCESSIBLE'						{ $type = TYPE_FROM_VERSION(50100, $type); };
ACTION_SYMBOL:							'ACTION';							// SQL-2003-N
ADD_SYMBOL:								'ADD';								// SQL-2003-R
ADDDATE_SYMBOL:							'ADDDATE'							{ $type = determine_function(ctx, $type); }; // MYSQL-FUNC
AFTER_SYMBOL:							'AFTER';							// SQL-2003-N
AGAINST_SYMBOL:							'AGAINST';
AGGREGATE_SYMBOL:						'AGGREGATE';
ALGORITHM_SYMBOL:						'ALGORITHM';
ALL_SYMBOL:								'ALL';								// SQL-2003-R
ALTER_SYMBOL:							'ALTER';							// SQL-2003-R
ANALYSE_SYMBOL:							'ANALYSE';
ANALYZE_SYMBOL:							'ANALYZE';
AND_SYMBOL:								'AND';								// SQL-2003-R
ANY_SYMBOL:								'ANY';								// SQL-2003-R
AS_SYMBOL:								'AS';								// SQL-2003-R
ASC_SYMBOL:								'ASC';								// SQL-2003-N
ASCII_SYMBOL:							'ASCII';							// MYSQL-FUNC
ASENSITIVE_SYMBOL:						'ASENSITIVE'						{ $type = TYPE_FROM_VERSION(50000, $type); }; // FUTURE-USE
AT_SYMBOL:								'AT';
AUTHORS_SYMBOL:							'AUTHORS'							{ $type = DEPRECATED_TYPE_FROM_VERSION(50700, $type); };
AUTOEXTEND_SIZE_SYMBOL:					'AUTOEXTEND_SIZE';
AUTO_INCREMENT_SYMBOL:					'AUTO_INCREMENT';
AVG_ROW_LENGTH_SYMBOL:					'AVG_ROW_LENGTH';
AVG_SYMBOL:								'AVG';								// SQL-2003-N
BACKUP_SYMBOL:							'BACKUP';
BEFORE_SYMBOL:							'BEFORE'							{ $type = TYPE_FROM_VERSION(40100, $type); }; // SQL-2003-N
BEGIN_SYMBOL:							'BEGIN';							// SQL-2003-R
BETWEEN_SYMBOL:							'BETWEEN';							// SQL-2003-R
BIGINT_SYMBOL:							'BIGINT';							// SQL-2003-R
BINARY_SYMBOL:							'BINARY';							// SQL-2003-R
BINLOG_SYMBOL:							'BINLOG';
BIN_NUM_SYMBOL:							'BIN_NUM';
BIT_AND_SYMBOL:							'BIT_AND'							{ $type = determine_function(ctx, $type); }; // MYSQL-FUNC
BIT_OR_SYMBOL:							'BIT_OR'							{ $type = determine_function(ctx, $type); }; // MYSQL-FUNC
BIT_SYMBOL:								'BIT';								// MYSQL-FUNC
BIT_XOR_SYMBOL:							'BIT_XOR'							{ $type = determine_function(ctx, $type); }; // MYSQL-FUNC
BLOB_SYMBOL:							'BLOB';								// SQL-2003-R
BLOCK_SYMBOL:							'BLOCK';
BOOLEAN_SYMBOL:							'BOOLEAN';							// SQL-2003-R
BOOL_SYMBOL:							'BOOL';
BOTH_SYMBOL:							'BOTH';								// SQL-2003-R
BTREE_SYMBOL:							'BTREE';
BY_SYMBOL:								'BY';								// SQL-2003-R
BYTE_SYMBOL:							'BYTE';
CACHE_SYMBOL:							'CACHE';
CALL_SYMBOL:							'CALL'								{ $type = TYPE_FROM_VERSION(50000, $type); };	// SQL-2003-R
CASCADE_SYMBOL:							'CASCADE';							// SQL-2003-N
CASCADED_SYMBOL:						'CASCADED';							// SQL-2003-R
CASE_SYMBOL:							'CASE';								// SQL-2003-R
CAST_SYMBOL:							'CAST'								{ $type = determine_function(ctx, $type); }; // SQL-2003-R
CATALOG_NAME_SYMBOL:					'CATALOG_NAME';						// SQL-2003-N
CHAIN_SYMBOL:							'CHAIN';							// SQL-2003-N
CHANGE_SYMBOL:							'CHANGE';
CHANGED_SYMBOL:							'CHANGED';
CHARSET_SYMBOL:							'CHARSET';
CHARACTER_SYMBOL:						'CHARACTER'							{ $type = CHAR_SYMBOL; }; // Synonym
CHAR_SYMBOL:							'CHAR';								// SQL-2003-R
CHECKSUM_SYMBOL:						'CHECKSUM';
CHECK_SYMBOL:							'CHECK'								{ $type = TYPE_FROM_VERSION(40000, $type); };	// SQL-2003-R
CIPHER_SYMBOL:							'CIPHER';
CLASS_ORIGIN_SYMBOL:					'CLASS_ORIGIN';						// SQL-2003-N
CLIENT_SYMBOL:							'CLIENT';
CLOSE_SYMBOL:							'CLOSE';							// SQL-2003-R
COALESCE_SYMBOL:						'COALESCE';							// SQL-2003-N
CODE_SYMBOL:							'CODE';
COLLATE_SYMBOL:							'COLLATE'							{ $type = TYPE_FROM_VERSION(40100, $type); }; // SQL-2003-R
COLLATION_SYMBOL:						'COLLATION';						// SQL-2003-N
COLUMNS_SYMBOL:							'COLUMNS';
COLUMN_SYMBOL:							'COLUMN';							// SQL-2003-R
COLUMN_NAME_SYMBOL:						'COLUMN_NAME';						// SQL-2003-N
COLUMN_FORMAT_SYMBOL:					'COLUMN_FORMAT'						{ $type = TYPE_FROM_VERSION(50600, $type); }; // Said to be available only in MySQL cluster, but nonetheless handled in the standard server parser as well.
COMMENT_SYMBOL:							'COMMENT';
COMMITTED_SYMBOL:						'COMMITTED';						// SQL-2003-N
COMMIT_SYMBOL:							'COMMIT';							// SQL-2003-R
COMPACT_SYMBOL:							'COMPACT';
COMPLETION_SYMBOL:						'COMPLETION';
COMPRESSED_SYMBOL:						'COMPRESSED';
CONCURRENT_SYMBOL:						'CONCURRENT';
CONDITION_SYMBOL:						'CONDITION'							{ $type = TYPE_FROM_VERSION(50000, $type); }; // SQL-2003-R, SQL-2008-R
CONNECTION_SYMBOL:						'CONNECTION'						{ $type = TYPE_FROM_VERSION(50000, $type); };
CONSISTENT_SYMBOL:						'CONSISTENT';
CONSTRAINT_SYMBOL:						'CONSTRAINT';						// SQL-2003-R
CONSTRAINT_CATALOG_SYMBOL:				'CONSTRAINT_CATALOG';				// SQL-2003-N
CONSTRAINT_NAME_SYMBOL:					'CONSTRAINT_NAME';					// SQL-2003-N
CONSTRAINT_SCHEMA_SYMBOL:				'CONSTRAINT_SCHEMA';				// SQL-2003-N
CONTAINS_SYMBOL:						'CONTAINS';							// SQL-2003-N
CONTEXT_SYMBOL:							'CONTEXT';
CONTINUE_SYMBOL:						'CONTINUE'							{ $type = TYPE_FROM_VERSION(50000, $type); };	// SQL-2003-R
CONTRIBUTORS_SYMBOL:					'CONTRIBUTORS'						{ $type = DEPRECATED_TYPE_FROM_VERSION(50700, $type); };
CONVERT_SYMBOL:							'CONVERT'							{ $type = TYPE_FROM_VERSION(40100, $type); }; // SQL-2003-N
COUNT_SYMBOL:							'COUNT'								{ $type = determine_function(ctx, $type); }; // SQL-2003-N
CPU_SYMBOL:								'CPU';
CREATE_SYMBOL:							'CREATE';							// SQL-2003-R
CROSS_SYMBOL:							'CROSS';							// SQL-2003-R
CUBE_SYMBOL:							'CUBE';								// SQL-2003-R
CURDATE_SYMBOL:							'CURDATE'							{ $type = determine_function(ctx, $type); }; // MYSQL-FUNC
CURRENT_SYMBOL:							'CURRENT'							{ $type = TYPE_FROM_VERSION(50604, $type); };
CURRENT_TIMESTAMP_SYMBOL:				'CURRENT_TIMESTAMP'					{ $type = NOW_SYMBOL; }; // Synonym
CURRENT_USER_SYMBOL:					'CURRENT_USER'						{ $type = TYPE_FROM_VERSION(40100, $type); }; // SQL-2003-R
CURSOR_SYMBOL:							'CURSOR'							{ $type = TYPE_FROM_VERSION(50000, $type); };	// SQL-2003-R
CURSOR_NAME_SYMBOL:						'CURSOR_NAME';						// SQL-2003-N
CURTIME_SYMBOL:							'CURTIME'							{ $type = determine_function(ctx, $type); }; // MYSQL-FUNC
DATABASE_SYMBOL:						'DATABASE';
DATABASES_SYMBOL:						'DATABASES';
DATAFILE_SYMBOL:						'DATAFILE';
DATA_SYMBOL:							'DATA';								// SQL-2003-N
DATETIME_SYMBOL:						'DATETIME';
DATE_ADD_SYMBOL:						'DATE_ADD'							{ $type = determine_function(ctx, $type); }; 
DATE_ADD_INTERVAL_SYMBOL:				'DATE_ADD_INTERVAL';				// MYSQL-FUNC
DATE_SUB_SYMBOL:						'DATE_SUB'							{ $type = determine_function(ctx, $type); }; 
DATE_SUB_INTERVAL_SYMBOL:				'DATE_SUB_INTERVAL';				// MYSQL-FUNC
DATE_SYMBOL:							'DATE';								// SQL-2003-R
DAYOFMONTH_SYMBOL:						'DAYOFMONTH'						{ $type = DAY_SYMBOL; }; // Synonym
DAY_HOUR_SYMBOL:						'DAY_HOUR';
DAY_MICROSECOND_SYMBOL:					'DAY_MICROSECOND'					{ $type = TYPE_FROM_VERSION(40100, $type); };
DAY_MINUTE_SYMBOL:						'DAY_MINUTE';
DAY_SECOND_SYMBOL:						'DAY_SECOND';
DAY_SYMBOL:								'DAY';								// SQL-2003-R
DEALLOCATE_SYMBOL:						'DEALLOCATE';						// SQL-2003-R
DEC_SYMBOL:								'DEC'								{ $type = DECIMAL_SYMBOL; };	// Synonym
DECIMAL_NUM_SYMBOL:						'DECIMAL_NUM';
DECIMAL_SYMBOL:							'DECIMAL';							// SQL-2003-R
DECLARE_SYMBOL:							'DECLARE'							{ $type = TYPE_FROM_VERSION(50000, $type); }; // SQL-2003-R
DEFAULT_SYMBOL:							'DEFAULT';							// SQL-2003-R
DEFAULT_AUTH_SYMBOL:					'DEFAULT_AUTH'						{ $type = TYPE_FROM_VERSION(50604, $type); }; // Internal
DEFINER_SYMBOL:							'DEFINER';
DELAYED_SYMBOL:							'DELAYED';
DELAY_KEY_WRITE_SYMBOL:					'DELAY_KEY_WRITE';
DELETE_SYMBOL:							'DELETE';							// SQL-2003-R
DESC_SYMBOL:							'DESC';								// SQL-2003-N
DESCRIBE_SYMBOL:						'DESCRIBE';							// SQL-2003-R
DES_KEY_FILE_SYMBOL:					'DES_KEY_FILE';
DETERMINISTIC_SYMBOL:					'DETERMINISTIC'						{ $type = TYPE_FROM_VERSION(50000, $type); }; // SQL-2003-R
DIAGNOSTICS_SYMBOL:						'DIAGNOSTICS'						{ $type = TYPE_FROM_VERSION(50600, $type); };
DIRECTORY_SYMBOL:						'DIRECTORY';
DISABLE_SYMBOL:							'DISABLE';
DISCARD_SYMBOL:							'DISCARD';
DISK_SYMBOL:							'DISK';
DISTINCT_SYMBOL:						'DISTINCT';							// SQL-2003-R
DISTINCTROW_SYMBOL:						'DISTINCTROW'						{ $type = DISTINCT_SYMBOL; };	// Synonym
DIV_SYMBOL:								'DIV'								{ $type = TYPE_FROM_VERSION(40100, $type); };
DOUBLE_SYMBOL:							'DOUBLE';							// SQL-2003-R
DO_SYMBOL:								'DO';
DROP_SYMBOL:							'DROP';								// SQL-2003-R
DUAL_SYMBOL:							'DUAL'								{ $type = TYPE_FROM_VERSION(40100, $type); };
DUMPFILE_SYMBOL:						'DUMPFILE';
DUPLICATE_SYMBOL:						'DUPLICATE';
DYNAMIC_SYMBOL:							'DYNAMIC';							// SQL-2003-R
EACH_SYMBOL:							'EACH'								{ $type = TYPE_FROM_VERSION(50000, $type); }; // SQL-2003-R
ELSE_SYMBOL:							'ELSE';								// SQL-2003-R
ELSEIF_SYMBOL:							'ELSEIF'							{ $type = TYPE_FROM_VERSION(50000, $type); };
ENABLE_SYMBOL:							'ENABLE';
ENCLOSED_SYMBOL:						'ENCLOSED';
END_SYMBOL:								'END';								// SQL-2003-R
ENDS_SYMBOL:							'ENDS';
END_OF_INPUT_SYMBOL:					'END_OF_INPUT';						// INTERNAL
ENGINES_SYMBOL:							'ENGINES';
ENGINE_SYMBOL:							'ENGINE';
ENUM_SYMBOL:							'ENUM';
ERROR_SYMBOL:							'ERROR';
ERRORS_SYMBOL:							'ERRORS';
ESCAPED_SYMBOL:							'ESCAPED';
ESCAPE_SYMBOL:							'ESCAPE';							// SQL-2003-R
EVENTS_SYMBOL:							'EVENTS';
EVENT_SYMBOL:							'EVENT';
EVERY_SYMBOL:							'EVERY';							// SQL-2003-N
EXCHANGE_SYMBOL:						'EXCHANGE'							{ $type = TYPE_FROM_VERSION(50600, $type); };
EXECUTE_SYMBOL:							'EXECUTE';							// SQL-2003-R
EXISTS_SYMBOL:							'EXISTS';							// SQL-2003-R
EXIT_SYMBOL:							'EXIT'								{ $type = TYPE_FROM_VERSION(50000, $type); };
EXPANSION_SYMBOL:						'EXPANSION';
EXPIRE_SYMBOL:							'EXPIRE'							{ $type = TYPE_FROM_VERSION(50606, $type); };
EXPLAIN_SYMBOL:							'EXPLAIN'							{ $type = DESCRIBE_SYMBOL; }; // SQL-2003-R
EXPORT_SYMBOL:							'EXPORT'							{ $type = TYPE_FROM_VERSION(50606, $type); };
EXTENDED_SYMBOL:						'EXTENDED';
EXTENT_SIZE_SYMBOL:						'EXTENT_SIZE';
EXTRACT_SYMBOL:							'EXTRACT'							{ $type = determine_function(ctx, $type); }; // SQL-2003-N
FALSE_SYMBOL:							'FALSE'								{ $type = TYPE_FROM_VERSION(40100, $type); };	// SQL-2003-R
FAST_SYMBOL:							'FAST';
FAULTS_SYMBOL:							'FAULTS';
FETCH_SYMBOL:							'FETCH'								{ $type = TYPE_FROM_VERSION(50000, $type); }; // SQL-2003-R
FIELDS_SYMBOL:							'FIELDS'							{ $type = COLUMNS_SYMBOL; };	// Synonym
FILE_SYMBOL:							'FILE';
FILTER_SYMBOL:							'FILTER'							{ $type = TYPE_FROM_VERSION(50700, $type); };
FIRST_SYMBOL:							'FIRST';							// SQL-2003-N
FIXED_SYMBOL:							'FIXED';
FLOAT4_SYMBOL:							'FLOAT4'							{ $type = FLOAT_SYMBOL; }; // Synonym
FLOAT8_SYMBOL:							'FLOAT8'							{ $type = DOUBLE_SYMBOL; }; // Synonym
FLOAT_SYMBOL:							'FLOAT';							// SQL-2003-R
FLUSH_SYMBOL:							'FLUSH';
FOLLOWS_SYMBOL:							'FOLLOWS'							{ $type = TYPE_FROM_VERSION(50700, $type); };
FORCE_SYMBOL:							'FORCE'								{ $type = TYPE_FROM_VERSION(40000, $type); };
FOREIGN_SYMBOL:							'FOREIGN';							// SQL-2003-R
FOR_SYMBOL:								'FOR';								// SQL-2003-R
FORMAT_SYMBOL:							'FORMAT'							{ $type = TYPE_FROM_VERSION(50600, $type); };
FOUND_SYMBOL:							'FOUND';							// SQL-2003-R
FRAC_SECOND_SYMBOL:						'FRAC_SECOND'						{ $type = DEPRECATED_TYPE_FROM_VERSION(50503, $type); };
FROM_SYMBOL:							'FROM';
FULL_SYMBOL:							'FULL';								// SQL-2003-R
FULLTEXT_SYMBOL:						'FULLTEXT';
FUNCTION_SYMBOL:						'FUNCTION';							// SQL-2003-R
GET_SYMBOL:								'GET'								{ $type = TYPE_FROM_VERSION(50600, $type); };
GENERAL_SYMBOL:							'GENERAL'							{ $type = TYPE_FROM_VERSION(50500, $type); };
GEOMETRYCOLLECTION_SYMBOL:				'GEOMETRYCOLLECTION';
GEOMETRY_SYMBOL:						'GEOMETRY';
GET_FORMAT_SYMBOL:						'GET_FORMAT';						// MYSQL-FUNC
GLOBAL_SYMBOL:							'GLOBAL';							// SQL-2003-R
GRANT_SYMBOL:							'GRANT';							// SQL-2003-R
GRANTS_SYMBOL:							'GRANTS';
GROUP_SYMBOL:							'GROUP';							// SQL-2003-R
GROUP_CONCAT_SYMBOL:					'GROUP_CONCAT'						{ $type = determine_function(ctx, $type); }; 
HANDLER_SYMBOL:							'HANDLER';
HASH_SYMBOL:							'HASH';
HAVING_SYMBOL:							'HAVING';							// SQL-2003-R
HELP_SYMBOL:							'HELP';
HIGH_PRIORITY_SYMBOL:					'HIGH_PRIORITY';
HOST_SYMBOL:							'HOST';
HOSTS_SYMBOL:							'HOSTS';
HOUR_MICROSECOND_SYMBOL:				'HOUR_MICROSECOND'					{ $type = TYPE_FROM_VERSION(40100, $type); };
HOUR_MINUTE_SYMBOL:						'HOUR_MINUTE';
HOUR_SECOND_SYMBOL:						'HOUR_SECOND';
HOUR_SYMBOL:							'HOUR';								// SQL-2003-R
IDENTIFIED_SYMBOL:						'IDENTIFIED';
IF_SYMBOL:								'IF';
IGNORE_SYMBOL:							'IGNORE';
IGNORE_SERVER_IDS_SYMBOL:				'IGNORE_SERVER_IDS'					{ $type = TYPE_FROM_VERSION(50500, $type); };
IMPORT_SYMBOL:							'IMPORT';
INDEXES_SYMBOL:							'INDEXES';
INDEX_SYMBOL:							'INDEX';
INFILE_SYMBOL:							'INFILE';
INITIAL_SIZE_SYMBOL:					'INITIAL_SIZE';
INNER_SYMBOL:							'INNER';							// SQL-2003-R
INNODB_SYMBOL:							'INNODB'							{ $type = SERVER_VERSION < 50100 ? $type : IDENTIFIER; }; // Deprecated in 5.1.
INOUT_SYMBOL:							'INOUT'								{ $type = TYPE_FROM_VERSION(50000, $type); }; // SQL-2003-R
INSENSITIVE_SYMBOL:						'INSENSITIVE'						{ $type = TYPE_FROM_VERSION(50000, $type); }; // SQL-2003-R
INSERT_SYMBOL:							'INSERT';							// SQL-2003-R
INSERT_METHOD_SYMBOL:					'INSERT_METHOD';
INSTALL_SYMBOL:							'INSTALL';
INTEGER_SYMBOL:							'INTEGER'							{ $type = INT_SYMBOL; }; // Synonym
INTERVAL_SYMBOL:						'INTERVAL';							// SQL-2003-R
INTO_SYMBOL:							'INTO';								// SQL-2003-R
INT_SYMBOL:								'INT';								// SQL-2003-R
INVOKER_SYMBOL:							'INVOKER';
IN_SYMBOL:								'IN';								// SQL-2003-R
IO_AFTER_GTIDS_SYMBOL:					'IO_AFTER_GTIDS'					{ $type = TYPE_FROM_VERSION(50600, $type); }; // MYSQL, FUTURE-USE
IO_BEFORE_GTIDS_SYMBOL:					'IO_BEFORE_GTIDS'					{ $type = TYPE_FROM_VERSION(50600, $type); }; // MYSQL, FUTURE-USE
IO_THREAD_SYMBOL:						'IO_THREAD'							{ $type = RELAY_THREAD_SYMBOL; }; // Synonym
IO_SYMBOL:								'IO';
IPC_SYMBOL:								'IPC';
IS_SYMBOL:								'IS';								// SQL-2003-R
ISOLATION_SYMBOL:						'ISOLATION';						// SQL-2003-R
ISSUER_SYMBOL:							'ISSUER';
ITERATE_SYMBOL:							'ITERATE'							{ $type = TYPE_FROM_VERSION(50000, $type); };
JOIN_SYMBOL:							'JOIN';								// SQL-2003-R
KEYS_SYMBOL:							'KEYS';
KEY_BLOCK_SIZE_SYMBOL:					'KEY_BLOCK_SIZE';
KEY_SYMBOL:								'KEY';								// SQL-2003-N
KILL_SYMBOL:							'KILL';
LANGUAGE_SYMBOL:						'LANGUAGE';							// SQL-2003-R
LAST_SYMBOL:							'LAST';								// SQL-2003-N
LEADING_SYMBOL:							'LEADING';							// SQL-2003-R
LEAVES_SYMBOL:							'LEAVES'							{ $type = TYPE_FROM_VERSION(50000, $type); };
LEAVE_SYMBOL:							'LEAVE';
LEFT_SYMBOL:							'LEFT';								// SQL-2003-R
LESS_SYMBOL:							'LESS';
LEVEL_SYMBOL:							'LEVEL';
LIKE_SYMBOL:							'LIKE';								// SQL-2003-R
LIMIT_SYMBOL:							'LIMIT';
LINEAR_SYMBOL:							'LINEAR'							{ $type = TYPE_FROM_VERSION(50100, $type); };
LINES_SYMBOL:							'LINES';
LINESTRING_SYMBOL:						'LINESTRING';
LIST_SYMBOL:							'LIST';
LOAD_SYMBOL:							'LOAD';
LOCALTIME_SYMBOL:						'LOCALTIME'							{ $type = TYPE_FROM_VERSION(40000, NOW_SYMBOL); }; //Synonym
LOCALTIMESTAMP_SYMBOL:					'LOCALTIMESTAMP'					{ $type = TYPE_FROM_VERSION(40000, NOW_SYMBOL); }; //Synonym
LOCAL_SYMBOL:							'LOCAL';							// SQL-2003-R
LOCATOR_SYMBOL:							'LOCATOR';							// SQL-2003-N
LOCKS_SYMBOL:							'LOCKS';
LOCK_SYMBOL:							'LOCK';
LOGFILE_SYMBOL:							'LOGFILE';
LOGS_SYMBOL:							'LOGS';
LONGBLOB_SYMBOL:						'LONGBLOB';
LONGTEXT_SYMBOL:						'LONGTEXT';
LONG_NUM_SYMBOL:						'LONG_NUM';
LONG_SYMBOL:							'LONG';
LOOP_SYMBOL:							'LOOP'								{ $type = TYPE_FROM_VERSION(50000, $type); };
LOW_PRIORITY_SYMBOL:					'LOW_PRIORITY';
MASTER_AUTO_POSITION_SYMBOL:			'MASTER_AUTO_POSITION'				{ $type = TYPE_FROM_VERSION(50605, $type); };
MASTER_BIND_SYMBOL:						'MASTER_BIND'						{ $type = TYPE_FROM_VERSION(50602, $type); };
MASTER_CONNECT_RETRY_SYMBOL:			'MASTER_CONNECT_RETRY';
MASTER_DELAY_SYMBOL:					'MASTER_DELAY'						{ $type = TYPE_FROM_VERSION(50600, $type); };
MASTER_HOST_SYMBOL:						'MASTER_HOST';
MASTER_LOG_FILE_SYMBOL:					'MASTER_LOG_FILE';
MASTER_LOG_POS_SYMBOL:					'MASTER_LOG_POS';
MASTER_PASSWORD_SYMBOL:					'MASTER_PASSWORD';
MASTER_PORT_SYMBOL:						'MASTER_PORT';
MASTER_RETRY_COUNT_SYMBOL:				'MASTER_RETRY_COUNT'				{ $type = TYPE_FROM_VERSION(50601, $type); };
MASTER_SERVER_ID_SYMBOL:				'MASTER_SERVER_ID';
MASTER_SSL_CAPATH_SYMBOL:				'MASTER_SSL_CAPATH';
MASTER_SSL_CA_SYMBOL:					'MASTER_SSL_CA';
MASTER_SSL_CERT_SYMBOL:					'MASTER_SSL_CERT';
MASTER_SSL_CIPHER_SYMBOL:				'MASTER_SSL_CIPHER';
MASTER_SSL_CRL_SYMBOL:					'MASTER_SSL_CRL'					{ $type = TYPE_FROM_VERSION(50603, $type); };
MASTER_SSL_CRLPATH_SYMBOL:				'MASTER_SSL_CRLPATH'				{ $type = TYPE_FROM_VERSION(50603, $type); };
MASTER_SSL_KEY_SYMBOL:					'MASTER_SSL_KEY';
MASTER_SSL_SYMBOL:						'MASTER_SSL';
MASTER_SSL_VERIFY_SERVER_CERT_SYMBOL:	'MASTER_SSL_VERIFY_SERVER_CERT'		{ $type = TYPE_FROM_VERSION(50100, $type); };
MASTER_SYMBOL:							'MASTER';
MASTER_USER_SYMBOL:						'MASTER_USER';
MASTER_HEARTBEAT_PERIOD_SYMBOL:			'MASTER_HEARTBEAT_PERIOD'			{ $type = TYPE_FROM_VERSION(50500, $type); };
MATCH_SYMBOL:							'MATCH';							// SQL-2003-R
MAX_CONNECTIONS_PER_HOUR_SYMBOL:		'MAX_CONNECTIONS_PER_HOUR';
MAX_QUERIES_PER_HOUR_SYMBOL:			'MAX_QUERIES_PER_HOUR';
MAX_ROWS_SYMBOL:						'MAX_ROWS';
MAX_SIZE_SYMBOL:						'MAX_SIZE';
MAX_STATEMENT_TIME_SYMBOL:				'MAX_STATEMENT_TIME'				{ $type = TYPE_FROM_VERSION(50704, $type); };
MAX_SYMBOL:								'MAX'								{ $type = determine_function(ctx, $type); }; // SQL-2003-N
MAX_UPDATES_PER_HOUR_SYMBOL:			'MAX_UPDATES_PER_HOUR';
MAX_USER_CONNECTIONS_SYMBOL:			'MAX_USER_CONNECTIONS';
MAXVALUE_SYMBOL:						'MAXVALUE'							{ $type = TYPE_FROM_VERSION(50500, $type); }; // SQL-2003-N
MEDIUMBLOB_SYMBOL:						'MEDIUMBLOB';
MEDIUMINT_SYMBOL:						'MEDIUMINT';
MEDIUMTEXT_SYMBOL:						'MEDIUMTEXT';
MEDIUM_SYMBOL:							'MEDIUM';
MEMORY_SYMBOL:							'MEMORY';
MERGE_SYMBOL:							'MERGE';							// SQL-2003-R
MESSAGE_TEXT_SYMBOL:					'MESSAGE_TEXT';						// SQL-2003-N
MICROSECOND_SYMBOL:						'MICROSECOND';						// MYSQL-FUNC
MID_SYMBOL:								'MID'								{ $type = determine_function(ctx, SUBSTRING_SYMBOL); }; // Synonym
MIDDLEINT_SYMBOL:						'MIDDLEINT'							{ $type = MEDIUMINT_SYMBOL; }; // Synonym (for Powerbuilder)
MIGRATE_SYMBOL:							'MIGRATE';
MINUTE_MICROSECOND_SYMBOL:				'MINUTE_MICROSECOND'				{ $type = TYPE_FROM_VERSION(40100, $type); };
MINUTE_SECOND_SYMBOL:					'MINUTE_SECOND';
MINUTE_SYMBOL:							'MINUTE';							// SQL-2003-R
MIN_ROWS_SYMBOL:						'MIN_ROWS';
MIN_SYMBOL:								'MIN'								{ $type = determine_function(ctx, $type); }; // SQL-2003-N
MODE_SYMBOL:							'MODE'								{ $type = TYPE_FROM_VERSION(40100, $type); };
MODIFIES_SYMBOL:						'MODIFIES'							{ $type = TYPE_FROM_VERSION(50000, $type); }; // SQL-2003-R
MODIFY_SYMBOL:							'MODIFY';
MOD_SYMBOL:								'MOD';								// SQL-2003-N
MONTH_SYMBOL:							'MONTH';							// SQL-2003-R
MULTILINESTRING_SYMBOL:					'MULTILINESTRING';
MULTIPOINT_SYMBOL:						'MULTIPOINT';
MULTIPOLYGON_SYMBOL:					'MULTIPOLYGON';
MUTEX_SYMBOL:							'MUTEX';
MYSQL_ERRNO_SYMBOL:						'MYSQL_ERRNO';
NAMES_SYMBOL:							'NAMES';							// SQL-2003-N
NAME_SYMBOL:							'NAME';								// SQL-2003-N
NATIONAL_SYMBOL:						'NATIONAL';							// SQL-2003-R
NATURAL_SYMBOL:							'NATURAL';							// SQL-2003-R
NCHAR_STRING_SYMBOL:					'NCHAR_STRING';
NCHAR_SYMBOL:							'NCHAR';							// SQL-2003-R
NDB_SYMBOL:								'NDB'								{ $type = NDBCLUSTER_SYMBOL; }; //Synonym
NDBCLUSTER_SYMBOL:						'NDBCLUSTER';
NEG_SYMBOL:								'NEG';
NEVER_SYMBOL:							'NEVER'								{ $type = TYPE_FROM_VERSION(50704, $type); };
NEW_SYMBOL:								'NEW';								// SQL-2003-R
NEXT_SYMBOL:							'NEXT';								// SQL-2003-N
NODEGROUP_SYMBOL:						'NODEGROUP';
NONE_SYMBOL:							'NONE';								// SQL-2003-R
NONBLOCKING_SYMBOL:						'NONBLOCKING'						{ $type = TYPE_FROM_VERSION(50700, $type); };
NOT_SYMBOL:								'NOT'								{ $type = SQL_MODE_ACTIVE(SQL_MODE_HIGH_NOT_PRECEDENCE) ? NOT2_SYMBOL : $type; }; // SQL-2003-R
NOW_SYMBOL:								'NOW'								{ $type = determine_function(ctx, $type); }; 
NO_SYMBOL:								'NO';								// SQL-2003-R
NO_WAIT_SYMBOL:							'NO_WAIT';
NO_WRITE_TO_BINLOG_SYMBOL:				'NO_WRITE_TO_BINLOG'				{ $type = TYPE_FROM_VERSION(40100, $type); };
NULL_SYMBOL:							'NULL';								// SQL-2003-R
NUMBER_SYMBOL:							'NUMBER'							{ $type = TYPE_FROM_VERSION(50606, $type); };
NUMERIC_SYMBOL:							'NUMERIC';							// SQL-2003-R
NVARCHAR_SYMBOL:						'NVARCHAR';
OFFLINE_SYMBOL:							'OFFLINE';
OFFSET_SYMBOL:							'OFFSET';
OLD_PASSWORD_SYMBOL:					'OLD_PASSWORD';
ON_SYMBOL:								'ON';								// SQL-2003-R
ONE_SHOT_SYMBOL:						'ONE_SHOT'							{ if (SERVER_VERSION >= 50600) $type = IDENTIFIER; }; // Deprecated in 5.0, removed in 5.6.
ONE_SYMBOL:								'ONE';
ONLINE_SYMBOL:							'ONLINE';
ONLY_SYMBOL:							'ONLY'								{ $type = TYPE_FROM_VERSION(50605, $type); };
OPEN_SYMBOL:							'OPEN';								// SQL-2003-R
OPTIMIZE_SYMBOL:						'OPTIMIZE';
OPTIONS_SYMBOL:							'OPTIONS';
OPTION_SYMBOL:							'OPTION';							// SQL-2003-N
OPTIONALLY_SYMBOL:						'OPTIONALLY';
ORDER_SYMBOL:							'ORDER';							// SQL-2003-R
OR_SYMBOL:								'OR';								// SQL-2003-R
OUTER_SYMBOL:							'OUTER';
OUTFILE_SYMBOL:							'OUTFILE';
OUT_SYMBOL:								'OUT'								{ $type = TYPE_FROM_VERSION(50000, $type); }; // SQL-2003-R
OWNER_SYMBOL:							'OWNER';
PACK_KEYS_SYMBOL:						'PACK_KEYS';
PAGE_SYMBOL:							'PAGE';
PARAM_MARKER_SYMBOL:					'PARAM_MARKER';
PARSER_SYMBOL:							'PARSER';
PARTIAL_SYMBOL:							'PARTIAL';							// SQL-2003-N
PARTITIONING_SYMBOL:					'PARTITIONING';
PARTITIONS_SYMBOL:						'PARTITIONS';
PARTITION_SYMBOL:						'PARTITION'							{ $type = TYPE_FROM_VERSION(50600, $type); }; // SQL-2003-R
PASSWORD_SYMBOL:						'PASSWORD';
PHASE_SYMBOL:							'PHASE';
PLUGINS_SYMBOL:							'PLUGINS';
PLUGIN_DIR_SYMBOL:						'PLUGIN_DIR'						{ $type = TYPE_FROM_VERSION(50604, $type); }; // Internal
PLUGIN_SYMBOL:							'PLUGIN';
POINT_SYMBOL:							'POINT';
POLYGON_SYMBOL:							'POLYGON';
PORT_SYMBOL:							'PORT';
POSITION_SYMBOL:						'POSITION'							{ $type = determine_function(ctx, $type); }; // SQL-2003-N
PRECEDES_SYMBOL:						'PRECEDES'							{ $type = TYPE_FROM_VERSION(50700, $type); };
PRECISION_SYMBOL:						'PRECISION';						// SQL-2003-R
PREPARE_SYMBOL:							'PREPARE';							// SQL-2003-R
PRESERVE_SYMBOL:						'PRESERVE';
PREV_SYMBOL:							'PREV';
PRIMARY_SYMBOL:							'PRIMARY';							// SQL-2003-R
PRIVILEGES_SYMBOL:						'PRIVILEGES';						// SQL-2003-N
PROCEDURE_SYMBOL:						'PROCEDURE';						// SQL-2003-R
PROCESS_SYMBOL:							'PROCESS';
PROCESSLIST_SYMBOL:						'PROCESSLIST';
PROFILE_SYMBOL:							'PROFILE';
PROFILES_SYMBOL:						'PROFILES';
PROXY_SYMBOL:							'PROXY'								{ $type = TYPE_FROM_VERSION(50500, $type); };
PURGE_SYMBOL:							'PURGE';
QUARTER_SYMBOL:							'QUARTER';
QUERY_SYMBOL:							'QUERY';
QUICK_SYMBOL:							'QUICK';
RANGE_SYMBOL:							'RANGE'								{ $type = TYPE_FROM_VERSION(50100, $type); }; // SQL-2003-R
READS_SYMBOL:							'READS'								{ $type = TYPE_FROM_VERSION(50000, $type); }; // SQL-2003-R
READ_ONLY_SYMBOL:						'READ_ONLY'							{ $type = TYPE_FROM_VERSION(50100, $type); };
READ_SYMBOL:							'READ';								// SQL-2003-N
READ_WRITE_SYMBOL:						'READ_WRITE'						{ $type = TYPE_FROM_VERSION(50100, $type); };
REAL_SYMBOL:							'REAL';								// SQL-2003-R
REBUILD_SYMBOL:							'REBUILD';
RECOVER_SYMBOL:							'RECOVER';
REDOFILE_SYMBOL:						'REDOFILE';
REDO_BUFFER_SIZE_SYMBOL:				'REDO_BUFFER_SIZE';
REDUNDANT_SYMBOL:						'REDUNDANT';
REFERENCES_SYMBOL:						'REFERENCES';						// SQL-2003-R
REGEXP_SYMBOL:							'REGEXP';
RELAY_SYMBOL:							'RELAY';
RELAYLOG_SYMBOL:						'RELAYLOG';
RELAY_LOG_FILE_SYMBOL:					'RELAY_LOG_FILE';
RELAY_LOG_POS_SYMBOL:					'RELAY_LOG_POS';
RELAY_THREAD_SYMBOL:					'RELAY_THREAD';
RELEASE_SYMBOL:							'RELEASE'							{ $type = TYPE_FROM_VERSION(50000, $type); }; // SQL-2003-R
RELOAD_SYMBOL:							'RELOAD';
REMOVE_SYMBOL:							'REMOVE';
RENAME_SYMBOL:							'RENAME';
REORGANIZE_SYMBOL:						'REORGANIZE';
REPAIR_SYMBOL:							'REPAIR';
REPEATABLE_SYMBOL:						'REPEATABLE';						// SQL-2003-N
REPEAT_SYMBOL:							'REPEAT'							{ $type = TYPE_FROM_VERSION(50000, $type); }; // MYSQL-FUNC
REPLACE_SYMBOL:							'REPLACE';							// MYSQL-FUNC
REPLICATION_SYMBOL:						'REPLICATION';
REPLICATE_DO_DB_SYMBOL:					'REPLICATE_DO_DB'					{ $type = TYPE_FROM_VERSION(50700, $type); };
REPLICATE_IGNORE_DB_SYMBOL:				'REPLICATE_IGNORE_DB'				{ $type = TYPE_FROM_VERSION(50700, $type); };
REPLICATE_DO_TABLE_SYMBOL:				'REPLICATE_DO_TABLE'				{ $type = TYPE_FROM_VERSION(50700, $type); };
REPLICATE_IGNORE_TABLE_SYMBOL:			'REPLICATE_IGNORE_TABLE'			{ $type = TYPE_FROM_VERSION(50700, $type); };
REPLICATE_WILD_DO_TABLE_SYMBOL:			'REPLICATE_WILD_DO_TABLE'			{ $type = TYPE_FROM_VERSION(50700, $type); };
REPLICATE_WILD_IGNORE_TABLE_SYMBOL:		'REPLICATE_WILD_IGNORE_TABLE'		{ $type = TYPE_FROM_VERSION(50700, $type); };
REPLICATE_REWRITE_DB_SYMBOL:			'REPLICATE_REWRITE_DB'				{ $type = TYPE_FROM_VERSION(50700, $type); };
REQUIRE_SYMBOL:							'REQUIRE'							{ $type = TYPE_FROM_VERSION(40000, $type); };
RESET_SYMBOL:							'RESET';
RESIGNAL_SYMBOL:						'RESIGNAL'							{ $type = TYPE_FROM_VERSION(50500, $type); }; // SQL-2003-R
RESTORE_SYMBOL:							'RESTORE';
RESTRICT_SYMBOL:						'RESTRICT';
RESUME_SYMBOL:							'RESUME';
RETURNED_SQLSTATE_SYMBOL:				'RETURNED_SQLSTATE'					{ $type = TYPE_FROM_VERSION(50600, $type); };
RETURNS_SYMBOL:							'RETURNS';							// SQL-2003-R
RETURN_SYMBOL:							'RETURN'							{ $type = TYPE_FROM_VERSION(50000, $type); }; // SQL-2003-R
REVERSE_SYMBOL:							'REVERSE'							{ $type = TYPE_FROM_VERSION(50600, $type); };
REVOKE_SYMBOL:							'REVOKE';							// SQL-2003-R
RIGHT_SYMBOL:							'RIGHT';							// SQL-2003-R
RLIKE_SYMBOL:							'RLIKE'								{ $type = REGEXP_SYMBOL; }; // Synonym (like in mSQL2)
ROLLBACK_SYMBOL:						'ROLLBACK';							// SQL-2003-R
ROLLUP_SYMBOL:							'ROLLUP';							// SQL-2003-R
ROUTINE_SYMBOL:							'ROUTINE';							// SQL-2003-N
ROWS_SYMBOL:							'ROWS';								// SQL-2003-R
ROW_COUNT_SYMBOL:						'ROW_COUNT';
ROW_FORMAT_SYMBOL:						'ROW_FORMAT';
ROW_SYMBOL:								'ROW';								// SQL-2003-R
RTREE_SYMBOL:							'RTREE';
SAVEPOINT_SYMBOL:						'SAVEPOINT';						// SQL-2003-R
SCHEDULE_SYMBOL:						'SCHEDULE';
SCHEMA_SYMBOL:							'SCHEMA' 							{ $type = TYPE_FROM_VERSION(50000, DATABASE_SYMBOL); }; // Synonym
SCHEMA_NAME_SYMBOL:						'SCHEMA_NAME';						// SQL-2003-N
SCHEMAS_SYMBOL:							'SCHEMAS' 							{ $type = TYPE_FROM_VERSION(50000, DATABASES_SYMBOL); }; // Synonym
SECOND_MICROSECOND_SYMBOL:				'SECOND_MICROSECOND'				{ $type = TYPE_FROM_VERSION(40100, $type); };
SECOND_SYMBOL:							'SECOND';							// SQL-2003-R
SECURITY_SYMBOL:						'SECURITY';							// SQL-2003-N
SELECT_SYMBOL:							'SELECT';							// SQL-2003-R
SENSITIVE_SYMBOL:						'SENSITIVE'							{ $type = TYPE_FROM_VERSION(50000, $type); }; // FUTURE-USE
SEPARATOR_SYMBOL:						'SEPARATOR'							{ $type = TYPE_FROM_VERSION(40100, $type); };
SERIALIZABLE_SYMBOL:					'SERIALIZABLE';						// SQL-2003-N
SERIAL_SYMBOL:							'SERIAL';
SESSION_SYMBOL:							'SESSION';							// SQL-2003-N
SERVER_SYMBOL:							'SERVER';
SERVER_OPTIONS_SYMBOL:					'SERVER_OPTIONS';
SESSION_USER_SYMBOL:					'SESSION_USER'						{ $type = determine_function(ctx, USER_SYMBOL); }; // Synonym
SET_SYMBOL:								'SET';								// SQL-2003-R
SET_VAR_SYMBOL:							'SET_VAR';
SHARE_SYMBOL:							'SHARE';
SHOW_SYMBOL:							'SHOW';
SHUTDOWN_SYMBOL:						'SHUTDOWN';
SIGNAL_SYMBOL:							'SIGNAL'							{ $type = TYPE_FROM_VERSION(50500, $type); }; // SQL-2003-R
SIGNED_SYMBOL:							'SIGNED';
SIMPLE_SYMBOL:							'SIMPLE';							// SQL-2003-N
SLAVE_SYMBOL:							'SLAVE';
SLOW_SYMBOL:							'SLOW'								{ $type = TYPE_FROM_VERSION(50500, $type); };
SMALLINT_SYMBOL:						'SMALLINT';							// SQL-2003-R
SNAPSHOT_SYMBOL:						'SNAPSHOT';
SOCKET_SYMBOL:							'SOCKET';
SONAME_SYMBOL:							'SONAME';
SOUNDS_SYMBOL:							'SOUNDS';
SOURCE_SYMBOL:							'SOURCE';
SPATIAL_SYMBOL:							'SPATIAL'							{ $type = TYPE_FROM_VERSION(40100, $type); };
SPECIFIC_SYMBOL:						'SPECIFIC'							{ $type = TYPE_FROM_VERSION(50000, $type); }; // SQL-2003-R
SQLEXCEPTION_SYMBOL:					'SQLEXCEPTION'						{ $type = TYPE_FROM_VERSION(50000, $type); }; // SQL-2003-R
SQLSTATE_SYMBOL:						'SQLSTATE'							{ $type = TYPE_FROM_VERSION(50000, $type); }; // SQL-2003-R
SQLWARNING_SYMBOL:						'SQLWARNING'						{ $type = TYPE_FROM_VERSION(50000, $type); }; // SQL-2003-R
SQL_AFTER_GTIDS_SYMBOL:					'SQL_AFTER_GTIDS'					{ $type = TYPE_FROM_VERSION(50600, $type); }; // MYSQL
SQL_AFTER_MTS_GAPS_SYMBOL:				'SQL_AFTER_MTS_GAPS'				{ $type = TYPE_FROM_VERSION(50606, $type); }; // MYSQL
SQL_BEFORE_GTIDS_SYMBOL:				'SQL_BEFORE_GTIDS'					{ $type = TYPE_FROM_VERSION(50600, $type); }; // MYSQL
SQL_BIG_RESULT_SYMBOL:					'SQL_BIG_RESULT';
SQL_BUFFER_RESULT_SYMBOL:				'SQL_BUFFER_RESULT';
SQL_CACHE_SYMBOL:						'SQL_CACHE';
SQL_CALC_FOUND_ROWS_SYMBOL:				'SQL_CALC_FOUND_ROWS'				{ $type = TYPE_FROM_VERSION(40000, $type); };
SQL_NO_CACHE_SYMBOL:					'SQL_NO_CACHE';
SQL_SMALL_RESULT_SYMBOL:				'SQL_SMALL_RESULT';
SQL_SYMBOL:								'SQL'								{ $type = TYPE_FROM_VERSION(50000, $type); }; // SQL-2003-R
SQL_THREAD_SYMBOL:						'SQL_THREAD';
SSL_SYMBOL:								'SSL'								{ $type = TYPE_FROM_VERSION(40000, $type); };
STACKED_SYMBOL:							'STACKED'							{ $type = TYPE_FROM_VERSION(50700, $type); };
STARTING_SYMBOL:						'STARTING';
STARTS_SYMBOL:							'STARTS';
START_SYMBOL:							'START';							// SQL-2003-R
STATS_AUTO_RECALC_SYMBOL:				'STATS_AUTO_RECALC'					{ $type = TYPE_FROM_VERSION(50600, $type); };
STATS_PERSISTENT_SYMBOL:				'STATS_PERSISTENT'					{ $type = TYPE_FROM_VERSION(50600, $type); };
STATS_SAMPLE_PAGES_SYMBOL:				'STATS_SAMPLE_PAGES'				{ $type = TYPE_FROM_VERSION(50600, $type); };
STATUS_SYMBOL:							'STATUS';
STDDEV_SAMP_SYMBOL:						'STDDEV_SAMP'						{ $type = determine_function(ctx, $type); }; // SQL-2003-N
STDDEV_SYMBOL:							'STDDEV'							{ $type = determine_function(ctx, STD_SYMBOL); }; // Synonym
STDDEV_POP_SYMBOL:						'STDDEV_POP'						{ $type = determine_function(ctx, STD_SYMBOL); }; // Synonym
STD_SYMBOL:								'STD'								{ $type = determine_function(ctx, $type); }; 
STOP_SYMBOL:							'STOP';
STORAGE_SYMBOL:							'STORAGE';
STRAIGHT_JOIN_SYMBOL:					'STRAIGHT_JOIN';
STRING_SYMBOL:							'STRING';
SUBCLASS_ORIGIN_SYMBOL:					'SUBCLASS_ORIGIN';					// SQL-2003-N
SUBDATE_SYMBOL:							'SUBDATE'							{ $type = determine_function(ctx, $type); }; 
SUBJECT_SYMBOL:							'SUBJECT';
SUBPARTITIONS_SYMBOL:					'SUBPARTITIONS';
SUBPARTITION_SYMBOL:					'SUBPARTITION';
SUBSTR_SYMBOL:							'SUBSTR'							{ $type = determine_function(ctx, SUBSTRING_SYMBOL); }; // Synonym
SUBSTRING_SYMBOL:						'SUBSTRING'							{ $type = determine_function(ctx, $type); }; // SQL-2003-N
SUM_SYMBOL:								'SUM'								{ $type = determine_function(ctx, $type); }; // SQL-2003-N
SUPER_SYMBOL:							'SUPER';
SUSPEND_SYMBOL:							'SUSPEND';
SWAPS_SYMBOL:							'SWAPS';
SWITCHES_SYMBOL:						'SWITCHES';
SYSDATE_SYMBOL:							'SYSDATE'							{ $type = determine_function(ctx, $type); };
SYSTEM_USER_SYMBOL:						'SYSTEM_USER'						{ $type = determine_function(ctx, USER_SYMBOL); };
TABLES_SYMBOL:							'TABLES';
TABLESPACE_SYMBOL:						'TABLESPACE';
TABLE_REF_PRIORITY_SYMBOL:				'TABLE_REF_PRIORITY';
TABLE_SYMBOL:							'TABLE';							// SQL-2003-R
TABLE_CHECKSUM_SYMBOL:					'TABLE_CHECKSUM';
TABLE_NAME_SYMBOL:						'TABLE_NAME';						// SQL-2003-N
TEMPORARY_SYMBOL:						'TEMPORARY';						// SQL-2003-N
TEMPTABLE_SYMBOL:						'TEMPTABLE';
TERMINATED_SYMBOL:						'TERMINATED';
TEXT_SYMBOL:							'TEXT';
THAN_SYMBOL:							'THAN';
THEN_SYMBOL:							'THEN';								// SQL-2003-R
TIMESTAMP_SYMBOL:						'TIMESTAMP';						// SQL-2003-R
TIMESTAMP_ADD_SYMBOL:					'TIMESTAMP_ADD';
TIMESTAMP_DIFF_SYMBOL:					'TIMESTAMP_DIFF';
TIME_SYMBOL:							'TIME';								// SQL-2003-R
TINYBLOB_SYMBOL:						'TINYBLOB';
TINYINT_SYMBOL:							'TINYINT';
TINYTEXT_SYMBOL:						'TINYTEXT';
TO_SYMBOL:								'TO';								// SQL-2003-R
TRAILING_SYMBOL:						'TRAILING';							// SQL-2003-R
TRANSACTION_SYMBOL:						'TRANSACTION';
TRIGGERS_SYMBOL:						'TRIGGERS'							{ $type = TYPE_FROM_VERSION(50000, $type); };
TRIGGER_SYMBOL:							'TRIGGER';							// SQL-2003-R
TRIM_SYMBOL:							'TRIM'								{ $type = determine_function(ctx, $type); }; // SQL-2003-N
TRUE_SYMBOL:							'TRUE'								{ $type = TYPE_FROM_VERSION(40100, $type); }; // SQL-2003-R
TRUNCATE_SYMBOL:						'TRUNCATE';
TYPES_SYMBOL:							'TYPES';
TYPE_SYMBOL:							'TYPE';								// SQL-2003-N
UDF_RETURNS_SYMBOL:						'UDF_RETURNS';
ULONGLONG_NUM_SYMBOL:					'ULONGLONG_NUM';
UNCOMMITTED_SYMBOL:						'UNCOMMITTED';						// SQL-2003-N
UNDEFINED_SYMBOL:						'UNDEFINED';
UNDOFILE_SYMBOL:						'UNDOFILE';
UNDO_BUFFER_SIZE_SYMBOL:				'UNDO_BUFFER_SIZE';
UNDO_SYMBOL:							'UNDO'								{ $type = TYPE_FROM_VERSION(50000, $type); }; // FUTURE-USE
UNICODE_SYMBOL:							'UNICODE';
UNINSTALL_SYMBOL:						'UNINSTALL';
UNION_SYMBOL:							'UNION';							// SQL-2003-R
UNIQUE_SYMBOL:							'UNIQUE';
UNKNOWN_SYMBOL:							'UNKNOWN';							// SQL-2003-R
UNLOCK_SYMBOL:							'UNLOCK';
UNSIGNED_SYMBOL:						'UNSIGNED';
UNTIL_SYMBOL:							'UNTIL';
UPDATE_SYMBOL:							'UPDATE';							// SQL-2003-R
UPGRADE_SYMBOL:							'UPGRADE'							{ $type = TYPE_FROM_VERSION(50000, $type); };
USAGE_SYMBOL:							'USAGE';							// SQL-2003-N
USER_RESOURCES_SYMBOL:					'USER_RESOURCES';
USER_SYMBOL:							'USER';								// SQL-2003-R
USE_FRM_SYMBOL:							'USE_FRM';
USE_SYMBOL:								'USE';
USING_SYMBOL:							'USING';							// SQL-2003-R
UTC_DATE_SYMBOL:						'UTC_DATE'							{ $type = TYPE_FROM_VERSION(40100, $type); };
UTC_TIMESTAMP_SYMBOL:					'UTC_TIMESTAMP'						{ $type = TYPE_FROM_VERSION(40100, $type); };
UTC_TIME_SYMBOL:						'UTC_TIME'							{ $type = TYPE_FROM_VERSION(40100, $type); };
VALUES_SYMBOL:							'VALUES';							// SQL-2003-R
VALUE_SYMBOL:							'VALUE';							// SQL-2003-R
VARBINARY_SYMBOL:						'VARBINARY';
VARCHAR_SYMBOL:							'VARCHAR';							// SQL-2003-R
VARCHARACTER_SYMBOL:					'VARCHARACTER'						{ $type = TYPE_FROM_VERSION(40100, VARCHAR_SYMBOL); }; // Synonym
VARIABLES_SYMBOL:						'VARIABLES';
VARIANCE_SYMBOL:						'VARIANCE'							{ $type = determine_function(ctx, $type); }; 
VARYING_SYMBOL:							'VARYING';							// SQL-2003-R
VAR_POP_SYMBOL:							'VAR_POP'							{ $type = determine_function(ctx, VARIANCE_SYMBOL); }; // Synonym
VAR_SAMP_SYMBOL:						'VAR_SAMP'							{ $type = determine_function(ctx, $type); }; 
VIEW_SYMBOL:							'VIEW';								// SQL-2003-N
WAIT_SYMBOL:							'WAIT';
WARNINGS_SYMBOL:						'WARNINGS';
WEEK_SYMBOL:							'WEEK';
WEIGHT_STRING_SYMBOL:					'WEIGHT_STRING'						{ $type = TYPE_FROM_VERSION(50600, $type); };
WHEN_SYMBOL:							'WHEN';								// SQL-2003-R
WHERE_SYMBOL:							'WHERE';							// SQL-2003-R
WHILE_SYMBOL:							'WHILE'								{ $type = TYPE_FROM_VERSION(50000, $type); };
WITH_SYMBOL:							'WITH';								// SQL-2003-R
WITH_CUBE_SYMBOL:						'WITH_CUBE';						// INTERNAL
WITH_ROLLUP_SYMBOL:						'WITH_ROLLUP';						// INTERNAL
WORK_SYMBOL:							'WORK';								// SQL-2003-N
WRAPPER_SYMBOL:							'WRAPPER';
WRITE_SYMBOL:							'WRITE';							// SQL-2003-N
X509_SYMBOL:							'X509';
XA_SYMBOL:								'XA';
XID_SYMBOL:								'XID'								{ $type = TYPE_FROM_VERSION(50704, $type); };
XML_SYMBOL:								'XML';
XOR_SYMBOL:								'XOR'								{ $type = TYPE_FROM_VERSION(40000, $type); };
YEAR_MONTH_SYMBOL:						'YEAR_MONTH';
YEAR_SYMBOL:							'YEAR';								// SQL-2003-R
ZEROFILL_SYMBOL:						'ZEROFILL';

// Additional tokens which are mapped to existing tokens.
INT1_SYMBOL:							'INT1'								{ $type = TINYINT_SYMBOL; };
INT2_SYMBOL:							'INT2'								{ $type = SMALLINT_SYMBOL; };
INT3_SYMBOL:							'INT3'								{ $type = MEDIUMINT_SYMBOL; };
INT4_SYMBOL:							'INT4'								{ $type = INT_SYMBOL; };
INT8_SYMBOL:							'INT8'								{ $type = BIGINT_SYMBOL; };

SQL_TSI_FRAC_SECOND_SYMBOL:				'SQL_TSI_FRAC_SECOND'				{ $type = DEPRECATED_TYPE_FROM_VERSION(50503, FRAC_SECOND_SYMBOL); };
SQL_TSI_SECOND_SYMBOL:					'SQL_TSI_SECOND'					{ $type = SECOND_SYMBOL; };
SQL_TSI_MINUTE_SYMBOL:					'SQL_TSI_MINUTE'					{ $type = MINUTE_SYMBOL; };
SQL_TSI_HOUR_SYMBOL:					'SQL_TSI_HOUR'						{ $type = HOUR_SYMBOL; };
SQL_TSI_DAY_SYMBOL:						'SQL_TSI_DAY'						{ $type = DAY_SYMBOL; };
SQL_TSI_WEEK_SYMBOL:					'SQL_TSI_WEEK'						{ $type = WEEK_SYMBOL; };
SQL_TSI_MONTH_SYMBOL:					'SQL_TSI_MONTH'						{ $type = MONTH_SYMBOL; };
SQL_TSI_QUARTER_SYMBOL:					'SQL_TSI_QUARTER'					{ $type = QUARTER_SYMBOL; };
SQL_TSI_YEAR_SYMBOL:					'SQL_TSI_YEAR'						{ $type = YEAR_SYMBOL; };

// $> Keywords

// White space handling
WS: ( ' ' | '\t' | '\f' | '\r'| '\n') { $channel = HIDDEN; };  // Ignore whitespaces.

// Input not covered elsewhere (unless quoted).
INVALID_INPUT:
	'\u0001'..'\u0008'   // Control codes.
	| '\u000B'           // Line tabulation.
	| '\u000C'           // Form feed.
	| '\u000E'..'\u001F' // More control codes.
	| '['
	| ']'
;

// Basic tokens. Tokens used in parser rules must not be fragments!
// INTEGER includes all the integral types defined in the server parser. These have different lengths, but
// mostly appear together anyway. So these are: NUM, LONG_NUM, DECIMAL_NUM and ULONGLONG_NUM.
// We'd need platform specific code to separate them.
INTEGER:				DIGITS;
FLOAT:					DIGITS? DOT_SYMBOL DIGITS ('E' (MINUS_OPERATOR | PLUS_OPERATOR)? DIGITS)?;

HEXNUMBER:				'0X' HEXDIGIT+;
HEXSTRING:				'X' '\'' HEXDIGIT+ '\'';

BITNUMBER:				'0B' ('0' | '1')+;
BITSTRING:				'B' '\'' ('0' | '1')+ '\'';

NCHAR_TEXT:				'N' SINGLE_QUOTED_TEXT;

// The underscore charset token is used to defined the repertoire of a string, though it conflicts
// with normal identifiers, which also can start with an underscore.
UNDERSCORE_CHARSET:		UNDERLINE_SYMBOL LETTER_WHEN_UNQUOTED+ { $type = check_charset(PAYLOAD, $text); };

// Identifiers might start with a digit, even tho it is discouraged.
IDENTIFIER: 			LETTER_WHEN_UNQUOTED+; // All keywords above are automatically excluded.

// For all 3 quoted types:
// MySQL supports automatic concatenation if multiple quoted strings follow each other. There's a twist, though.
// If there's one or more whitespaces between two strings the quotes and the whitespaces are simply removed. If there's no
// whitespace however then the repeated quote char is replaced by a single one, which is then part of the string:
// 1) 'abc'   'def' => 'abcdef'
// 2) 'abc''def'    => 'abc'def'.
// The quotes must be handled by the consumer code (tree walker etc.), as well as any escape sequences.
// That's necessary to not break lexing for invalid sequences and avoids casing issues.
// This will also help to reproduce the same output if this is a reformatter.
// Multiple identifiers with only whitespaces between them are handled in the string_literal parser rule.
// In order to aid the consumption of repeated or escaped quote chars the token contains a counter in its
// user1 field. So post processing (except for outer quotes) is only necessary if this field is > 0.

// Ok, here's another twist: back quoted identifiers don't support the first form (it is interpreted as two identifiers).
BACK_TICK_QUOTED_ID
@init { int escape_count = 0; }:
	BACK_TICK
	(
		BACK_TICK BACK_TICK { escape_count++; }
		| {!SQL_MODE_ACTIVE(SQL_MODE_NO_BACKSLASH_ESCAPES)}? => ESCAPE_OPERATOR .  { escape_count++; }
		| {SQL_MODE_ACTIVE(SQL_MODE_NO_BACKSLASH_ESCAPES)}? => ~(BACK_TICK)
		| {!SQL_MODE_ACTIVE(SQL_MODE_NO_BACKSLASH_ESCAPES)}? => ~(BACK_TICK | ESCAPE_OPERATOR)
	)*
	BACK_TICK
	{ EMIT(); LTOKEN->user1 = escape_count; } // Need to call EMIT() or we have no token to store our count in.
;

DOUBLE_QUOTED_TEXT
@init { int escape_count = 0; }:
	DOUBLE_QUOTE
	(
		DOUBLE_QUOTE DOUBLE_QUOTE { escape_count++; }
		| {!SQL_MODE_ACTIVE(SQL_MODE_NO_BACKSLASH_ESCAPES)}? => ESCAPE_OPERATOR .  { escape_count++; }
		| {SQL_MODE_ACTIVE(SQL_MODE_NO_BACKSLASH_ESCAPES)}? => ~(DOUBLE_QUOTE)
		| {!SQL_MODE_ACTIVE(SQL_MODE_NO_BACKSLASH_ESCAPES)}? => ~(DOUBLE_QUOTE | ESCAPE_OPERATOR)
	)*
	DOUBLE_QUOTE
	{ EMIT(); LTOKEN->user1 = escape_count; }
;

SINGLE_QUOTED_TEXT
@init { int escape_count = 0; }:
	SINGLE_QUOTE
	(
		SINGLE_QUOTE SINGLE_QUOTE { escape_count++; }
		| {!SQL_MODE_ACTIVE(SQL_MODE_NO_BACKSLASH_ESCAPES)}? => ESCAPE_OPERATOR .  { escape_count++; }
		| {SQL_MODE_ACTIVE(SQL_MODE_NO_BACKSLASH_ESCAPES)}? => ~(SINGLE_QUOTE)
		| {!SQL_MODE_ACTIVE(SQL_MODE_NO_BACKSLASH_ESCAPES)}? => ~(SINGLE_QUOTE | ESCAPE_OPERATOR)
	)*
	SINGLE_QUOTE
	{ EMIT(); LTOKEN->user1 = escape_count; }
;

COMMENT_RULE:
	{LA(1) == '-' && LA(2) == '-' && (LA(3) == EOF || LA(3) == ' ' || LA(3) == '\t' || LA(3) == '\n' || LA(3) == '\r')}? => DASHDASH_COMMENT
	| ML_COMMENT_HEAD BLOCK_COMMENT
	| VERSION_COMMENT_END
	| POUND_COMMENT
;

// There are 3 types of block comments:
// /* ... */ - The standard multi line comment.
// /*! ... */ - A comment used to mask code for other clients. In MySQL the content is handled as normal code.
// /*!12345 ... */ - Same as the previous one except code is only used when the given number is a lower value
//                   than the current server version (specifying so the minimum server version the code can run with).
fragment BLOCK_COMMENT options { greedy = false; }:
	{in_version_comment == ANTLR3_FALSE}? => VERSION_COMMENT
	| MULTILINE_COMMENT
;

fragment VERSION_COMMENT
@init { matched_version = ANTLR3_TRUE; }
:
	VERSION_COMMENT_INTRODUCER
		(
			v = INTEGER { matched_version = check_version_token(SERVER_VERSION, $v); } VERSION_COMMENT_TAIL
			| VERSION_COMMENT_TAIL
		)
;

fragment VERSION_COMMENT_TAIL:
	{ matched_version == ANTLR3_FALSE }? => // One level of block comment nesting is allowed for version comments.
		( options { greedy = false; }: (ML_COMMENT_HEAD MULTILINE_COMMENT) | . )* ML_COMMENT_END { $type = MULTILINE_COMMENT; $channel = HIDDEN; }
	| { $type = VERSION_COMMENT; $channel = HIDDEN; in_version_comment = ANTLR3_TRUE; }
;

fragment MULTILINE_COMMENT:	( options { greedy = false; }: . )* ML_COMMENT_END { $channel = HIDDEN; };

fragment VERSION_COMMENT_END:
	{in_version_comment == ANTLR3_TRUE}? => ML_COMMENT_END { $channel = HIDDEN; in_version_comment = ANTLR3_FALSE; }
	| // Intentionally left empty to make the gated semantic predicate work.
;

fragment POUND_COMMENT: '#' ~LINEBREAK* { $channel = HIDDEN; };
fragment DASHDASH_COMMENT:
	DOUBLE_DASH
		(
			LINEBREAK
			| (' ' | '\t') ~LINEBREAK*
			| EOF
		) { $channel = HIDDEN; }
;

fragment DOUBLE_DASH:	'--';
fragment LINEBREAK:		'\n' | '\r';

fragment DIGIT:		'0'..'9';
fragment DIGITS:	DIGIT+;
fragment HEXDIGIT:	DIGIT | 'A'..'F';
fragment SIMPLE_IDENTIFIER: (DIGIT | 'A'..'Z' | DOT_SYMBOL | '_' | '$')+;

fragment ML_COMMENT_HEAD:				'/*';
fragment ML_COMMENT_END:				'*/';
fragment VERSION_COMMENT_INTRODUCER: 	'!';

// As defined in http://dev.mysql.com/doc/refman/5.6/en/identifiers.html.
fragment LETTER_WHEN_UNQUOTED:
	'0'..'9'
	| 'A'..'Z' // Only upper case, as we use a case insensitive parser (insensitive only for ASCII).
	| '$'
	| '_'
	| '\u0080'..'\uffff'
;

// These are imaginary tokens which are never matched (but used as special tokens).

fragment NOT2_SYMBOL: ;
fragment CONCAT_PIPES_SYMBOL: ;
fragment AT_TEXT_SUFFIX: ; // See AT_SYMBOL for more information.
