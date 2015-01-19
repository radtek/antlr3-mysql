parser grammar Expression;

// expression statement -------  http://dev.mysql.com/doc/refman/5.6/en/expressions.html -------------

expression_list:
    LPAREN expression ( COMMA expression )* RPAREN ;

expression:     exp_factor1 ( OR_OP exp_factor1 )* ; 
exp_factor1:    exp_factor2 ( XOR exp_factor2 )* ; 
exp_factor2:    exp_factor3 ( AND_OP exp_factor3 )* ; 
exp_factor3:    (NOT)? exp_factor4 ;
exp_factor4:    bool_primary ( IS (NOT)? (boolean_literal|NULL) )? ; 
bool_primary:
      ( predicate relational_op predicate ) 
    | ( predicate relational_op ( ALL | ANY )? subquery )
    | ( NOT? EXISTS subquery )
    | predicate 
;

predicate:
      ( bit_expr (NOT)? IN (subquery | expression_list) )
    | ( bit_expr (NOT)? BETWEEN bit_expr AND predicate )
    | ( bit_expr SOUNDS LIKE bit_expr )
    | ( bit_expr (NOT)? LIKE simple_expr (ESCAPE simple_expr)? )
    | ( bit_expr (NOT)? REGEXP bit_expr )
    | ( bit_expr )
;

relational_op:
    EQ | LTH | GTH | NOT_EQ | LET | GET  ;

bit_expr:
    factor1 ( VERTBAR factor1 )? ;
factor1:
    factor2 ( BITAND factor2 )? ;
factor2:
    factor3 ( (SHIFT_LEFT|SHIFT_RIGHT) factor3 )? ;
factor3:
    factor4 ( (PLUS|MINUS) factor4 )? ;
factor4:
    factor5 ( (ASTERISK|DIVIDE_OP|MOD_OP|POWER_OP) factor5 )? ;
factor5:
    factor6 ( (PLUS_OP|MINUS_OP) interval_expr )? ;
factor6:
    (PLUS_OP | MINUS_OP | NEGATION | BINARY) simple_expr
    | simple_expr ;

factor7:
    simple_expr (COLLATE collation_names)?;

simple_expr:
    literal_value
    | column_spec
    | function_call
    //| param_marker
    | USER_VAR
    | expression_list
    | (ROW expression_list)
    | subquery
    | EXISTS subquery
    //| {identifier expression}
    | match_against_statement
    | case_when_statement
    | interval_expr
;

search_modifier:    
    (IN NATURAL LANGUAGE MODE)
    | (IN NATURAL LANGUAGE MODE WITH QUERY EXPANSION)
    | (IN BOOLEAN MODE)
    | (WITH QUERY EXPANSION)
;

case_when_statement:
        case_when_statement1 | case_when_statement2
;

case_when_statement1:
        CASE
        ( WHEN expression THEN bit_expr )+
        ( ELSE bit_expr )?
        END
;

case_when_statement2:
        CASE bit_expr
        ( WHEN bit_expr THEN bit_expr )+
        ( ELSE bit_expr )?
        END
;

match_against_statement:    
    MATCH (column_spec (COMMA column_spec)* ) AGAINST (expression (search_modifier)? ) 
;

interval_expr:
    INTERVAL expression interval_unit
;

interval_unit:
      SECOND
    | MINUTE
    | HOUR 
    | DAY
    | WEEK 
    | MONTH
    | QUARTER
    | YEAR 
    | SECOND_MICROSECOND
    | MINUTE_MICROSECOND
    | MINUTE_SECOND
    | HOUR_MICROSECOND
    | HOUR_SECOND
    | HOUR_MINUTE
    | DAY_MICROSECOND
    | DAY_SECOND
    | DAY_MINUTE
    | DAY_HOUR
    | YEAR_MONTH
;
