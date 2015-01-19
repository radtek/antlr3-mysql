parser grammar ShowStatement;

show_authors_statement
	:	SHOW AUTHORS
;

show_binary_logs_statement
	:	SHOW (BINARY | MASTER) LOGS
;

show_binlog_events_statement
	:	SHOW BINLOG EVENTS (IN TEXT_STRING)? (FROM number_literal)? 
			(limit_clause)?
;

show_character_set_statement
	:	SHOW CHARACTER SET (like_or_where)?
;

show_collation_statement
	:	SHOW COLLATION (like_or_where)?
;

show_columns_statement
	:	SHOW (FULL)? COLUMNS (FROM | IN) table_spec ((FROM | IN)? schema_name)?     
			(like_or_where)?
;
	
/* ignore 
show_contributors_statement :	; */

show_create_database_statement
	:	SHOW CREATE (DATABASE | SCHEMA) (IF NOT EXISTS)? schema_name
;

show_create_statements
	:	SHOW CREATE EVENT event_name
	:	SHOW CREATE FUNCTION func_name
	:	SHOW CREATE PROCEDURE proc_name
	:	SHOW CREATE TABLE table_spec
	:	SHOW CREATE TRIGGER trigger_name
	:	SHOW CREATE VIEW	view_name
;

show_databases_statement
	:	SHOW (DATABASES | SCHEMAS) (like_or_where)?
;

show_engine_statement
	:	SHOW ENGINE engine_name (STATUS | MUTEX)
;

show_engines_statement
	:	SHOW (STORAGE)? ENGINES
;

show_wes_statement
	:	SHOW (COUNT LPAREN ASTERISK RPAREN)? (ERRORS|WARNINGS) (limit_clause)?
;

show_events_statement
	:	SHOW EVENTS ((FROM|IN) schema_name)? (like_or_where)?
	;

show_function_code_statement
	:	SHOW FUNCTION CODE func_name
	;
	
show_function_status_statement
	:	SHOW FUNCTION STATUS like_or_where
	;
	
/* ignore
show_grants_statement
*/

show_index_statement
	:	SHOW (INDEX|INDEXS|KEYS) (FROM|IN) table_spec ((FROM|IN) schema_name)? 
			(WHERE expression)?
	;

show_master_status_statement
	:	SHOW MASTER STATUS
;


like_or_where
	:	((LIKE TEXT_STRING) | (WHERE expression))
;