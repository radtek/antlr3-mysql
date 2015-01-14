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
