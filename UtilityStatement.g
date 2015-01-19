parser grammar UtilityStatement;

explain_statement
	:	(EXPLAIN | DESCRIBE | DESC) table_spec (column_name)?
	|	(EXPLAIN | DESCRIBE | DESC) (explain_type)? explainable_stmt
	;
	
explain_type
	:	(EXTENDED | PARTITIONS | (FORMAT EQ format_name))
	;
	
format_name
	:	(T_ R_ A_ D_ I_ T_ I_ O_ N_ A_ L_)
	| 	(J_ S_ O_ N_)
	;
	
explainable_stmt
	:	select_statement
	|	delete_statements
	|	insert_statements
	|	replace_statement
	|	update_statements
	;

help_statement
	:	HELP TEXT_STRING 
	;
	
use_statement
	:	USE schema_name
	;