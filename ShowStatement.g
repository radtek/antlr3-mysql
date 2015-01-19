parser grammar ShowStatement;

// show statements ----- http://dev.mysql.com/doc/refman/5.6/en/show.html

/* ignore
show_authors_statement
	:	SHOW AUTHORS
;*/

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
	|	SHOW CREATE FUNCTION function_name
	|	SHOW CREATE PROCEDURE procedure_name
	|	SHOW CREATE TABLE table_spec
	|	SHOW CREATE TRIGGER trigger_name
	|	SHOW CREATE VIEW	view_name
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
	:	SHOW FUNCTION CODE function_name
	;
	
show_function_status_statement
	:	SHOW FUNCTION STATUS like_or_where
	;
	
/* ignore
show_grants_statement
*/

show_index_statement
	:	SHOW (INDEX|INDEXES|KEYS) (FROM|IN) table_spec ((FROM|IN) schema_name)? 
			(WHERE expression)?
	;

show_master_status_statement
	:	SHOW MASTER STATUS
;

show_open_tables_statement
	:	SHOW OPEN TABLES ((FROM|IN) schema_name)? (like_or_where)?
;

show_plugins_statement
	:	SHOW PLUGINS
	;
	
show_privileges_statement
	:	SHOW PRIVILEGES
	;

show_procedure_code_statement
	:	SHOW PROCEDURE CODE procedure_name
	;
	
show_procedure_status_statement
	:	SHOW PROCEDURE STATUS (like_or_where)?
	;

show_processlist_statement
	:	SHOW (FULL)? PROCESSLIST
	;

/* ignore for future depreciate
show_profile_statement
show_profiles_statement
*/

show_relaylog_events_statement
	:	SHOW RELAYLOG EVENTS (IN TEXT_STRING)? (FROM number_literal)? (limit_clause)?
	;

show_slave_hosts_statement
	:	SHOW SLAVE HOSTS
	;

show_slave_status_statement
	:	SHOW SLAVE STATUS
	;

show_status_statement
	:	SHOW (GLOBAL|SESSION)? STATUS (like_or_where)?
	;
	
show_table_status_statement
	:	SHOW TABLE STATUS ((FROM | IN) schema_name)? (like_or_where)?
	;
	
show_tables_statement
	:	SHOW (FULL)? TABLES ((FROM | IN) schema_name)? (like_or_where)?
	;

show_triggers_statement
	:	SHOW TRIGGERS ((FROM | IN) schema_name)? (like_or_where)?
	;

show_variables_statement
	:	SHOW (GLOBAL|SESSION)? VARIABLES (like_or_where)?
	;
	
like_or_where
	:	((LIKE TEXT_STRING) | (WHERE expression))
;

// other statements ---- http://dev.mysql.com/doc/refman/5.6/en/binlog.html
binlog_statement
	:	BINLOG TEXT_STRING
	;

/* ignore
cache_index_statement

flush_statement

kill_statement

load_index_into_cache

reset
*/


