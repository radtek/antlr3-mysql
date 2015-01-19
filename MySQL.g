grammar MySQL;

options 
{
    language=Java;
    output=AST;
    //ASTLabelType=CommonTree; 
    backtrack=true;
}

import Literal, Expression, Function, Identifier, Charset, TransactionStatement, AdminStatement, DMLStatement, DDLStatement;

fragment A_ :    'a' | 'A';
fragment B_ :    'b' | 'B';
fragment C_ :    'c' | 'C';
fragment D_ :    'd' | 'D';
fragment E_ :    'e' | 'E';
fragment F_ :    'f' | 'F';
fragment G_ :    'g' | 'G';
fragment H_ :    'h' | 'H';
fragment I_ :    'i' | 'I';
fragment J_ :    'j' | 'J';
fragment K_ :    'k' | 'K';
fragment L_ :    'l' | 'L';
fragment M_ :    'm' | 'M';
fragment N_ :    'n' | 'N';
fragment O_ :    'o' | 'O';
fragment P_ :    'p' | 'P';
fragment Q_ :    'q' | 'Q';
fragment R_ :    'r' | 'R';
fragment S_ :    's' | 'S';
fragment T_ :    't' | 'T';
fragment U_ :    'u' | 'U';
fragment V_ :    'v' | 'V';
fragment W_ :    'w' | 'W';
fragment X_ :    'x' | 'X';
fragment Y_ :    'y' | 'Y';
fragment Z_ :    'z' | 'Z';




ABS                : A_ B_ S_ ;
ACCESSIBLE            : A_ C_ C_ E_ S_ S_ I_ B_ L_ E_  ;
ACOS                : A_ C_ O_ S_ ;
ACTION                : A_ C_ T_ I_ O_ N_  ;
ADD                : A_ D_ D_  ;
ADDDATE                : A_ D_ D_ D_ A_ T_ E_  ;
ADDTIME                : A_ D_ D_ T_ I_ M_ E_  ;
AES_DECRYPT            : A_ E_ S_ '_' D_ E_ C_ R_ Y_ P_ T_  ;
AES_ENCRYPT            : A_ E_ S_ '_' E_ N_ C_ R_ Y_ P_ T_  ;
AFTER            : A_ F_ T_ E_ R_  ;
AGAINST                : A_ G_ A_ I_ N_ S_ T_  ;
AGGREGATE            : A_ G_ G_ R_ E_ G_ A_ T_ E_  ;
ALGORITHM            : A_ L_ G_ O_ R_ I_ T_ H_ M_  ;
ALL                : A_ L_ L_  ;
ALTER                : A_ L_ T_ E_ R_  ;
ANALYZE            : A_ N_ A_ L_ Y_ Z_ E_  ;
AND_KEY : A_ N_ D_ ;
ANY                : A_ N_ Y_ ;
ARMSCII8            : A_ R_ M_ S_ C_ I_ I_ '8'  ;
AS                : A_ S_  ;
ASC                : A_ S_ C_  ;
ASCII            : A_ S_ C_ I_ I_  ;
ASENSITIVE            : A_ S_ E_ N_ S_ I_ T_ I_ V_ E_  ;
ASIN                : A_ S_ I_ N_  ;
AT                : A_ T_  ;
ATAN                : A_ T_ A_ N_  ;
ATAN2                : A_ T_ A_ N_ '2'  ;
AUTHORS            : A_ U_ T_ H_ O_ R_ S_  ;
AUTO_INCREMENT        : A_ U_ T_ O_  '_' I_ N_ C_ R_ E_ M_ E_ N_ T_  ;
AUTOCOMMIT          : A_ U_ T_ O_ C_ O_ M_ M_ I_ T_ ;
AUTOEXTEND_SIZE        : A_ U_ T_ O_ E_ X_ T_ E_ N_ D_  '_' S_ I_ Z_ E_  ;
AVG                : A_ V_ G_;
AVG_ROW_LENGTH            : A_ V_ G_  '_' R_ O_ W_  '_' L_ E_ N_ G_ T_ H_  ;
BACKUP            : B_ A_ C_ K_ U_ P_  ;
BEFORE            : B_ E_ F_ O_ R_ E_  ;
BEGIN            : B_ E_ G_ I_ N_  ;
BENCHMARK            : B_ E_ N_ C_ H_ M_ A_ R_ K_  ;
BETWEEN                : B_ E_ T_ W_ E_ E_ N_  ;
BIG5                : B_ I_ G_ '5'  ;
BIGINT                : B_ I_ G_ I_ N_ T_  ;
BIN                : B_ I_ N_  ;
BINARY                : B_ I_ N_ A_ R_ Y_  ;
BINLOG            : B_ I_ N_ L_ O_ G_  ;
BIT_AND                : B_ I_ T_ '_' A_ N_ D_  ;
BIT_LENGTH            : B_ I_ T_ '_' L_ E_ N_ G_ T_ H_;
BIT_OR                : B_ I_ T_ '_' O_ R_  ;
BIT                : B_ I_ T_  ;
BIT_XOR                : B_ I_ T_ '_' X_ O_ R_  ;
BLOB            : B_ L_ O_ B_  ;
BLOCK            : B_ L_ O_ C_ K_  ;
BOOL            : B_ O_ O_ L_  ;
BOOLEAN            : B_ O_ O_ L_ E_ A_ N_  ;
BOTH                : B_ O_ T_ H_  ;
BTREE            : B_ T_ R_ E_ E_  ;
BY                : B_ Y_ ;
BYTE            : B_ Y_ T_ E_  ;
CACHE            : C_ A_ C_ H_ E_  ;
CALL            : C_ A_ L_ L_  ;
CASCADE                : C_ A_ S_ C_ A_ D_ E_  ;
CASCADED            : C_ A_ S_ C_ A_ D_ E_ D_  ;
CASE            : C_ A_ S_ E_  ;
CAST            : C_ A_ S_ T_  ;
CEIL                : C_ E_ I_ L_  ;
CEILING                : C_ E_ I_ L_ I_ N_ G_  ;
CHAIN            : C_ H_ A_ I_ N_  ;
CHANGE                : C_ H_ A_ N_ G_ E_  ;
CHANGED                : C_ H_ A_ N_ G_ E_ D_  ;
CHAR                : C_ H_ A_ R_  ;
CHAR_LENGTH            : (C_ H_ A_ R_ '_' L_ E_ N_ G_ T_ H_) | (C_ H_ A_ R_ A_ C_ T_ E_ R_ '_' L_ E_ N_ G_ T_ H_) ;
CHARACTER            : C_ H_ A_ R_ A_ C_ T_ E_ R_  ;
CHARSET                : C_ H_ A_ R_ S_ E_ T_  ;
CHECK            : C_ H_ E_ C_ K_  ;
CHECKSUM            : C_ H_ E_ C_ K_ S_ U_ M_  ;
CIPHER            : C_ I_ P_ H_ E_ R_  ;
CLIENT            : C_ L_ I_ E_ N_ T_  ;
CLOSE            : C_ L_ O_ S_ E_ ;
COALESCE            : C_ O_ A_ L_ E_ S_ C_ E_  ;
CODE            : C_ O_ D_ E_  ;
COERCIBILITY            : C_ O_ E_ R_ C_ I_ B_ I_ L_ I_ T_ Y_  ;
COLLATE            : C_ O_ L_ L_ A_ T_ E_  ;
COLLATION            : C_ O_ L_ L_ A_ T_ I_ O_ N_  ;
COLUMN_FORMAT            : C_ O_ L_ U_ M_ N_ '_' F_ O_ R_ M_ A_ T_  ;
COLUMN            : C_ O_ L_ U_ M_ N_  ;
COLUMNS            : C_ O_ L_ U_ M_ N_ S_  ;
COMMENT            : C_ O_ M_ M_ E_ N_ T_  ;
COMMIT            : C_ O_ M_ M_ I_ T_  ;
COMMITTED            : C_ O_ M_ M_ I_ T_ T_ E_ D_  ;
COMPACT            : C_ O_ M_ P_ A_ C_ T_  ;
COMPLETION            : C_ O_ M_ P_ L_ E_ T_ I_ O_ N_  ;
COMPRESS            : C_ O_ M_ P_ R_ E_ S_ S_  ;
COMPRESSED            : C_ O_ M_ P_ R_ E_ S_ S_ E_ D_  ;
CONCAT                : C_ O_ N_ C_ A_ T_  ;
CONCAT_WS            : C_ O_ N_ C_ A_ T_ '_' W_ S_  ;
CONCURRENT            : C_ O_ N_ C_ U_ R_ R_ E_ N_ T_  ;
CONDITION            : C_ O_ N_ D_ I_ T_ I_ O_ N_  ;
CONNECTION_ID            : C_ O_ N_ N_ E_ C_ T_ I_ O_ N_ '_' I_ D_  ;
CONNECTION            : C_ O_ N_ N_ E_ C_ T_ I_ O_ N_  ;
CONSISTENT            : C_ O_ N_ S_ I_ S_ T_ E_ N_ T_  ;
CONSTRAINT            : C_ O_ N_ S_ T_ R_ A_ I_ N_ T_  ;
CONTAINS            : C_ O_ N_ T_ A_ I_ N_ S_  ;
CONTEXT            : C_ O_ N_ T_ E_ X_ T_  ;
CONTINUE            : C_ O_ N_ T_ I_ N_ U_ E_  ;
CONTRIBUTORS        : C_ O_ N_ T_ R_ I_ B_ U_ T_ O_ R_ S_  ;
CONV                : C_ O_ N_ V_  ;
CONVERT            : C_ O_ N_ V_ E_ R_ T_  ;
CONVERT_TZ            : C_ O_ N_ V_ E_ R_ T_ '_' T_ Z_  ;
COPY            : C_ O_ P_ Y_  ;
COS                : C_ O_ S_  ;
COT                : C_ O_ T_  ;
COUNT                : C_ O_ U_ N_ T_  ;
CP1250                : C_ P_ '1250'  ;
CP1251                : C_ P_ '1251'  ;
CP1256                : C_ P_ '1256'  ;
CP1257                : C_ P_ '1257'  ;
CP850                : C_ P_ '850'  ;
CP852                : C_ P_ '852'  ;
CP866                : C_ P_ '866'  ;
CP932                : C_ P_ '932'  ;
CPU                : C_ P_ U_  ;
CRC32                : C_ R_ C_ '32'  ;
CREATE                : C_ R_ E_ A_ T_ E_ ;
CROSECOND            : C_ R_ O_ S_ E_ C_ O_ N_ D_  ;
CROSS                : C_ R_ O_ S_ S_  ;
CUBE            : C_ U_ B_ E_  ;
CURDATE            : (C_ U_ R_ D_ A_ T_ E_) | (C_ U_ R_ R_ E_ N_ T_ '_' D_ A_ T_ E_) ;
CURRENT_TIMESTAMP        : C_ U_ R_ R_ E_ N_ T_ '_' T_ I_ M_ E_ S_ T_ A_ M_ P_  ;
CURRENT_USER        : C_ U_ R_ R_ E_ N_ T_ '_' U_ S_ E_ R_ ;
CURSOR        : C_ U_ R_ S_ O_ R_  ;
CURTIME            : (C_ U_ R_ T_ I_ M_ E_) | (C_ U_ R_ R_ E_ N_ T_ '_' T_ I_ M_ E_) ;
DATABASE            : D_ A_ T_ A_ B_ A_ S_ E_  ;
DATAFILE            : D_ A_ T_ A_ F_ I_ L_ E_  ;
DATA            : D_ A_ T_ A_  ;
DATE_ADD            : D_ A_ T_ E_ '_' A_ D_ D_  ;
DATE_FORMAT            : D_ A_ T_ E_ '_' F_ O_ R_ M_ A_ T_  ;
DATE_SUB            : (D_ A_ T_ E_ '_' S_ U_ B_) | (S_ U_ B_ D_ A_ T_ E_) ;
DATE            : D_ A_ T_ E_  ;
DATEDIFF            : D_ A_ T_ E_ D_ I_ F_ F_  ;
DATETIME            : D_ A_ T_ E_ T_ I_ M_ E_  ;
DAY                : D_ A_ Y_  ;
DAY_HOUR            : D_ A_ Y_  '_' H_ O_ U_ R_  ;
DAY_MICROSECOND            : D_ A_ Y_  '_' M_ I_ C_ R_ O_ S_ E_ C_ O_ N_ D_  ;
DAY_MINUTE            : D_ A_ Y_  '_' M_ I_ N_ U_ T_ E_  ;
DAY_SECOND            : D_ A_ Y_  '_' S_ E_ C_ O_ N_ D_  ;
DAYNAME                : D_ A_ Y_ N_ A_ M_ E_  ;
DAYOFMONTH            : (D_ A_ Y_ O_ F_ M_ O_ N_ T_ H_) | (D_ A_ Y_) ;
DAYOFWEEK            : D_ A_ Y_ O_ F_ W_ E_ E_ K_  ;
DAYOFYEAR            : D_ A_ Y_ O_ F_ Y_ E_ A_ R_  ;
DEALLOCATE            : D_ E_ A_ L_ L_ O_ C_ A_ T_ E_  ; 
DEC8                : D_ E_ C_ '8'  ;
DECIMAL            : D_ E_ C_ I_ M_ A_ L_  ;
DECLARE            : D_ E_ C_ L_ A_ R_ E_  ;
DECODE                : D_ E_ C_ O_ D_ E_  ;
DEFAULT                : D_ E_ F_ A_ U_ L_ T_  ;
DEFINER                : D_ E_ F_ I_ N_ E_ R_ ;
DEGREES                : D_ E_ G_ R_ E_ E_ S_  ;
DELAY_KEY_WRITE        : D_ E_ L_ A_ Y_  '_' K_ E_ Y_  '_' W_ R_ I_ T_ E_  ;
DELAYED            : D_ E_ L_ A_ Y_ E_ D_  ;
DELETE            : D_ E_ L_ E_ T_ E_ ;
DES_DECRYPT            : D_ E_ S_ '_' D_ E_ C_ R_ Y_ P_ T_  ;
DES_ENCRYPT            : D_ E_ S_ '_' E_ N_ C_ R_ Y_ P_ T_  ;
DES_KEY_FILE            : D_ E_ S_  '_' K_ E_ Y_  '_' F_ I_ L_ E_  ;
DESC                : D_ E_ S_ C_  ;
DETERMINISTIC        : D_ E_ T_ E_ R_ M_ I_ N_ I_ S_ T_ I_ C_  ;
DIRECTORY            : D_ I_ R_ E_ C_ T_ O_ R_ Y_  ;
DISABLE            : D_ I_ S_ A_ B_ L_ E_  ;
DISCARD                : D_ I_ S_ C_ A_ R_ D_  ;
DISK            : D_ I_ S_ K_  ;
DISTINCT            : D_ I_ S_ T_ I_ N_ C_ T_ ;
DISTINCTROW            : D_ I_ S_ T_ I_ N_ C_ T_ R_ O_ W_ ;
DO                : D_ O_  ;
DOUBLE            : D_ O_ U_ B_ L_ E_  ;
DROP                : D_ R_ O_ P_  ;
DUAL            : D_ U_ A_ L_  ;
DUMPFILE            : D_ U_ M_ P_ F_ I_ L_ E_  ;
DUPLICATE            : D_ U_ P_ L_ I_ C_ A_ T_ E_  ;
DYNAMIC            : D_ Y_ N_ A_ M_ I_ C_  ;
EACH            : E_ A_ C_ H_  ;
ELSE            : E_ L_ S_ E_  ;
ELSIF            : E_ L_ S_ I_ F_ ;
ELT                : E_ L_ T_  ;
ENABLE            : E_ N_ A_ B_ L_ E_  ;
ENCLOSED            : E_ N_ C_ L_ O_ S_ E_ D_  ;
ENCODE                : E_ N_ C_ O_ D_ E_  ;
ENCRYPT                : E_ N_ C_ R_ Y_ P_ T_  ;
END                : E_ N_ D_ ;
ENDS            : E_ N_ D_ S_  ;
ENGINE            : E_ N_ G_ I_ N_ E_  ;
ENGINES            : E_ N_ G_ I_ N_ E_ S_  ;
ENUM                : E_ N_ U_ M_  ;
ERRORS                : E_ R_ R_ O_ R_ S_  ;
ESCAPE            : E_ S_ C_ A_ P_ E_  ;
ESCAPED                : E_ S_ C_ A_ P_ E_ D_  ;
EUCJPMS                : E_ U_ C_ J_ P_ M_ S_ ;
EUCKR                : E_ U_ C_ K_ R_  ;
EVENT            : E_ V_ E_ N_ T_  ;
EVENTS            : E_ V_ E_ N_ T_ S_  ;
EVERY            : E_ V_ E_ R_ Y_  ;
EXCHANGE            : E_ X_ C_ H_ A_ N_ G_ E_ '_' S_ Y_ M_  ;
EXECUTE            : E_ X_ E_ C_ U_ T_ E_  ;
EXCLUSIVE            : E_ X_ C_ L_ U_ S_ I_ V_ E_  ;
EXISTS                : E_ X_ I_ S_ T_ S_ ;
EXIT            : E_ X_ I_ T_  ;
EXP                : E_ X_ P_  ;
EXPANSION            : E_ X_ P_ A_ N_ S_ I_ O_ N_  ;
EXPORT_SET            : E_ X_ P_ O_ R_ T_ '_' S_ E_ T_  ;
EXTENDED            : E_ X_ T_ E_ N_ D_ E_ D_  ;
EXTENT_SIZE            : E_ X_ T_ E_ N_ T_  '_' S_ I_ Z_ E_  ;
EXTRACT                : E_ X_ T_ R_ A_ C_ T_  ;
FALSE            : F_ A_ L_ S_ E_ ;
FAST            : F_ A_ S_ T_  ;
FAULTS            : F_ A_ U_ L_ T_ S_  ;
FIELDS            : F_ I_ E_ L_ D_ S_  ;
FETCH            : F_ E_ T_ C_ H_  ;
FIELD                : F_ I_ E_ L_ D_  ;
FILE            : F_ I_ L_ E_  ;
FIND_IN_SET            : F_ I_ N_ D_ '_' I_ N_ '_' S_ E_ T_  ;
FIRST            : F_ I_ R_ S_ T_  ;
FIXED            : F_ I_ X_ E_ D_  ;
FLOAT            : F_ L_ O_ A_ T_  ;
FLOOR                : F_ L_ O_ O_ R_  ;
FLUSH            : F_ L_ U_ S_ H_  ;
FOR                : F_ O_ R_  ;
FORCE            : F_ O_ R_ C_ E_  ;
FOREIGN                : F_ O_ R_ E_ I_ G_ N_  ;
FORMAT                : F_ O_ R_ M_ A_ T_  ;
FOUND_ROWS            : F_ O_ U_ N_ D_ '_' R_ O_ W_ S_  ;
FOUND            : F_ O_ U_ N_ D_  ;
FROM                : F_ R_ O_ M_  ;
FROM_BASE64            : F_ R_ O_ M_ '_' B_ A_ S_ E_ '64';
FROM_DAYS            : F_ R_ O_ M_ '_' D_ A_ Y_ S_  ;
FROM_UNIXTIME            : F_ R_ O_ M_ '_' U_ N_ I_ X_ T_ I_ M_ E_  ;
FULL                : F_ U_ L_ L_  ;
FULLTEXT            : F_ U_ L_ L_ T_ E_ X_ T_  ;
FUNCTION            : F_ U_ N_ C_ T_ I_ O_ N_  ;
GB2312                : G_ B_ '2312'  ;
GBK                : G_ B_ K_  ;
GEOMETRY            : G_ E_ O_ M_ E_ T_ R_ Y_  ;
GEOMETRYCOLLECTION        : G_ E_ O_ M_ E_ T_ R_ Y_ C_ O_ L_ L_ E_ C_ T_ I_ O_ N_  ;
GEOSTD8                : G_ E_ O_ S_ T_ D_ '8'  ;
GET_FORMAT            : G_ E_ T_ '_' F_ O_ R_ M_ A_ T_  ;
GET_LOCK            : G_ E_ T_ '_' L_ O_ C_ K_  ;
GLOBAL            : G_ L_ O_ B_ A_ L_  ;
GRANT                : G_ R_ A_ N_ T_  ;
GRANTS                : G_ R_ A_ N_ T_ S_  ;
GREEK                : G_ R_ E_ E_ K_  ;
GROUP_CONCAT            : G_ R_ O_ U_ P_ '_' C_ O_ N_ C_ A_ T_  ;
GROUP            : G_ R_ O_ U_ P_  ;
HANDLER            : H_ A_ N_ D_ L_ E_ R_  ;
HASH            : H_ A_ S_ H_  ;
HAVING                : H_ A_ V_ I_ N_ G_  ;
HEBREW                : H_ E_ B_ R_ E_ W_  ;
HELP            : H_ E_ L_ P_  ;
HEX                : H_ E_ X_  ;
HIGH_PRIORITY            : H_ I_ G_ H_  '_' P_ R_ I_ O_ R_ I_ T_ Y_  ;
HOST            : H_ O_ S_ T_  ;
HOSTS            : H_ O_ S_ T_ S_  ;
HOUR                : H_ O_ U_ R_  ;
HOUR_MICROSECOND        : H_ O_ U_ R_  '_' M_ I_ C_ R_ O_ S_ E_ C_ O_ N_ D_  ;
HOUR_MINUTE            : H_ O_ U_ R_  '_' M_ I_ N_ U_ T_ E_  ;
HOUR_SECOND            : H_ O_ U_ R_  '_' S_ E_ C_ O_ N_ D_  ;
HP8                : H_ P_ '8'  ;
IDENTIFIED            : I_ D_ E_ N_ T_ I_ F_ I_ E_ D_  ;
IF                : I_ F_  ;
IFNULL                : I_ F_ N_ U_ L_ L_  ;
IGNORE            : I_ G_ N_ O_ R_ E_  ;
IMPORT                : I_ M_ P_ O_ R_ T_  ;
IN                : I_ N_  ;
INDEX            : I_ N_ D_ E_ X_  ;
INDEXES                : I_ N_ D_ E_ X_ E_ S_  ;
INET_ATON            : I_ N_ E_ T_ '_' A_ T_ O_ N_  ;
INET_NTOA            : I_ N_ E_ T_ '_' N_ T_ O_ A_  ;
INFILE                : I_ N_ F_ I_ L_ E_  ;
INITIAL_SIZE        : I_ N_ I_ T_ I_ A_ L_  '_' S_ I_ Z_ E_  ;
INNER            : I_ N_ N_ E_ R_  ;
INOUT            : I_ N_ O_ U_ T_  ;
INPLACE            : I_ N_ P_ L_ A_ C_ E_   ;
INSENSITIVE            : I_ N_ S_ E_ N_ S_ I_ T_ I_ V_ E_  ;
INSERT                : I_ N_ S_ E_ R_ T_  ;
INSERT_METHOD            : I_ N_ S_ E_ R_ T_  '_' M_ E_ T_ H_ O_ D_  ;
INSTALL            : I_ N_ S_ T_ A_ L_ L_  ;
INSTR                : I_ N_ S_ T_ R_  ;
INT                : I_ N_ T_  ;
INTEGER            : I_ N_ T_ E_ G_ E_ R_  ;
INTERVAL            : I_ N_ T_ E_ R_ V_ A_ L_  ;
INTO                : I_ N_ T_ O_  ;
INVOKER            : I_ N_ V_ O_ K_ E_ R_  ;
IO                : I_ O_  ;
IPC                : I_ P_ C_  ;
IS_FREE_LOCK            : I_ S_ '_' F_ R_ E_ E_ '_' L_ O_ C_ K_  ;
IS                : I_ S_  ;
IS_USED_LOCK            : I_ S_ '_' U_ S_ E_ D_ '_' L_ O_ C_ K_  ;
ISOLATION            : I_ S_ O_ L_ A_ T_ I_ O_ N_  ;
ISSUER            : I_ S_ S_ U_ E_ R_  ;
ITERATE            : I_ T_ E_ R_ A_ T_ E_  ;
JOIN            : J_ O_ I_ N_  ;
KEY_BLOCK_SIZE            : K_ E_ Y_  '_' B_ L_ O_ C_ K_  '_' S_ I_ Z_ E_  ;
KEY                : K_ E_ Y_  ;
KEYBCS2                : K_ E_ Y_ B_ C_ S_ '2'  ;
KEYS                : K_ E_ Y_ S_  ;
KILL            : K_ I_ L_ L_  ;
KOI8R                : K_ O_ I_ '8' R_  ;
KOI8U                : K_ O_ I_ '8' U_  ;
LANGUAGE            : L_ A_ N_ G_ U_ A_ G_ E_ ;
LAST_DAY            : L_ A_ S_ T_ '_' D_ A_ Y_  ;
LAST_INSERT_ID            : L_ A_ S_ T_ '_' I_ N_ S_ E_ R_ T_ '_' I_ D_  ;
LAST            : L_ A_ S_ T_  ;
LATIN1_BIN            : L_ A_ T_ I_ N_ '1_' B_ I_ N_  ;
LATIN1_GENERAL_CS        : L_ A_ T_ I_ N_ '1_' G_ E_ N_ E_ R_ A_ L_ '_' C_ S_  ;
LATIN1                : L_ A_ T_ I_ N_ '1'  ;
LATIN2                : L_ A_ T_ I_ N_ '2'  ;
LATIN5                : L_ A_ T_ I_ N_ '5'  ;
LATIN7                : L_ A_ T_ I_ N_ '7'  ;
LEADING                : L_ E_ A_ D_ I_ N_ G_  ;
LEAVE            : L_ E_ A_ V_ E_  ;
LEAVES                : L_ E_ A_ V_ E_ S_  ;
LEFT                : L_ E_ F_ T_  ;
LENGTH                : (L_ E_ N_ G_ T_ H_) | (O_ C_ T_ E_ T_ '_' L_ E_ N_ G_ T_ H_) ;
LESS            : L_ E_ S_ S_  ;
LEVEL            : L_ E_ V_ E_ L_  ;
LIKE            : L_ I_ K_ E_  ;
LIMIT                : L_ I_ M_ I_ T_  ;
LINEAR            : L_ I_ N_ E_ A_ R_  ;
LINES                : L_ I_ N_ E_ S_  ;
LINESTRING            : L_ I_ N_ E_ S_ T_ R_ I_ N_ G_  ;
LIST            : L_ I_ S_ T_  ;
LN                : L_ N_  ;
LOAD                : L_ O_ A_ D_  ;
LOAD_FILE            : L_ O_ A_ D_ '_' F_ I_ L_ E_  ;
LOCAL            : L_ O_ C_ A_ L_  ;
LOCATE                : (L_ O_ C_ A_ T_ E_) | (P_ O_ S_ I_ T_ I_ O_ N_)  ;
LOCK                : L_ O_ C_ K_ ;
LOCKS            : L_ O_ C_ K_ S_  ;
LOG                	: L_ O_ G_  ;
LOG10                : L_ O_ G_ '10'  ;
LOG2                : L_ O_ G_ '2'  ;
LOGFILE            : L_ O_ G_ F_ I_ L_ E_  ;
LOGS            : L_ O_ G_ S_  ;
LONG            : L_ O_ N_ G_  ;
LONGBLOB            : L_ O_ N_ G_ B_ L_ O_ B_  ;
LONGTEXT            : L_ O_ N_ G_ T_ E_ X_ T_  ;
LOOP            : L_ O_ O_ P_  ;
LOW_PRIORITY            : L_ O_ W_  '_' P_ R_ I_ O_ R_ I_ T_ Y_  ;
LOWER                : (L_ O_ W_ E_ R_) | (L_ C_ A_ S_ E_) ;
LPAD                : L_ P_ A_ D_  ;
LTRIM                : L_ T_ R_ I_ M_  ;
MACCE                : M_ A_ C_ C_ E_  ;
MACROMAN            : M_ A_ C_ R_ O_ M_ A_ N_  ;
MAKE_SET            : M_ A_ K_ E_ '_' S_ E_ T_  ;
MAKEDATE            : M_ A_ K_ E_ D_ A_ T_ E_  ;
MAKETIME            : M_ A_ K_ E_ T_ I_ M_ E_  ;
MASTER_CONNECT_RETRY        : M_ A_ S_ T_ E_ R_  '_' C_ O_ N_ N_ E_ C_ T_  '_' R_ E_ T_ R_ Y_  ;
MASTER_HOST            : M_ A_ S_ T_ E_ R_  '_' H_ O_ S_ T_  ;
MASTER_LOG_FILE        : M_ A_ S_ T_ E_ R_  '_' L_ O_ G_  '_' F_ I_ L_ E_  ;
MASTER_LOG_POS        : M_ A_ S_ T_ E_ R_  '_' L_ O_ G_  '_' P_ O_ S_  ;
MASTER_PASSWORD        : M_ A_ S_ T_ E_ R_  '_' P_ A_ S_ S_ W_ O_ R_ D_  ;
MASTER_PORT            : M_ A_ S_ T_ E_ R_  '_' P_ O_ R_ T_  ;
MASTER_POS_WAIT            : M_ A_ S_ T_ E_ R_ '_' P_ O_ S_ '_' W_ A_ I_ T_  ;
MASTER_SERVER_ID        : M_ A_ S_ T_ E_ R_  '_' S_ E_ R_ V_ E_ R_  '_' I_ D_  ;
MASTER_SSL_CA        : M_ A_ S_ T_ E_ R_  '_' S_ S_ L_  '_' C_ A_  ;
MASTER_SSL_CAPATH        : M_ A_ S_ T_ E_ R_  '_' S_ S_ L_  '_' C_ A_ P_ A_ T_ H_  ;
MASTER_SSL_CERT        : M_ A_ S_ T_ E_ R_  '_' S_ S_ L_  '_' C_ E_ R_ T_  ;
MASTER_SSL_CIPHER        : M_ A_ S_ T_ E_ R_  '_' S_ S_ L_  '_' C_ I_ P_ H_ E_ R_  ;
MASTER_SSL_KEY        : M_ A_ S_ T_ E_ R_  '_' S_ S_ L_  '_' K_ E_ Y_  ;
MASTER_SSL            : M_ A_ S_ T_ E_ R_  '_' S_ S_ L_  ;
MASTER_SSL_VERIFY_SERVER_CERT    : M_ A_ S_ T_ E_ R_  '_' S_ S_ L_  '_' V_ E_ R_ I_ F_ Y_  '_' S_ E_ R_ V_ E_ R_  '_' C_ E_ R_ T_  ;
MASTER            : M_ A_ S_ T_ E_ R_  ;
MASTER_USER            : M_ A_ S_ T_ E_ R_  '_' U_ S_ E_ R_  ;
MATCH                : M_ A_ T_ C_ H_  ;
MAX                : M_ A_ X_  ;
MAX_CONNECTIONS_PER_HOUR    : M_ A_ X_  '_' C_ O_ N_ N_ E_ C_ T_ I_ O_ N_ S_  '_' P_ E_ R_  '_' H_ O_ U_ R_  ;
MAX_QUERIES_PER_HOUR        : M_ A_ X_  '_' Q_ U_ E_ R_ I_ E_ S_  '_' P_ E_ R_  '_' H_ O_ U_ R_  ;
MAX_ROWS            : M_ A_ X_  '_' R_ O_ W_ S_  ;
MAX_SIZE            : M_ A_ X_  '_' S_ I_ Z_ E_  ;
MAX_UPDATES_PER_HOUR        : M_ A_ X_  '_' U_ P_ D_ A_ T_ E_ S_  '_' P_ E_ R_  '_' H_ O_ U_ R_  ;
MAX_USER_CONNECTIONS    : M_ A_ X_  '_' U_ S_ E_ R_  '_' C_ O_ N_ N_ E_ C_ T_ I_ O_ N_ S_  ;
MAXVALUE            : M_ A_ X_ V_ A_ L_ U_ E_  ;
MD5                : M_ D_ '5'  ;
MEDIUM            : M_ E_ D_ I_ U_ M_  ;
MEDIUMBLOB            : M_ E_ D_ I_ U_ M_ B_ L_ O_ B_  ;
MEDIUMINT            : M_ E_ D_ I_ U_ M_ I_ N_ T_  ;
MEDIUMTEXT            : M_ E_ D_ I_ U_ M_ T_ E_ X_ T_  ;
MEMORY            : M_ E_ M_ O_ R_ Y_  ;
MERGE            : M_ E_ R_ G_ E_  ;
MICROSECOND            : M_ I_ C_ R_ O_ S_ E_ C_ O_ N_ D_  ;
MID                : M_ I_ D_  ;
MIGRATE            : M_ I_ G_ R_ A_ T_ E_  ;
MIN                : M_ I_ N_  ;
MIN_ROWS            : M_ I_ N_  '_' R_ O_ W_ S_  ;
MINUTE                : M_ I_ N_ U_ T_ E_  ;
MINUTE_MICROSECOND        : M_ I_ N_ U_ T_ E_  '_' M_ I_ C_ R_ O_ S_ E_ C_ O_ N_ D_  ;
MINUTE_SECOND            : M_ I_ N_ U_ T_ E_  '_' S_ E_ C_ O_ N_ D_  ;
MOD                : M_ O_ D_  ;
MODE            : M_ O_ D_ E_  ;
MODIFIES            : M_ O_ D_ I_ F_ I_ E_ S_  ;
MODIFY            : M_ O_ D_ I_ F_ Y_  ;
MONTH                : M_ O_ N_ T_ H_  ;
MONTHNAME            : M_ O_ N_ T_ H_ N_ A_ M_ E_  ;
MULTILINESTRING            : M_ U_ L_ T_ I_ L_ I_ N_ E_ S_ T_ R_ I_ N_ G_  ;
MULTIPOINT            : M_ U_ L_ T_ I_ P_ O_ I_ N_ T_  ;
MULTIPOLYGON            : M_ U_ L_ T_ I_ P_ O_ L_ Y_ G_ O_ N_  ;
MUTEX            : M_ U_ T_ E_ X_  ;
NAME_CONST            : N_ A_ M_ E_ '_' C_ O_ N_ S_ T_  ;
NAME            : N_ A_ M_ E_  ;
NAMES            : N_ A_ M_ E_ S_  ;
NATIONAL            : N_ A_ T_ I_ O_ N_ A_ L_  ;
NATURAL                : N_ A_ T_ U_ R_ A_ L_  ;
NCHAR            : N_ C_ H_ A_ R_  ;
NEW                : N_ E_ W_  ;
NEXT            : N_ E_ X_ T_  ;
NO                : N_ O_  ;
NO_WAIT            : N_ O_  '_' W_ A_ I_ T_  ;
NO_WRITE_TO_BINLOG        : N_ O_  '_' W_ R_ I_ T_ E_  '_' T_ O_  '_' B_ I_ N_ L_ O_ G_  ;
NODEGROUP            : N_ O_ D_ E_ G_ R_ O_ U_ P_  ;
NONE            : N_ O_ N_ E_  ;
NOT                : (N_ O_ T_) | ('!') ;
NOW                : (N_ O_ W_) | (L_ O_ C_ A_ L_ T_ I_ M_ E_) | (L_ O_ C_ A_ L_ T_ I_ M_ E_ S_ T_ A_ M_ P_) | (C_ U_ R_ R_ E_ N_ T_ '_' T_ I_ M_ E_ S_ T_ A_ M_ P_);
NULL            : N_ U_ L_ L_  ;
NUMERIC            : N_ U_ M_ E_ R_ I_ C_  ;
NVARCHAR            : N_ V_ A_ R_ C_ H_ A_ R_  ;
OCT                : O_ C_ T_  ;
OFFSET            : O_ F_ F_ S_ E_ T_  ;
OJ                : O_ J_  ;
OLD_PASSWORD            : O_ L_ D_  '_' P_ A_ S_ S_ W_ O_ R_ D_  ;
ON                : O_ N_  ;
ONE_SHOT            : O_ N_ E_  '_' S_ H_ O_ T_  ;
ONE                : O_ N_ E_  ;
ONLY            : O_ N_ L_ Y_ ;
OPEN            : O_ P_ E_ N_  ;
OPTIMIZE            : O_ P_ T_ I_ M_ I_ Z_ E_  ;
OPTION                : O_ P_ T_ I_ O_ N_  ;
OPTIONALLY            : O_ P_ T_ I_ O_ N_ A_ L_ L_ Y_  ;
OPTIONS            : O_ P_ T_ I_ O_ N_ S_  ;
ORD                : O_ R_ D_  ;
ORDER            : O_ R_ D_ E_ R_  ;
OUT                : O_ U_ T_  ;
OUTER                : O_ U_ T_ E_ R_  ;
OUTFILE                : O_ U_ T_ F_ I_ L_ E_  ;
OWNER            : O_ W_ N_ E_ R_  ;
PACK_KEYS            : P_ A_ C_ K_  '_' K_ E_ Y_ S_  ;
PAGE_CHECKSUM        : P_ A_ G_ E_  '_' C_ H_ E_ C_ K_ S_ U_ M_  ;
PAGE            : P_ A_ G_ E_  ;
PARSER            : P_ A_ R_ S_ E_ R_  ;
PARTIAL                : P_ A_ R_ T_ I_ A_ L_  ;
PARTITION            : P_ A_ R_ T_ I_ T_ I_ O_ N_  ;
PARTITIONING        : P_ A_ R_ T_ I_ T_ I_ O_ N_ I_ N_ G_  ;
PARTITIONS            : P_ A_ R_ T_ I_ T_ I_ O_ N_ S_  ;
PASSWORD            : P_ A_ S_ S_ W_ O_ R_ D_  ;
PERIOD_ADD            : P_ E_ R_ I_ O_ D_ '_' A_ D_ D_  ;
PERIOD_DIFF            : P_ E_ R_ I_ O_ D_ '_' D_ I_ F_ F_  ;
PHASE            : P_ H_ A_ S_ E_  ;
PI                    : P_ I_  ;
PLUGIN            : P_ L_ U_ G_ I_ N_  ;
PLUGINS            : P_ L_ U_ G_ I_ N_ S_  ;
POINT            : P_ O_ I_ N_ T_  ;
POLYGON                : P_ O_ L_ Y_ G_ O_ N_  ;
PORT            : P_ O_ R_ T_  ;
POW                    : P_ O_ W_  ;
POWER                : P_ O_ W_ E_ R_  ;
PRECISION            : P_ R_ E_ C_ I_ S_ I_ O_ N_  ;
PREPARE            : P_ R_ E_ P_ A_ R_ E_  ;
PRESERVE        : P_ R_ E_ S_ E_ R_ V_ E_  ;
PREV            : P_ R_ E_ V_  ;
PRIMARY            : P_ R_ I_ M_ A_ R_ Y_  ;
PRIVILEGES            : P_ R_ I_ V_ I_ L_ E_ G_ E_ S_  ;
PROCEDURE            : P_ R_ O_ C_ E_ D_ U_ R_ E_  ;
PROCESS                : P_ R_ O_ C_ E_ S_ S_  ;
PROCESSLIST        : P_ R_ O_ C_ E_ S_ S_ L_ I_ S_ T_  ;
PROFILE            : P_ R_ O_ F_ I_ L_ E_  ;
PROFILES        : P_ R_ O_ F_ I_ L_ E_ S_  ;
PURGE                : P_ U_ R_ G_ E_  ;
QUARTER                : Q_ U_ A_ R_ T_ E_ R_  ;
QUERY            : Q_ U_ E_ R_ Y_  ;
QUICK                : Q_ U_ I_ C_ K_  ;
QUOTE                : Q_ U_ O_ T_ E_  ;
RADIANS                : R_ A_ D_ I_ A_ N_ S_  ;
RAND                : R_ A_ N_ D_  ;
RANGE            : R_ A_ N_ G_ E_  ;
READ_ONLY       : R_ E_ A_ D_  '_' O_ N_ L_ Y_  ;
READ            : R_ E_ A_ D_  ;
READ_WRITE      : R_ E_ A_ D_  '_' W_ R_ I_ T_ E_  ;
READS            : R_ E_ A_ D_ S_  ;
REAL                : R_ E_ A_ L_  ;
REBUILD            : R_ E_ B_ U_ I_ L_ D_  ;
RECOVER            : R_ E_ C_ O_ V_ E_ R_  ;
REDO_BUFFER_SIZE        : R_ E_ D_ O_  '_' B_ U_ F_ F_ E_ R_  '_' S_ I_ Z_ E_  ;
REDOFILE            : R_ E_ D_ O_ F_ I_ L_ E_  ;
REDUNDANT            : R_ E_ D_ U_ N_ D_ A_ N_ T_  ;
REFERENCES            : R_ E_ F_ E_ R_ E_ N_ C_ E_ S_  ;
REGEXP                : (R_ E_ G_ E_ X_ P_) | (R_ L_ I_ K_ E_);
RELAY_LOG_FILE        : R_ E_ L_ A_ Y_  '_' L_ O_ G_  '_' F_ I_ L_ E_  ;
RELAY_LOG_POS        : R_ E_ L_ A_ Y_  '_' L_ O_ G_  '_' P_ O_ S_  ;
RELEASE_LOCK            : R_ E_ L_ E_ A_ S_ E_ '_' L_ O_ C_ K_  ;
RELEASE            : R_ E_ L_ E_ A_ S_ E_  ;
RELOAD                : R_ E_ L_ O_ A_ D_  ;
REMOVE            : R_ E_ M_ O_ V_ E_  ;
RENAME                : R_ E_ N_ A_ M_ E_  ;
REORGANIZE            : R_ E_ O_ R_ G_ A_ N_ I_ Z_ E_  ;
REPAIR                : R_ E_ P_ A_ I_ R_  ;
REPEAT                : R_ E_ P_ E_ A_ T_  ;
REPEATABLE            : R_ E_ P_ E_ A_ T_ A_ B_ L_ E_  ;
REPLACE                : R_ E_ P_ L_ A_ C_ E_  ;
REPLICATION            : R_ E_ P_ L_ I_ C_ A_ T_ I_ O_ N_  ;
REQUIRE            : R_ E_ Q_ U_ I_ R_ E_  ;
RESET            : R_ E_ S_ E_ T_  ;
RESOURCES            : U_ S_ E_ R_  '_' R_ E_ S_ O_ U_ R_ C_ E_ S_  ;
RESTORE            : R_ E_ S_ T_ O_ R_ E_  ;
RESTRICT            : R_ E_ S_ T_ R_ I_ C_ T_  ;
RESUME            : R_ E_ S_ U_ M_ E_  ;
RETURN            : R_ E_ T_ U_ R_ N_  ;
RETURNS            : R_ E_ T_ U_ R_ N_ S_  ;
REVERSE                : R_ E_ V_ E_ R_ S_ E_  ;
REVOKE                : R_ E_ V_ O_ K_ E_  ;
RIGHT                : R_ I_ G_ H_ T_  ;
ROLLBACK            : R_ O_ L_ L_ B_ A_ C_ K_ ;
ROLLUP            : R_ O_ L_ L_ U_ P_  ;
ROUND                : R_ O_ U_ N_ D_  ;
ROUTINE            : R_ O_ U_ T_ I_ N_ E_  ;
ROW_FORMAT            : R_ O_ W_  '_' F_ O_ R_ M_ A_ T_  ;
ROW                : R_ O_ W_  ;
ROWS            : R_ O_ W_ S_  ;
RPAD                : R_ P_ A_ D_  ;
RTREE            : R_ T_ R_ E_ E_  ;
RTRIM                : R_ T_ R_ I_ M_  ;
SAVEPOINT            : S_ A_ V_ E_ P_ O_ I_ N_ T_ ;
SCHEDULE            : S_ C_ H_ E_ D_ U_ L_ E_  ;
SCHEMA                : S_ C_ H_ E_ M_ A_  ;
SEC_TO_TIME            : S_ E_ C_ '_' T_ O_ '_' T_ I_ M_ E_  ;
SECOND                : S_ E_ C_ O_ N_ D_  ;
SECOND_MICROSECOND        : S_ E_ C_ O_ N_ D_  '_' M_ I_ C_ R_ O_ S_ E_ C_ O_ N_ D_  ;
SECURITY            : S_ E_ C_ U_ R_ I_ T_ Y_  ;
SELECT                : S_ E_ L_ E_ C_ T_ ;
SENSITIVE            : S_ E_ N_ S_ I_ T_ I_ V_ E_  ;
SEPARATOR            : S_ E_ P_ A_ R_ A_ T_ O_ R_  ;
SERIAL            : S_ E_ R_ I_ A_ L_  ;
SERIALIZABLE        : S_ E_ R_ I_ A_ L_ I_ Z_ A_ B_ L_ E_  ;
SERVER            : S_ E_ R_ V_ E_ R_  ;
SESSION            : S_ E_ S_ S_ I_ O_ N_  ;
SESSION_USER            : S_ E_ S_ S_ I_ O_ N_ '_' U_ S_ E_ R_  ;
SET                : S_ E_ T_ ;
SHARED            : S_ H_ A_ R_ E_ D_  ;
SHARE            : S_ H_ A_ R_ E_  ;
SHOW                : S_ H_ O_ W_  ;
SHUTDOWN            : S_ H_ U_ T_ D_ O_ W_ N_  ;
SIGN                : S_ I_ G_ N_  ;
SIGNED            : S_ I_ G_ N_ E_ D_  ;
SIMPLE            : S_ I_ M_ P_ L_ E_  ;
SIN                : S_ I_ N_  ;
SJIS                : S_ J_ I_ S_  ;
SLAVE                : S_ L_ A_ V_ E_  ;
SLEEP                : S_ L_ E_ E_ P_  ;
SMALLINT            : S_ M_ A_ L_ L_ I_ N_ T_  ;
SNAPSHOT            : S_ N_ A_ P_ S_ H_ O_ T_  ;
SOCKET            : S_ O_ C_ K_ E_ T_  ;
SONAME            : S_ O_ N_ A_ M_ E_  ;
SOUNDEX                : S_ O_ U_ N_ D_ E_ X_  ;
SOUNDS            : S_ O_ U_ N_ D_ S_  ;
SOURCE            : S_ O_ U_ R_ C_ E_  ;
SPACE                : S_ P_ A_ C_ E_  ;
SPATIAL            : S_ P_ A_ T_ I_ A_ L_  ;
SPECIFIC            : S_ P_ E_ C_ I_ F_ I_ C_  ;
SQL_BIG_RESULT            : S_ Q_ L_  '_' B_ I_ G_  '_' R_ E_ S_ U_ L_ T_  ;
SQL_BUFFER_RESULT        : S_ Q_ L_  '_' B_ U_ F_ F_ E_ R_  '_' R_ E_ S_ U_ L_ T_  ;
SQL_CACHE            : S_ Q_ L_  '_' C_ A_ C_ H_ E_  ;
SQL_CALC_FOUND_ROWS        : S_ Q_ L_  '_' C_ A_ L_ C_  '_' F_ O_ U_ N_ D_  '_' R_ O_ W_ S_  ;
SQL_NO_CACHE        : S_ Q_ L_  '_' N_ O_  '_' C_ A_ C_ H_ E_  ;
SQL_SMALL_RESULT        : S_ Q_ L_  '_' S_ M_ A_ L_ L_  '_' R_ E_ S_ U_ L_ T_  ;
SQL                : S_ Q_ L_ ;
SQL_THREAD            : S_ Q_ L_  '_' T_ H_ R_ E_ A_ D_  ;
SQLEXCEPTION        : S_ Q_ L_ E_ X_ C_ E_ P_ T_ I_ O_ N_  ;
SQLSTATE            : S_ Q_ L_ S_ T_ A_ T_ E_  ;
SQLWARNING            : S_ Q_ L_ W_ A_ R_ N_ I_ N_ G_  ;
SQRT                : S_ Q_ R_ T_  ;
SSL                : S_ S_ L_  ;
START            : S_ T_ A_ R_ T_  ;
STARTING            : S_ T_ A_ R_ T_ I_ N_ G_  ;
STATS_AUTO_RECALC        : S_ T_ A_ T_ S_ '_' A_ U_ T_ O_ '_' R_ E_ C_ A_ L_ C_  ;
STATS_PERSISTENT        : S_ T_ A_ T_ S_ '_' P_ E_ R_ S_ I_ S_ T_ E_ N_ T_  ;
STARTS            : S_ T_ A_ R_ T_ S_  ;
STATUS            : S_ T_ A_ T_ U_ S_  ;
STD                : S_ T_ D_  ;
STDDEV                : S_ T_ D_ D_ E_ V_  ;
STDDEV_POP            : S_ T_ D_ D_ E_ V_ '_' P_ O_ P_  ;
STDDEV_SAMP            : S_ T_ D_ D_ E_ V_ '_' S_ A_ M_ P_  ;
STOP            : S_ T_ O_ P_  ;
STORAGE            : S_ T_ O_ R_ A_ G_ E_  ;
STR_TO_DATE            : S_ T_ R_ '_' T_ O_ '_' D_ A_ T_ E_  ;
STRAIGHT_JOIN            : S_ T_ R_ A_ I_ G_ H_ T_  '_' J_ O_ I_ N_  ;
STRCMP                : S_ T_ R_ C_ M_ P_;
STRING            : S_ T_ R_ I_ N_ G_  ;
SUBJECT            : S_ U_ B_ J_ E_ C_ T_  ;
SUBPARTITION        : S_ U_ B_ P_ A_ R_ T_ I_ T_ I_ O_ N_  ;
SUBPARTITIONS        : S_ U_ B_ P_ A_ R_ T_ I_ T_ I_ O_ N_ S_  ;
SUBSTRING            : (S_ U_ B_ S_ T_ R_ I_ N_ G_) | (S_ U_ B_ S_ T_ R_) ;
SUBSTRING_INDEX            : S_ U_ B_ S_ T_ R_ I_ N_ G_ '_' I_ N_ D_ E_ X_  ;
SUBTIME                : S_ U_ B_ T_ I_ M_ E_  ;
SUM                : S_ U_ M_  ;
SUPER            : S_ U_ P_ E_ R_  ;
SUSPEND            : S_ U_ S_ P_ E_ N_ D_  ;
SWAPS            : S_ W_ A_ P_ S_  ;
SWE7                : S_ W_ E_ '7'  ;
SWITCHES            : S_ W_ I_ T_ C_ H_ E_ S_  ;
SYSDATE                : S_ Y_ S_ D_ A_ T_ E_  ;
SYSTEM_USER            : S_ Y_ S_ T_ E_ M_ '_' U_ S_ E_ R_  ;
TABLE                : T_ A_ B_ L_ E_ ;
TABLE_CHECKSUM        : T_ A_ B_ L_ E_  '_' C_ H_ E_ C_ K_ S_ U_ M_  ;
TABLES                : T_ A_ B_ L_ E_ S_  ;
TABLESPACE            : T_ A_ B_ L_ E_ S_ P_ A_ C_ E_  ;
TAN                : T_ A_ N_  ;
TEMPORARY            : T_ E_ M_ P_ O_ R_ A_ R_ Y_  ;
TEMPTABLE            : T_ E_ M_ P_ T_ A_ B_ L_ E_  ;
TERMINATED            : T_ E_ R_ M_ I_ N_ A_ T_ E_ D_  ;
TEXT            : T_ E_ X_ T_  ;
THAN            : T_ H_ A_ N_  ;
THEN            : T_ H_ E_ N_  ;
TIME_FORMAT            : T_ I_ M_ E_ '_' F_ O_ R_ M_ A_ T_  ;
TIME            : T_ I_ M_ E_  ;
TIME_TO_SEC            : T_ I_ M_ E_ '_' T_ O_ '_' S_ E_ C_  ;
TIMEDIFF            : T_ I_ M_ E_ D_ I_ F_ F_  ;
TIMESTAMP            : T_ I_ M_ E_ S_ T_ A_ M_ P_  ;
TIMESTAMPADD            : T_ I_ M_ E_ S_ T_ A_ M_ P_ A_ D_ D_  ;
TIMESTAMPDIFF            : T_ I_ M_ E_ S_ T_ A_ M_ P_ D_ I_ F_ F_  ;
TINYBLOB            : T_ I_ N_ Y_ B_ L_ O_ B_  ;
TINYINT                : T_ I_ N_ Y_ I_ N_ T_  ;
TINYTEXT            : T_ I_ N_ Y_ T_ E_ X_ T_  ;
TIS620                : T_ I_ S_ '620'  ;
TO_BASE64            : T_ O_ '_' B_ A_ S_ E_ '64';
TO_DAYS                : T_ O_ '_' D_ A_ Y_ S_  ;
TO_SECONDS            : T_ O_ '_' S_ E_ C_ O_ N_ D_ S_;
TO                : T_ O_  ;
TRAILING            : T_ R_ A_ I_ L_ I_ N_ G_  ;
TRANSACTION            : T_ R_ A_ N_ S_ A_ C_ T_ I_ O_ N_ ;
TRANSACTIONAL        : T_ R_ A_ N_ S_ A_ C_ T_ I_ O_ N_ A_ L_  ;
TRIGGER            : T_ R_ I_ G_ G_ E_ R_  ;
TRIGGERS            : T_ R_ I_ G_ G_ E_ R_ S_  ;
TRIM                : T_ R_ I_ M_  ;
TRUE            : T_ R_ U_ E_ ;
TRUNCATE            : T_ R_ U_ N_ C_ A_ T_ E_  ;
TYPE            : 'TYPE'  ;
TYPES            : T_ Y_ P_ E_ S_  ;
UCS2                : U_ C_ S_ '2';
UJIS                : U_ J_ I_ S_  ;
UNCOMMITTED            : U_ N_ C_ O_ M_ M_ I_ T_ T_ E_ D_  ;
UNCOMPRESS            : U_ N_ C_ O_ M_ P_ R_ E_ S_ S_  ;
UNCOMPRESSED_LENGTH        : U_ N_ C_ O_ M_ P_ R_ E_ S_ S_ E_ D_ '_' L_ E_ N_ G_ T_ H_  ;
UNDEFINED            : U_ N_ D_ E_ F_ I_ N_ E_ D_  ;
UNDO_BUFFER_SIZE        : U_ N_ D_ O_  '_' B_ U_ F_ F_ E_ R_  '_' S_ I_ Z_ E_  ;
UNDO            : U_ N_ D_ O_  ;
UNDOFILE            : U_ N_ D_ O_ F_ I_ L_ E_  ;
UNHEX                : U_ N_ H_ E_ X_  ;
UNICODE            : U_ N_ I_ C_ O_ D_ E_  ;
UNINSTALL            : U_ N_ I_ N_ S_ T_ A_ L_ L_  ;
UNION            : U_ N_ I_ O_ N_  ;
UNIQUE            : U_ N_ I_ Q_ U_ E_  ;
UNIX_TIMESTAMP            : U_ N_ I_ X_ '_' T_ I_ M_ E_ S_ T_ A_ M_ P_  ;
UNKNOWN            : U_ N_ K_ N_ O_ W_ N_  ;
UNLOCK            : U_ N_ L_ O_ C_ K_  ;
UNSIGNED            : U_ N_ S_ I_ G_ N_ E_ D_  ;
UNTIL            : U_ N_ T_ I_ L_  ;
UPDATE                : U_ P_ D_ A_ T_ E_ ;
UPGRADE            : U_ P_ G_ R_ A_ D_ E_  ;
UPPER                : (U_ P_ P_ E_ R_) | (U_ C_ A_ S_ E_)  ;
USAGE                : U_ S_ A_ G_ E_  ;
USE_FRM                : U_ S_ E_  '_' F_ R_ M_  ;
USE                : U_ S_ E_  ;
USER                : 'USER'  ;
USING            : U_ S_ I_ N_ G_     ;
UTC_DATE            : U_ T_ C_ '_' D_ A_ T_ E_  ;
UTC_TIME            : U_ T_ C_ '_' T_ I_ M_ E_  ;
UTC_TIMESTAMP            : U_ T_ C_ '_' T_ I_ M_ E_ S_ T_ A_ M_ P_  ;
UTF16LE                : U_ T_ F_ '16' L_ E_   ;
UTF16                : U_ T_ F_ '16'  ;
UTF32                : U_ T_ F_ '32'  ;
UTF8                : U_ T_ F_ '8'  ;
UUID                : U_ U_ I_ D_  ;
VALUE            : V_ A_ L_ U_ E_  ;
VALUES                : V_ A_ L_ U_ E_ S_  ;
VAR_POP                : V_ A_ R_ '_' P_ O_ P_  ;
VAR_SAMP            : V_ A_ R_ '_' S_ A_ M_ P_  ;
VARBINARY            : V_ A_ R_ B_ I_ N_ A_ R_ Y_  ;
VARCHAR                : V_ A_ R_ C_ H_ A_ R_  ;
VARIABLES            : V_ A_ R_ I_ A_ B_ L_ E_ S_  ;
VARIANCE            : V_ A_ R_ I_ A_ N_ C_ E_  ;
VARYING                : V_ A_ R_ Y_ I_ N_ G_ ;
VERSION            : V_ E_ R_ S_ I_ O_ N_  ;
VIEW            : V_ I_ E_ W_  ;
WAIT            : W_ A_ I_ T_  ;
WARNINGS            : W_ A_ R_ N_ I_ N_ G_ S_  ;
WEEK                : W_ E_ E_ K_  ;
WEEKDAY                : W_ E_ E_ K_ D_ A_ Y_  ;
WEEKOFYEAR            : W_ E_ E_ K_ O_ F_ Y_ E_ A_ R_  ;
WEIGHT_STRING            : W_ E_ I_ G_ H_ T_ '_' S_ T_ R_ I_ N_ G_;
WHEN            : W_ H_ E_ N_     ;
WHERE                : W_ H_ E_ R_ E_  ;
WHILE            : W_ H_ I_ L_ E_ ;
WITH                : W_ I_ T_ H_  ;
WORK            : W_ O_ R_ K_  ;
WRAPPER            : W_ R_ A_ P_ P_ E_ R_  ;
WRITE            : W_ R_ I_ T_ E_  ;
X509            : X_  '509'  ;
XA                : X_ A_  ;
XML                : X_ M_ L_  ;
XOR                : X_ O_ R_  ;
YEAR                : Y_ E_ A_ R_  ;
YEAR_MONTH            : Y_ E_ A_ R_  '_' M_ O_ N_ T_ H_  ;
YEARWEEK            : Y_ E_ A_ R_ W_ E_ E_ K_  ;
ZEROFILL            : Z_ E_ R_ O_ F_ I_ L_ L_  ;

// basic token definition ------------------------------------------------------------

DIVIDE_OP    : (  D_ I_ V_ ) | '/' ;
MOD_OP    : (  M_ O_ D_ ) | '%' ;
OR_OP    : (  O_ R_ ) | '||';
AND_OP    : (  A_ N_ D_ ) | '&&';

ARROW    : '=>' ;
EQ    : '=' | '<=>' ;
NOT_EQ    : '<>' | '!=' | '~='| '^=';
LET    : '<=' ;
GET    : '>=' ;
SET_VAR    : ':=' ;
SHIFT_LEFT    : '<<' ;
SHIFT_RIGHT    : '>>' ;
ALL_FIELDS    : '.*' ;

SEMI    : ';' ;
COLON    : ':' ;
DOT    : '.' ;
COMMA    : ',' ;
ASTERISK: '*' ;
RPAREN    : ')' ;
LPAREN    : '(' ;
RBRACK    : ']' ;
LBRACK    : '[' ;
PLUS_OP   : '+' ;
MINUS_OP  : '-' ;
NEGATION: '~' ;
VERTBAR    : '|' ;
BITAND    : '&' ;
POWER_OP: '^' ;
GTH    : '>' ;
LTH    : '<' ;

SINGLE_QUOTE : '\'' ;
DOUBLE_QUOTE : '\"' ;
BACKSLASH : '\\' ;

INTEGER_NUM: ('0'..'9')+ ;

fragment HEX_DIGIT_FRAGMENT: ( 'a'..'f' | 'A'..'F' | '0'..'9' ) ;
HEX_DIGIT:
    (  '0x'     (HEX_DIGIT_FRAGMENT)+  )
    |
    (  'X' SINGLE_QUOTE (HEX_DIGIT_FRAGMENT)+ SINGLE_QUOTE  ) 
;

BIT_NUM:
    (  '0b'    ('0'|'1')+  )
    |
    (  B_ SINGLE_QUOTE ('0'|'1')+ SINGLE_QUOTE  ) 
;

REAL_NUMBER:
    (  INTEGER_NUM DOT INTEGER_NUM | INTEGER_NUM DOT | DOT INTEGER_NUM | INTEGER_NUM  )
    (  ('E'|'e') ( PLUS_OP | MINUS_OP )? INTEGER_NUM  )? 
;

TEXT_STRING:
    ( N_ | ('_' U_ T_ F_ '8') )?
    (
        (  SINGLE_QUOTE ( (BACKSLASH BACKSLASH) | (SINGLE_QUOTE SINGLE_QUOTE) | (BACKSLASH SINGLE_QUOTE) | ~(SINGLE_QUOTE) )* SINGLE_QUOTE  )
        |
        (  DOUBLE_QUOTE ( (BACKSLASH BACKSLASH) | (DOUBLE_QUOTE DOUBLE_QUOTE) | (BACKSLASH DOUBLE_QUOTE) | ~(DOUBLE_QUOTE) )* DOUBLE_QUOTE  ) 
    )
;

ID:    
    ( 'A'..'Z' | 'a'..'z' | '_' | '$') ( 'A'..'Z' | 'a'..'z' | '_' | '$' | '0'..'9' )*
;

// http://dev.mysql.com/doc/refman/5.6/en/user-variables.html
USER_VAR:
    '@' (USER_VAR_SUBFIX1 | USER_VAR_SUBFIX2 | USER_VAR_SUBFIX3 | USER_VAR_SUBFIX4)
;
fragment USER_VAR_SUBFIX1:    (  '`' (~'`' )+ '`'  ) ;
fragment USER_VAR_SUBFIX2:    ( SINGLE_QUOTE (~SINGLE_QUOTE)+ SINGLE_QUOTE ) ;
fragment USER_VAR_SUBFIX3:    ( DOUBLE_QUOTE (~DOUBLE_QUOTE)+ DOUBLE_QUOTE ) ;
fragment USER_VAR_SUBFIX4:    ( 'A'..'Z' | 'a'..'z' | '_' | '$' | '0'..'9' | DOT )+ ;

SYS_VAR_PREFIX: ('@@' (GLOBAL | SESSION)? DOT );
fragment SYS_VAR_ID:    ID ;


WHITE_SPACE    : ( ' '|'\r'|'\t'|'\n' ) {$channel=HIDDEN;} ;

// http://dev.mysql.com/doc/refman/5.6/en/comments.html
SL_COMMENT    : ( ('--'|'#') ~('\n'|'\r')* '\r'? '\n' ) {$channel=HIDDEN;} ;
ML_COMMENT    : '/*' ( options {greedy=false;} : . )* '*/' {$channel=HIDDEN;} ;
// data type definition -----  http://dev.mysql.com/doc/refman/5.6/en/data-types.html  ---------------
/*integer_types:
    INTEGER | TINYINT | SMALLINT | MEDIUMINT | INT | BIGINT
    ( LPAREN INTEGER_NUM RPAREN )?
    ZEROFILL? UNSIGNED? 
    AUTO_INCREMENT?;
fixed_point_types:
    (DECIMAL | NUMERIC)    // the same
    ( LPAREN INTEGER_NUM ( COMMA INTEGER_NUM )? RPAREN )? ;
floating_point_types:
    (FLOAT | DOUBLE)
    ( LPAREN INTEGER_NUM ( COMMA INTEGER_NUM )? RPAREN )? 
    AUTO_INCREMENT?;
bit_value_type:    
    BIT
    ( LPAREN INTEGER_NUM RPAREN )?;
numeric_types:
    integer_types | fixed_point_types | floating_point_types | bit_value_type;

datetime_length:
    LPAREN tlen=INTEGER_NUM RPAREN {atoi((char*)($tlen.text->chars)) <= 6}?  ;
datetime_types:
      ( DATE )
    | ( TIME (datetime_length)? )
    | ( (DATETIME | TIMESTAMP) (datetime_length)? (DEFAULT CURRENT_TIMESTAMP)? (ON UPDATE CURRENT_TIMESTAMP)? )
    | ( YEAR LPAREN ('2'|'4') RPAREN ) ;


char_varchar_types:
    ( CHAR      LPAREN clen=INTEGER_NUM RPAREN {atoi((char*)($clen.text->chars)) < 256}? )
    |
    ( VARCHAR   LPAREN vlen=INTEGER_NUM RPAREN {atoi((char*)($vlen.text->chars)) < 1024}? ) ;
binary_varbinary_types:
    ( BINARY    LPAREN blen=INTEGER_NUM RPAREN {atoi((char*)($blen.text->chars)) < 256}? )
    |
    ( VARBINARY LPAREN vlen=INTEGER_NUM RPAREN {atoi((char*)($vlen.text->chars)) < 1024}? ) ;
blob_types:
      ( TINYBLOB   LPAREN blen=INTEGER_NUM RPAREN {atoi((char*)($blen.text->chars)) < (1<<8)}?  ) 
    | ( BLOB   LPAREN blen=INTEGER_NUM RPAREN {atoi((char*)($blen.text->chars)) < (1<<16)}? ) 
    | ( MEDIUMBLOB LPAREN blen=INTEGER_NUM RPAREN {atoi((char*)($blen.text->chars)) < (1<<24)}? ) 
    | ( LONGBLOB   LPAREN blen=INTEGER_NUM RPAREN {_atoi64((char*)($blen.text->chars)) < (1LL<<32)}? ) ;    // atoll
text_types:
      ( TINYTEXT   LPAREN tlen=INTEGER_NUM RPAREN {atoi((char*)($tlen.text->chars)) < (1<<8)}?  ) 
    | ( TEXT   LPAREN tlen=INTEGER_NUM RPAREN {atoi((char*)($tlen.text->chars)) < (1<<16)}? ) 
    | ( MEDIUMTEXT LPAREN tlen=INTEGER_NUM RPAREN {atoi((char*)($tlen.text->chars)) < (1<<24)}? ) 
    | ( LONGTEXT   LPAREN tlen=INTEGER_NUM RPAREN {_atoi64((char*)($tlen.text->chars)) < (1LL<<32)}? ) ;    // atoll
enum_types:
    ENUM    LPAREN TEXT_STRING (COMMA TEXT_STRING)* RPAREN;        //0 <= count <= 65535
set_types:
    SET LPAREN TEXT_STRING (COMMA TEXT_STRING)* RPAREN;        //0 <= count <= 64
string_types:
    char_varchar_types
    | binary_varbinary_types
    | blob_types | text_types
    | enum_types | set_types;

datetypes_decl:
    numeric_types | datetime_types | string_types;
*/


// SQL Statement Syntax ----  http://dev.mysql.com/doc/refman/5.6/en/sql-syntax.html ----------
root_statement:
    (SHIFT_LEFT SHIFT_RIGHT)?  
    ( data_manipulation_statements 
	| data_definition_statements 
	| transactional_locking_statements 
	/*| replication_statements*/ 
	| database_admin_statements )
    (SEMI)?
;

data_manipulation_statements:
      select_statement
    | delete_statements
    | insert_statements
    | update_statements

    | call_statement
    | do_statement
    | handler_statements
    | load_data_statement
    | load_xml_statement
    | replace_statement
;

data_definition_statements: 
      create_database_statement
    | alter_database_statements
    | drop_database_statement
    
    | create_event_statement
    | alter_event_statement
    | drop_event_statement
    
    //| create_function_statement
    //| alter_function_statement
    //| drop_function_statement
    
    //| create_procedure_create_function_statement
    //| alter_procedure_statement
    //| drop_procedure_drop_function_statement
    
    //| create_trigger_statement
    //| drop_trigger_statement
    
    | create_server_statement
    | alter_server_statement
    | drop_server_statement
    
    | create_table_statement
    | alter_table_statement
    | drop_table_statement
    
    | create_view_statement
    | alter_view_statement
    | rename_table_statement
    | drop_view_statement
    | truncate_table_statement
    
    | create_index_statement
    | drop_index_statement
;

transactional_locking_statements:
      start_transaction_statement
    | begin_statement
    | commit_statement
    | rollback_statement
    | set_transaction_statement
    | set_autocommit_statement

    | savepoint_statement
    | rollback_to_savepoint_statement
    | release_savepoint_statement

    | lock_table_statement
    | unlock_table_statement

    // | xa_transaction_statement
;

/*
replication_statements:    
      controlling_master_servers_statements
    | controlling_slave_servers_statements
;
*/


database_admin_statements
	:	
      // set statements
      set_charset_statement
    | set_names_statement
    | set_usrvar_statement
    | set_sysvar_statement

      // table maintenance statement
    | analyze_table_statement
    | check_table_statement
    | checksum_table_statement
    | optimize_table_statement
    | repair_table_statement
;
	