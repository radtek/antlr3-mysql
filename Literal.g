parser grammar Literal;

// basic const data definition --------------------------------------------------
string_literal:     TEXT_STRING ;
number_literal:     (PLUS | MINUS)? (INTEGER_NUM | REAL_NUMBER) ;
//date_time_literal:    ;
hex_literal:        HEX_DIGIT ;
boolean_literal:    TRUE_SYM | FALSE_SYM ;
bit_literal:        BIT_NUM ;
null_literal:       NULL_SYM ;

// http://dev.mysql.com/doc/refman/5.6/en/literals.html
literal_value:
    ( string_literal 
    | number_literal 
    | hex_literal 
    | boolean_literal 
    | bit_literal 
    | null_literal 
    )
;

