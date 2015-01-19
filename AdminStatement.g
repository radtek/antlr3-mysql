parser grammar AdminStatement;

////////////////////// database admin statements ///////////////////////////
// table maintenance statements - http://dev.mysql.com/doc/refman/5.6/en/table-maintenance-sql.html

analyze_table_statement:
    ANALYZE_SYM (NO_WRITE_TO_BINLOG | LOCAL_SYM)? TABLE table_spec_list
;

check_table_statement:
    CHECK_SYM TABLE table_spec_list (FOR_SYM UPGRADE_SYM | QUICK | FAST_SYM | MEDIUM_SYM | EXTENDED_SYM | CHANGED)?
;

checksum_table_statement:
    CHECKSUM_SYM TABLE table_spec_list (QUICK | EXTENDED_SYM)?
;

optimize_table_statement:
    OPTIMIZE (NO_WRITE_TO_BINLOG | LOCAL_SYM)? TABLE table_spec_list
;

repair_table_statement:
    REPAIR (NO_WRITE_TO_BINLOG | LOCAL_SYM)? TABLE table_spec_list (QUICK)? (EXTENDED_SYM)? (USE_FRM)?
;


// set statements
set_usrvar_statement:
    SET_SYM USER_VAR (SET_VAR | EQ_SYM) expression (COMMA USER_VAR (SET_VAR | EQ_SYM) expression)*
;

set_charset_statement:
    SET_SYM CHARACTER_SYM SET_SYM (DEFAULT | charset_name_str)
;

set_sysvar_statement:
    SET_SYM sys_var_id (SET_VAR | EQ_SYM) expression (COMMA SYS_VAR (SET_VAR | EQ_SYM) expression)*
;

set_names_statement:
    SET_SYM NAMES_SYM (DEFAULT | charset_name_str (COLLATE_SYM collation_names_str)? )
;

charset_name_str:
      charset_name
    | string_literal
;

collation_names_str:
      collation_names
    | string_literal
;
