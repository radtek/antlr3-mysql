parser grammar TransactionStatement;

///////////////// transactional_locking_statements ///////////////////
// http://dev.mysql.com/doc/refman/5.6/en/sql-syntax-transactions.html

// START TRANSACTION, COMMIT, and ROLLBACK Syntax ---> http://dev.mysql.com/doc/refman/5.6/en/commit.html 

start_transaction_statement:
    START_SYM TRANSACTION transaction_characteristic_list
;

// set transaction - http://dev.mysql.com/doc/refman/5.6/en/set-transaction.html
set_transaction_statement:
    SET_SYM (GLOBAL_SYM | SESSION_SYM)? TRANSACTION transaction_characteristic_list
;


transaction_characteristic_list:
    transaction_characteristic (COMMA transaction_characteristic)*
;

transaction_characteristic:
      WITH CONSISTENT_SYM SNAPSHOT_SYM
    | READ_SYM WRITE_SYM
    | READ_SYM ONLY_SYM
;

begin_statement:
    BEGIN_SYM (WORK_SYM)?
;

commit_statement:
    COMMIT_SYM (WORK_SYM)? (AND_KEY_SYM (NO_SYM)? CHAIN_SYM)? ((NO_SYM)? RELEASE_SYM)?
;

rollback_statement:
    ROLLBACK (WORK_SYM)? (AND_KEY_SYM (NO_SYM)? CHAIN_SYM)? ((NO_SYM)? RELEASE_SYM)?
;

// savepoint - http://dev.mysql.com/doc/refman/5.6/en/savepoint.html
savepoint_statement:
    SAVEPOINT ID
;

rollback_to_savepoint_statement:
    ROLLBACK (WORK_SYM)? TO_SYM ID
;

set_autocommit_statement:
    SET_SYM (SYS_VAR_PREFIX | GLOBAL_SYM | SESSION_SYM)? AUTOCOMMIT (EQ_SYM | SET_VAR) expression
;

release_savepoint_statement:
    RELEASE_SYM SAVEPOINT ID
;

// lock & unlock - http://dev.mysql.com/doc/refman/5.6/en/lock-tables.html
lock_table_statement:
    LOCK TABLES lock_type_list
;

lock_type_list:
    table_spec (alias)? lock_type (COMMA table_spec (alias)? lock_type)*
;

lock_type:
     READ_SYM (LOCAL_SYM)?
   | (LOW_PRIORITY)? WRITE_SYM
;

unlock_table_statement:
    UNLOCK_SYM TABLES
;

