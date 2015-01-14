parser grammar Charset;

charset_name:
      ARMSCII8
    | ASCII_SYM
    | BIG5 
    | BINARY
    | CP1250
    | CP1251
    | CP1256
    | CP1257
    | CP850
    | CP852
    | CP866
    | CP932
    | DEC8
    | EUCJPMS
    | EUCKR
    | GB2312
    | GBK
    | GEOSTD8
    | GREEK
    | HEBREW
    | HP8
    | KEYBCS2
    | KOI8R
    | KOI8U
    | LATIN1
    | LATIN2
    | LATIN5
    | LATIN7
    | MACCE
    | MACROMAN
    | SJIS
    | SWE7
    | TIS620
    | UCS2
    | UJIS
    | UTF8
;


transcoding_name:
      LATIN1
    | UTF8
;

collation_names:
    LATIN1_GENERAL_CS | LATIN1_BIN
;

