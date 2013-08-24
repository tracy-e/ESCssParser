/* http://www.w3.org/TR/css3-syntax/ */

%%

stylesheet
  : [ CHARSET_SYM S* STRING S* ';' ]?
    [S|CDO|CDC]* [ import [S|CDO|CDC]* ]*
    [ namespace [S|CDO|CDC]* ]*
    [ [ ruleset | media | page | font_face ] [S|CDO|CDC]* ]*
  ;
import
  : IMPORT_SYM S*
    [STRING|URI] S* [ medium [ ',' S* medium]* ]? ';' S*
  ;
namespace
  : NAMESPACE_SYM S* [namespace_prefix S*]? [STRING|URI] S* ';' S*
  ;
namespace_prefix
  : IDENT
  ;
media
  : MEDIA_SYM S* medium [ ',' S* medium ]* '{' S* ruleset* '}' S*
  ;
medium
  : IDENT S*
  ;
page
  : PAGE_SYM S* IDENT? pseudo_page? S*
    '{' S* declaration [ ';' S* declaration ]* '}' S*
  ;
pseudo_page
  : ':' IDENT
  ;
font_face
  : FONT_FACE_SYM S*
    '{' S* declaration [ ';' S* declaration ]* '}' S*
  ;
operator
  : '/' S* | ',' S* | /* empty */
  ;
combinator
  : '+' S* | '>' S* | /* empty */
  ;
unary_operator
  : '-' | '+'
  ;
property
  : IDENT S*
  ;
ruleset
  : selector [ ',' S* selector ]*
    '{' S* declaration [ ';' S* declaration ]* '}' S*
  ;
selector
  : simple_selector [ combinator simple_selector ]*
  ;
simple_selector
  : element_name? [ HASH | class | attrib | pseudo ]* S*
  ;
class
  : '.' IDENT
  ;
element_name
  : IDENT | '*'
  ;
attrib
  : '[' S* IDENT S* [ [ '=' | INCLUDES | DASHMATCH ] S*
    [ IDENT | STRING ] S* ]? ']'
  ;
pseudo
  : ':' [ IDENT | FUNCTION S* IDENT S* ')' ]
  ;
declaration
  : property ':' S* expr prio?
  | /* empty */
  ;
prio
  : IMPORTANT_SYM S*
  ;
expr
  : term [ operator term ]*
  ;
term
  : unary_operator?
    [ NUMBER S* | PERCENTAGE S* | LENGTH S* | EMS S* | EXS S* | ANGLE S* |
      TIME S* | FREQ S* | function ]
  | STRING S* | IDENT S* | URI S* | UNICODERANGE S* | hexcolor
  ;
function
  : FUNCTION S* expr ')' S*
  ;
/*
 * There is a constraint on the color that it must
 * have either 3 or 6 hex-digits (i.e., [0-9a-fA-F])
 * after the "#"; e.g., "#000" is OK, but "#abcd" is not.
 */
hexcolor
  : HASH S*
  ;
  
%%