parser grammar Expression;

// expression statement -------  http://dev.mysql.com/doc/refman/5.6/en/expressions.html -------------

expression_list:
    LPAREN expression ( COMMA expression )* RPAREN ;

expression:     exp_factor1 ( OR_SYM exp_factor1 )* ; 
exp_factor1:    exp_factor2 ( XOR exp_factor2 )* ; 
exp_factor2:    exp_factor3 ( AND_SYM exp_factor3 )* ; 
exp_factor3:    (NOT_SYM)? exp_factor4 ;
exp_factor4:    bool_primary ( IS_SYM (NOT_SYM)? (boolean_literal|NULL_SYM) )? ; 
bool_primary:
      ( predicate relational_op predicate ) 
    | ( predicate relational_op ( ALL | ANY )? subquery )
    | ( NOT_SYM? EXISTS subquery )
    | predicate 
;

predicate:
      ( bit_expr (NOT_SYM)? IN_SYM (subquery | expression_list) )
    | ( bit_expr (NOT_SYM)? BETWEEN bit_expr AND_SYM predicate )
    | ( bit_expr SOUNDS_SYM LIKE_SYM bit_expr )
    | ( bit_expr (NOT_SYM)? LIKE_SYM simple_expr (ESCAPE_SYM simple_expr)? )
    | ( bit_expr (NOT_SYM)? REGEXP bit_expr )
    | ( bit_expr )
;

relational_op:
    EQ_SYM | LTH | GTH | NOT_EQ | LET | GET  ;

bit_expr:
    factor1 ( VERTBAR factor1 )? ;
factor1:
    factor2 ( BITAND factor2 )? ;
factor2:
    factor3 ( (SHIFT_LEFT|SHIFT_RIGHT) factor3 )? ;
factor3:
    factor4 ( (PLUS|MINUS) factor4 )? ;
factor4:
    factor5 ( (ASTERISK|DIVIDE|MOD_SYM|POWER_OP) factor5 )? ;
factor5:
    factor6 ( (PLUS|MINUS) interval_expr )? ;
factor6:
    (PLUS | MINUS | NEGATION | BINARY) simple_expr
    | simple_expr ;

factor7:
    simple_expr (COLLATE_SYM collation_names)?;

simple_expr:
    literal_value
    | column_spec
    | function_call
    //| param_marker
    | USER_VAR
    | expression_list
    | (ROW_SYM expression_list)
    | subquery
    | EXISTS subquery
    //| {identifier expression}
    | match_against_statement
    | case_when_statement
    | interval_expr
;

search_modifier:    
    (IN_SYM NATURAL LANGUAGE MODE_SYM)
    | (IN_SYM NATURAL LANGUAGE MODE_SYM WITH QUERY_SYM EXPANSION_SYM)
    | (IN_SYM BOOLEAN_SYM MODE_SYM)
    | (WITH QUERY_SYM EXPANSION_SYM)
;

case_when_statement:
        case_when_statement1 | case_when_statement2
;

case_when_statement1:
        CASE_SYM
        ( WHEN_SYM expression THEN_SYM bit_expr )+
        ( ELSE_SYM bit_expr )?
        END_SYM
;

case_when_statement2:
        CASE_SYM bit_expr
        ( WHEN_SYM bit_expr THEN_SYM bit_expr )+
        ( ELSE_SYM bit_expr )?
        END_SYM
;

match_against_statement:    
    MATCH (column_spec (COMMA column_spec)* ) AGAINST (expression (search_modifier)? ) 
;

interval_expr:
    INTERVAL_SYM expression interval_unit
;

interval_unit:
      SECOND
    | MINUTE
    | HOUR 
    | DAY_SYM
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
