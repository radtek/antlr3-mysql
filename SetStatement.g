parser grammar SetStatement;

// set transaction - http://dev.mysql.com/doc/refman/5.6/en/set-transaction.html
set_transaction_statement:
    SET_SYM (GLOBAL_SYM | SESSION_SYM)? TRANSACTION set_transaction_characteristic (COMMA set_transaction_characteristic)*
;


set_transaction_characteristic:
    ISOLATION LEVEL_SYM (
        REPEATABLE_SYM READ_SYM | READ_SYM COMMITTED_SYM | READ_SYM UNCOMMITTED_SYM
            | SERIALIZABLE_SYM)
    | READ_SYM WRITE_SYM
    | READ_SYM ONLY_SYM
;


set_usrvar_statement:
    SET_SYM USER_VAR (SET_VAR | EQ_SYM) expression (COMMA USER_VAR (SET_VAR | EQ_SYM) expression)*
;

set_charset_statement:
    SET_SYM CHARACTER_SYM SET_SYM (DEFAULT | charset_name_str)
;

set_sysvar_statement:
    SET_SYM SYS_VAR (SET_VAR | EQ_SYM) expression (COMMA SYS_VAR (SET_VAR | EQ_SYM) expression)*
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
