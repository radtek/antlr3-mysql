parser grammar AdminStatement;

////////////////////// database admin statements ///////////////////////////
// table maintenance statements - http://dev.mysql.com/doc/refman/5.6/en/table-maintenance-sql.html

analyze_table_statement:
    ANALYZE (NO_WRITE_TO_BINLOG | LOCAL)? TABLE table_spec_list
;

check_table_statement:
    CHECK TABLE table_spec_list (FOR UPGRADE | QUICK | FAST | MEDIUM | EXTENDED | CHANGED)?
;

checksum_table_statement:
    CHECKSUM TABLE table_spec_list (QUICK | EXTENDED)?
;

optimize_table_statement:
    OPTIMIZE (NO_WRITE_TO_BINLOG | LOCAL)? TABLE table_spec_list
;

repair_table_statement:
    REPAIR (NO_WRITE_TO_BINLOG | LOCAL)? TABLE table_spec_list (QUICK)? (EXTENDED)? (USE_FRM)?
;


// set statements
set_usrvar_statement:
    SET USER_VAR (SET_VAR | EQ) expression (COMMA USER_VAR (SET_VAR | EQ) expression)*
;

set_charset_statement:
    SET CHARACTER SET (DEFAULT | charset_name_str)
;

set_sysvar_statement:
    SET sys_var_id (SET_VAR | EQ) expression (COMMA sys_var_id (SET_VAR | EQ) expression)*
;

sys_var_id:
    (SYS_VAR_PREFIX | GLOBAL | SESSION) ID
;

set_names_statement:
    SET NAMES (DEFAULT | charset_name_str (COLLATE collation_names_str)? )
;

charset_name_str:	
	  charset_name
	| string_literal
;

collation_names_str:
      collation_names
    | string_literal
;