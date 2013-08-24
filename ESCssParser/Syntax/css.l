/* http://www.w3.org/TR/css3-syntax/ */

%option case-insensitive

%{
#include "ESCssTokens.h"
void css_parse(const char* buffer) {
    yy_scan_bytes(buffer,strlen(buffer));
    csslex();
    yy_delete_buffer(YY_CURRENT_BUFFER);
}
int csswrap(void){ return 1;}
%}

h                   [0-9a-f]
nonascii            [\200-\377]
unicode             \\{h}{1,6}[ \t\r\n\f]?
escape              {unicode}|\\[ -~\200-\377]
nmstart             [a-z]|{nonascii}|{escape}
nmchar              [a-z0-9-]|{nonascii}|{escape}
string1             \"([\t !#$%&(-~]|\\{nl}|\'|{nonascii}|{escape})*\"
string2             \'([\t !#$%&(-~]|\\{nl}|\"|{nonascii}|{escape})*\'

ident               [-]?{nmstart}{nmchar}*
name                {nmchar}+
num                 [0-9]+|[0-9]*"."[0-9]+
string              {string1}|{string2}
url                 ([!#$%&*-~]|{nonascii}|{escape})*
w                   [ \t\r\n\f]*
nl                  \n|\r\n|\r|\f
range               \?{1,6}|{h}(\?{0,5}|{h}(\?{0,4}|{h}(\?{0,3}|{h}(\?{0,2}|{h}(\??|{h})))))

%%

[ \t\r\n\f]+                        { css_scan(yytext, S); }

\/\*[^*]*\*+([^/][^*]*\*+)*\/       /* ignore comments */

"<!--"                              { css_scan(yytext, CDO); }
"-->"                               { css_scan(yytext, CDC); }
"~="                                { css_scan(yytext, INCLUDES); }
"|="                                { css_scan(yytext, DASHMATCH); }

{string}                            { css_scan(yytext, STRING); }

{ident}                             { css_scan(yytext, IDENT); }

"#"{name}                           { css_scan(yytext, HASH); }

"@import"                           { css_scan(yytext, IMPORT_SYM); }
"@page"                             { css_scan(yytext, PAGE_SYM); }
"@media"                            { css_scan(yytext, MEDIA_SYM); }
"@font-face"                        { css_scan(yytext, FONT_FACE_SYM); }
"@charset"                          { css_scan(yytext, CHARSET_SYM); }
"@namespace"                        { css_scan(yytext, NAMESPACE_SYM); }

"!{w}important"                     { css_scan(yytext, IMPORTANT_SYM); }

{num}em                             { css_scan(yytext, EMS); }
{num}ex                             { css_scan(yytext, EXS); }
{num}px                             { css_scan(yytext, LENGTH); }
{num}cm                             { css_scan(yytext, LENGTH); }
{num}mm                             { css_scan(yytext, LENGTH); }
{num}in                             { css_scan(yytext, LENGTH); }
{num}pt                             { css_scan(yytext, LENGTH); }
{num}pc                             { css_scan(yytext, LENGTH); }
{num}deg                            { css_scan(yytext, ANGLE); }
{num}rad                            { css_scan(yytext, ANGLE); }
{num}grad                           { css_scan(yytext, ANGLE); }
{num}ms                             { css_scan(yytext, TIME); }
{num}s                              { css_scan(yytext, TIME); }
{num}Hz                             { css_scan(yytext, FREQ); }
{num}kHz                            { css_scan(yytext, FREQ); }
{num}{ident}                        { css_scan(yytext, DIMEN); }
{num}%                              { css_scan(yytext, PERCENTAGE); }
{num}                               { css_scan(yytext, NUMBER); }

"url("{w}{string}{w}")"             { css_scan(yytext, URI); }
"url("{w}{url}{w}")"                { css_scan(yytext, URI); }
{ident}"("                          { css_scan(yytext, FUNCTION); }

U\+{range}                          { css_scan(yytext, UNICODERANGE); }
U\+{h}{1,6}-{h}{1,6}                { css_scan(yytext, UNICODERANGE); }

.                                   { css_scan(yytext, UNKNOWN); }

%%
