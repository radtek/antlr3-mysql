parser grammar Identifier;

column_spec:
    ( ( schema_name DOT )? table_name DOT )? column_name ;

// identifiers ---  http://dev.mysql.com/doc/refman/5.6/en/identifiers.html 
schema_name:	ID;
table_name:	    ID; 
engine_name:    ID; 
column_name:    ID;
view_name:      ID;
parser_name:    ID;
index_name:     ID; 
partition_name: ID; 
partition_logical_name: ID;
constraint_symbol_name: ID; 
foreign_key_symbol_name:    ID;
collation_name: ID;
event_name:     ID; 
user_name:      ID;
function_name:  ID; 
procedure_name: ID; 
server_name:    ID;
wrapper_name:   ID; 
alias:   ( AS )? ID;
trigger_name:   ID;
