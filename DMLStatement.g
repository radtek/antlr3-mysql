parser grammar DMLStatement;

// JOIN Syntax ----------  http://dev.mysql.com/doc/refman/5.6/en/join.html  ---------------
table_references:
        table_reference ( COMMA table_reference )*
;
table_reference:
    table_factor1 | table_atom
;
table_factor1:
    table_factor2 (  (INNER_SYM | CROSS)? JOIN_SYM table_atom (join_condition)?  )?  
;
table_factor2:
    table_factor3 (  STRAIGHT_JOIN table_atom (ON expression)?  )?  
;
table_factor3:
    table_factor4 (  (LEFT|RIGHT) (OUTER)? JOIN_SYM table_factor4 join_condition  )?  
;
table_factor4:
    table_atom (  NATURAL ( (LEFT|RIGHT) (OUTER)? )? JOIN_SYM table_atom )?
;

table_atom:
      ( table_spec (partition_clause)? (alias)? (index_hint_list)? )
    | ( subquery alias )
    | ( LPAREN table_references RPAREN )
    | ( OJ_SYM table_reference LEFT OUTER JOIN_SYM table_reference ON expression )
;

join_condition:
      (ON expression) | (USING_SYM column_list)
;

index_hint_list:    
    index_hint (COMMA index_hint)*
;

index_options:
    (INDEX_SYM | KEY_SYM) (  FOR_SYM ((JOIN_SYM) | (ORDER_SYM BY_SYM) | (GROUP_SYM BY_SYM))  )?
;

index_hint:
      USE_SYM    index_options LPAREN (index_list)? RPAREN
    | IGNORE_SYM index_options LPAREN index_list RPAREN
    | FORCE_SYM  index_options LPAREN index_list RPAREN
;

index_list:
    index_name (COMMA index_name)*
;

partition_clause:
    PARTITION_SYM LPAREN partition_names RPAREN
;

partition_names:    partition_name (COMMA partition_name)* ;



// select ------  http://dev.mysql.com/doc/refman/5.6/en/select.html
select_statement:
        select_expression ( (UNION_SYM (ALL)?) select_expression )* 
;

select_expression:
    SELECT 
    ( ALL | DISTINCT | DISTINCTROW )? 
    (HIGH_PRIORITY)?
    (STRAIGHT_JOIN)?
    (SQL_SMALL_RESULT)? (SQL_BIG_RESULT)? (SQL_BUFFER_RESULT)?
    (SQL_CACHE_SYM | SQL_NO_CACHE_SYM)? (SQL_CALC_FOUND_ROWS)?

    select_list

    (
        FROM table_references
        ( partition_clause )?
        ( where_clause )?
        ( groupby_clause )?
        ( having_clause )?
    ) ?

    ( orderby_clause )?
    ( limit_clause )?
    ( ( FOR_SYM UPDATE) | (LOCK IN_SYM SHARE_SYM MODE_SYM) )?
;

where_clause:
    WHERE expression
;

groupby_clause:
    GROUP_SYM BY_SYM groupby_item (COMMA groupby_item)* (WITH ROLLUP_SYM)?
;
groupby_item:   column_spec | INTEGER_NUM | bit_expr ;

having_clause:
    HAVING expression
;

orderby_clause:
    ORDER_SYM BY_SYM orderby_item (COMMA orderby_item)*
;
orderby_item:   groupby_item (ASC | DESC)? ;

limit_clause:
    LIMIT ((offset COMMA)? row_count) | (row_count OFFSET_SYM offset)
;
offset:     INTEGER_NUM ;
row_count:  INTEGER_NUM ;

select_list:
    ( ( displayed_column ( COMMA displayed_column )*)
    | ASTERISK )
;

column_list:
    LPAREN column_spec (COMMA column_spec)* RPAREN
;

subquery:
    LPAREN select_statement RPAREN
;

table_spec:
    ( schema_name DOT )? table_name
;

table_spec_list:
    table_spec (COMMA table_spec)*
;

displayed_column :
    ( table_spec DOT ASTERISK )
    |
    ( column_spec (alias)? )
    |
    ( bit_expr (alias)? )
;


// delete ------  http://dev.mysql.com/doc/refman/5.6/en/delete.html  ----
delete_statements:
    DELETE_SYM (LOW_PRIORITY)? (QUICK)? (IGNORE_SYM)?
    ( delete_single_table_statement | delete_multiple_table_statement1 | delete_multiple_table_statement2 )
;

delete_single_table_statement:
    FROM table_spec
    (partition_clause)?
    (where_clause)?
    (orderby_clause)?
    (limit_clause)?
;

delete_multiple_table_statement1:
    table_spec (ALL_FIELDS)? (COMMA table_spec (ALL_FIELDS)?)*
    FROM table_references
    (where_clause)?

;
delete_multiple_table_statement2:
    FROM table_spec (ALL_FIELDS)? (COMMA table_spec (ALL_FIELDS)?)*
    USING_SYM table_references
    (where_clause)?
;





// insert ---------  http://dev.mysql.com/doc/refman/5.6/en/insert.html  -------------------------
insert_statements :
    insert_statement1 | insert_statement2 | insert_statement3
;

insert_header:
    INSERT (LOW_PRIORITY | HIGH_PRIORITY)? (IGNORE_SYM)?
    (INTO)? table_spec
    (partition_clause)?
;

insert_subfix:
    ON DUPLICATE_SYM KEY_SYM UPDATE column_spec EQ_SYM expression (COMMA column_spec EQ_S
YM expression)*
;

insert_statement1:
    insert_header
    (column_list)?
    value_list_clause
    ( insert_subfix )?
;
value_list_clause:  (VALUES | VALUE_SYM) column_value_list (COMMA column_value_list)*;
column_value_list:  LPAREN (bit_expr|DEFAULT) (COMMA (bit_expr|DEFAULT) )* RPAREN ;

insert_statement2:
    insert_header
    set_columns_cluase
    ( insert_subfix )?
;
set_columns_cluase: SET_SYM set_column_cluase ( COMMA set_column_cluase )*;
set_column_cluase:  column_spec EQ_SYM (expression|DEFAULT) ;

insert_statement3:
    insert_header
    (column_list)?
    select_expression
    ( insert_subfix )?
;



// update --------  http://dev.mysql.com/doc/refman/5.6/en/update.html  --------
update_statements :
    single_table_update_statement | multiple_table_update_statement
;

single_table_update_statement:
UPDATE (LOW_PRIORITY)? (IGNORE_SYM)? table_reference
    set_columns_cluase
    (where_clause)?
    (orderby_clause)?
    (limit_clause)?
;

multiple_table_update_statement:
    UPDATE (LOW_PRIORITY)? (IGNORE_SYM)? table_references
    set_columns_cluase
    (where_clause)?
;


// call -----------  http://dev.mysql.com/doc/refman/5.6/en/call.html 
call_statement:
    CALL_SYM procedure_name (LPAREN ( bit_expr (COMMA bit_expr)* )? RPAREN)?
;


// do --------------  http://dev.mysql.com/doc/refman/5.6/en/do.html 
do_statement:
    DO_SYM root_statement (COMMA root_statement)*
;


// handler ------------  http://dev.mysql.com/doc/refman/5.6/en/handler.html 
handler_statements:
    HANDLER_SYM table_name
    (open_handler_statement | handler_statement1 | handler_statement2 | handler_statement3 | close_handler_statement)
;

open_handler_statement:
    OPEN_SYM (alias)?
;

handler_statement1:
    READ_SYM index_name relational_op LPAREN bit_expr (COMMA bit_expr)* RPAREN
    (where_clause)? (limit_clause)?
;

handler_statement2:
    READ_SYM index_name (FIRST_SYM | NEXT_SYM | PREV_SYM | LAST_SYM)
    (where_clause)? (limit_clause)?
;

handler_statement3:
    READ_SYM (FIRST_SYM | NEXT_SYM)
    (where_clause)? (limit_clause)?
;

close_handler_statement:
    CLOSE_SYM
;

// load data ------------  http://dev.mysql.com/doc/refman/5.6/en/load-data.html 
load_data_statement:
    LOAD DATA_SYM (LOW_PRIORITY | CONCURRENT)? (LOCAL_SYM)? INFILE TEXT_STRING
    (REPLACE | IGNORE_SYM)?
    INTO TABLE table_spec
    (partition_clause)?
    (CHARACTER_SYM SET_SYM charset_name)?
    (
        (FIELDS_SYM | COLUMNS_SYM)
        (TERMINATED BY_SYM TEXT_STRING)?
        ((OPTIONALLY)? ENCLOSED BY_SYM TEXT_STRING)?
        (ESCAPED BY_SYM TEXT_STRING)?
    )?
    (
        LINES
        (STARTING BY_SYM TEXT_STRING)?
        (TERMINATED BY_SYM TEXT_STRING)?
    )?
    (IGNORE_SYM INTEGER_NUM (LINES | ROWS_SYM))?
    (LPAREN (column_spec|USER_VAR) (COMMA (column_spec|USER_VAR))* RPAREN)?
    (set_columns_cluase)?
;






// load xml ---------------  http://dev.mysql.com/doc/refman/5.6/en/load-xml.html  ----------------------
load_xml_statement:
    LOAD XML_SYM (LOW_PRIORITY | CONCURRENT)? (LOCAL_SYM)? INFILE TEXT_STRING
    (REPLACE | IGNORE_SYM)?
    INTO TABLE table_spec
    (partition_clause)?
    (CHARACTER_SYM SET_SYM charset_name)?
    (ROWS_SYM IDENTIFIED_SYM BY_SYM TEXT_STRING)?
    (IGNORE_SYM INTEGER_NUM (LINES | ROWS_SYM))?
    (LPAREN (column_spec|USER_VAR) (COMMA (column_spec|USER_VAR))* RPAREN)?
    (set_columns_cluase)?
;






// replace -------------------  http://dev.mysql.com/doc/refman/5.6/en/replace.html  ---------------------
replace_statement:
    replace_statement_header
    ( replace_statement1 | replace_statement2 | replace_statement3 )
;

replace_statement_header:
    REPLACE (LOW_PRIORITY | DELAYED_SYM)?
    (INTO)? table_name
    (partition_clause)?
;

replace_statement1:
    (column_list)?
    value_list_clause
;

replace_statement2:
    set_columns_cluase
;

replace_statement3:
    (column_list)?
    select_statement
;
