parser grammar Identifier;

column_spec:
    ( ( schema_name DOT )? table_name DOT )? column_name ;

// identifiers ---  http://dev.mysql.com/doc/refman/5.6/en/identifiers.html 
schema_name     : tmpName=ID {System.out.println("schema name = " + $tmpName.text);};
table_name          : tmpName=ID {System.out.println("schema name = " + $tmpName.text);};
engine_name     : tmpName=ID {System.out.println("schema name = " + $tmpName.text);};
column_name     : tmpName=ID {System.out.println("schema name = " + $tmpName.text);};
view_name           : tmpName=ID {System.out.println("schema name = " + $tmpName.text);};
parser_name     : tmpName=ID {System.out.println("schema name = " + $tmpName.text);};
index_name          : tmpName=ID {System.out.println("schema name = " + $tmpName.text);};
partition_name      : tmpName=ID {System.out.println("schema name = " + $tmpName.text);};
partition_logical_name      : tmpName=ID {System.out.println("schema name = " + $tmpName.text);};
constraint_symbol_name      : tmpName=ID {System.out.println("schema name = " + $tmpName.text);};
foreign_key_symbol_name : tmpName=ID {System.out.println("schema name = " + $tmpName.text);};
collation_name      : tmpName=ID {System.out.println("schema name = " + $tmpName.text);};
event_name          : tmpName=ID {System.out.println("schema name = " + $tmpName.text);};
user_name           : tmpName=ID {System.out.println("schema name = " + $tmpName.text);};
function_name       : tmpName=ID {System.out.println("schema name = " + $tmpName.text);};
procedure_name      : tmpName=ID {System.out.println("schema name = " + $tmpName.text);};
server_name     : tmpName=ID {System.out.println("schema name = " + $tmpName.text);};
wrapper_name        : tmpName=ID {System.out.println("schema name = " + $tmpName.text);};
alias           : ( AS_SYM )? tmpName=ID {System.out.println("schema name = " + $tmpName.text);};
