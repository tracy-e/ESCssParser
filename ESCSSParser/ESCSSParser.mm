//
//  ESCSSParser.m
//  ESCSSParser
//
//  Created by Tracy E on 12-11-12.
//  Copyright (c) 2012年 Tracy E. All rights reserved.
//

#import "ESCSSParser.h"
#include <iostream>

using namespace std;

#pragma mark -- C++ Methods --

enum parse_status   { in_selector,in_property,in_value,in_string,in_comment,in_keyframe};
enum token_type{ AT_START, AT_END, SEL_START, SEL_END, PROPERTY, VALUE, COMMENT };
struct token{ token_type type; string data;};

static string tokens = "{};:()@='\"/,\\!$%&*+.<>?[]^`|~";
static string str_replace(const string find, const string replace, string str);
char s_at(const string &istring, const int pos);
static bool escaped(const string &istring, int pos);
static bool in_str_array(const string& haystack, const char needle);
static bool is_token(string& istring,const int i);
static const string trim(const string istring);
static const string trimspaces(const string istring);
static bool ctype_space(const char c);
static string unicode(string& istring,int& i);
static bool ctype_xdigit(char c);
static bool ctype_digit(const char c);
static double hexdec(string istring);
static const string rtrim(const string istring);
static string char2str(const char c);

static bool ctype_space(const char c)
{
	return (c == ' ' || c == '\t' || c == '\r' || c == '\n' || c == 11);
}

static string char2str(const char c)
{
	string ret = "";
	ret += c;
	return ret;
}

static double hexdec(string istring)
{
	double ret = 0;
	istring = trim(istring);
	for(int i = istring.length()-1; i >= 0; --i)
	{
		int num = 0;
		switch(tolower(istring[i]))
		{
			case 'a': num = 10; break;
			case 'b': num = 11; break;
			case 'c': num = 12; break;
			case 'd': num = 13; break;
			case 'e': num = 14; break;
			case 'f': num = 15; break;
			case '1': num = 1; break;
			case '2': num = 2; break;
			case '3': num = 3; break;
			case '4': num = 4; break;
			case '5': num = 5; break;
			case '6': num = 6; break;
			case '7': num = 7; break;
			case '8': num = 8; break;
			case '9': num = 9; break;
			case '0': num = 0; break;
		}
		ret += num*pow((double) 16, (double) istring.length()-i-1);
	}
	return ret;
}

static bool ctype_digit(const char c)
{
	return (c == '0' || c == '1' || c == '2' || c == '3' || c == '4' || c == '5' || c == '6' || c == '7' || c == '8' || c == '9');
}

static const string rtrim(const string istring)
{
	std::string::size_type last = istring.find_last_not_of(" \n\t\r\0xb"); /// must succeed
	return istring.substr( 0, last + 1);
}

static bool ctype_xdigit(char c)
{
	return (ctype_digit(c) || c == 'a' || c == 'b' || c == 'c' || c == 'd' || c == 'e' || c == 'f');
}

static string unicode(string& istring,int& i)
{
	++i;
	string add = "";
	bool replaced = false;
	
	while(i < istring.length() && (ctype_xdigit(istring[i]) || ctype_space(istring[i])) && add.length()< 6)
	{
		add += istring[i];
        
		if(ctype_space(istring[i]))
		{
			break;
		}
		i++;
	}
    
	if((hexdec(add) > 47 && hexdec(add) < 58) || (hexdec(add) > 64 && hexdec(add) < 91) || (hexdec(add) > 96 && hexdec(add) < 123))
	{
		string msg = "Replaced unicode notation: Changed \\" + rtrim(add) + " to ";
		add = static_cast<int>(hexdec(add));
		msg += add;
		replaced = true;
	}
	else
	{
		add = trim("\\" + add);
	}
    
	if((ctype_xdigit(istring[i+1]) && ctype_space(istring[i]) && !replaced) || !ctype_space(istring[i]))
	{
		i--;
	}
	
	return "";
}

static string str_replace(const string find, const string replace, string str)
{
    int len = find.length();
    int replace_len = replace.length();
    int pos = str.find(find);
    
    while(pos != string::npos)
	{
        str.replace(pos, len, replace);
        pos = str.find(find, pos + replace_len);
    }
    return str;
}

char s_at(const string &istring, const int pos)
{
	if(pos > (istring.length()-1) && pos < 0)
	{
		return 0;
	}
	else
	{
		return istring[pos];
	}
}

static const string trim(const string istring)
{
	std::string::size_type first = istring.find_first_not_of(" \n\t\r\0xb");
	if (first == std::string::npos) {
		return std::string();
	}
	else {
		std::string::size_type last = istring.find_last_not_of(" \n\t\r\0xb");
		return istring.substr( first, last - first + 1);
	}
}

static const string trimspaces(const string istring)
{
	std::string::size_type first = istring.find_first_not_of(" ");
	if (first == std::string::npos) {
		return std::string();
	}
	else {
		std::string::size_type last = istring.find_last_not_of(" ");
		return istring.substr( first, last - first + 1);
	}
}

static bool escaped(const string &istring, const int pos)
{
	return !(s_at(istring,pos-1) != '\\' || escaped(istring,pos-1));
}

static bool in_str_array(const string& haystack, const char needle)
{
	return (haystack.find_first_of(needle,0) != string::npos);
}

static bool is_token(string& istring,const int i){
	return (in_str_array(tokens,istring[i]) && !escaped(istring,i));
}

static NSString* stringForm(string string){
    return [NSString stringWithCString:string.c_str() encoding:NSUTF8StringEncoding];
}


#pragma mark - -- ESCSSParser implementation --
@implementation ESCSSParser

- (NSDictionary *)parse:(NSString *)cssText{
    if (cssText == nil) return nil;
    
    NSMutableDictionary *styleSheet = [[NSMutableDictionary alloc] init];
    NSMutableDictionary *keyframeRule = nil;
    NSMutableDictionary *properties = nil;

    string css_input = [cssText UTF8String];
    css_input = str_replace("\r\n","\n",css_input);
    css_input = str_replace("\n","",css_input);
	css_input += "\n";
	parse_status status = in_selector, from;
	string cur_property = "", cur_selector,cur_string,cur_sub_value,cur_keyframes,cur_comment;
    string temp_add;
    
	char str_char;
	bool str_in_str = false;
	bool invalid_at = false;
	bool pn = false;
    bool in_keyframes = false;
    
	int str_size = css_input.length();
	for(int i = 0; i < str_size; ++i)
	{
		switch(status)
		{
            /* Case in-selector */
			case in_selector:
                if(is_token(css_input,i))
                {
                    if(css_input[i] == '/' && s_at(css_input,i+1) == '*' && trim(cur_selector) == "")
                    {
                        status = in_comment; ++i;
                        from = in_selector;
                    }
                    else if(css_input[i] == '"' || css_input[i] == '\'')
                    {
                        cur_string = css_input[i];
                        status = in_string;
                        str_char = css_input[i];
                        from = in_selector;
                    }
                    else if(invalid_at && css_input[i] == ';')
                    {
                        invalid_at = false;
                        status = in_selector;
                    }
                    else if(css_input[i] == '{')
                    {
                        status = in_property;
                        cur_selector = trim(cur_selector);
                        cur_selector = trimspaces(cur_selector);
                        
                        properties = [[[NSMutableDictionary alloc] init] autorelease];
                    }
                    else if(css_input[i] == '}')
                    {
                        //a keyframes end
                        if (in_keyframes) {
                            in_keyframes = false;
                            cur_keyframes = str_replace("-webkit-", "", cur_keyframes);
                            cur_keyframes = trimspaces(cur_keyframes);
                            
                            [styleSheet setObject:keyframeRule forKey:stringForm(cur_keyframes)];
                            cur_keyframes = "";
                        }
                        cur_selector = "";
                    }
                    else if(css_input[i] == ',')
                    {
                        cur_selector = trim(cur_selector) + ",";
                    }
                    else if(css_input[i] == '\\')
                    {
                        cur_selector += unicode(css_input,i);
                    }
                    else if(css_input[i] == '@'){
                        status = in_keyframe;
                    }
                    else if(!(css_input[i] == '*' && (s_at(css_input,i+1) == '.' || s_at(css_input,i+1) == '[' || s_at(css_input,i+1) == ':' || s_at(css_input,i+1) == '#')))
                    {
                        cur_selector += css_input[i];
                    }
                }
                else
                {
                    int lastpos = cur_selector.length()-1;
                    if(!( (ctype_space(cur_selector[lastpos]) || (is_token(cur_selector,lastpos) && cur_selector[lastpos] == ',')) && ctype_space(css_input[i])))
                    {
                        cur_selector += css_input[i];
                    }
				}
                break;
                
            /* Case in-property */
			case in_property:
                if(is_token(css_input,i))
                {
                    if(css_input[i] == ':' || (css_input[i] == '=' && cur_property != ""))
                    {
                        status = in_value;
                    }
                    else if(css_input[i] == '/' && s_at(css_input,i+1) == '*' && cur_property == "")
                    {
                        status = in_comment; ++i;
                        from = in_property;
                    }
                    else if(css_input[i] == '}')
                    {
                        if (in_keyframes) {
                            [keyframeRule setObject:properties forKey:stringForm(cur_selector)];
                        }else{
                            NSString *selector = stringForm(cur_selector);
                            if ([styleSheet objectForKey:selector]) {
                                NSMutableDictionary *preRule = [styleSheet objectForKey:selector];
                                [preRule addEntriesFromDictionary:properties];
                            }else{
                                [styleSheet setObject:properties forKey:selector];
                            }
                        }
                        
                        status = in_selector;
                        invalid_at = false;
                        cur_selector = "";
                        cur_property = "";
                    }
                    else if(css_input[i] == ';')
                    {
                        cur_property = "";
                    }
                }
                else if(!ctype_space(css_input[i]))
                {
                    cur_property += css_input[i];
                }
                break;
                
            /* Case in-value */
			case in_value:
                pn = ((css_input[i] == '\n' || css_input[i] == '\r')  || i == str_size-1);
                
                if(is_token(css_input,i) || pn)
                {
                    if(css_input[i] == '/' && s_at(css_input,i+1) == '*')
                    {
                        status = in_comment; ++i;
                        from = in_value;
                    }
                    else if(css_input[i] == '"' || css_input[i] == '\'' || css_input[i] == '(')
                    {
                        str_char = (css_input[i] == '(') ? ')' : css_input[i];
                        cur_string = css_input[i];
                        status = in_string;
                        from = in_value;
                    }
                    else if(css_input[i] == '\\')
                    {
                        cur_sub_value += unicode(css_input,i);
                    }
                    else if(css_input[i] == ';' || pn)
                    {
                        status = in_property;
                    }
                    else if(css_input[i] != '}')
                    {
                        cur_sub_value += css_input[i];
                    }
                    if( (css_input[i] == '}' || css_input[i] == ';' || pn) && !cur_selector.empty())
                    {
                        cur_sub_value = trimspaces(cur_sub_value);
                        
                        NSString *propertyName = stringForm(cur_property);
                        NSString *propertyValue = stringForm(cur_sub_value);
                        [properties setValue:propertyValue forKey:propertyName];
                        
                        cur_selector = trim(cur_selector);
                        cur_property = trim(cur_property);
                        cur_sub_value = trim(cur_sub_value);
                        
                        if(cur_sub_value != "")
                        {
                            cur_sub_value = "";
                        }
                        cur_property = "";
                    }
                    if(css_input[i] == '}')
                    {
                        status = in_selector;
                        invalid_at = false;
                        cur_selector = "";
                    }
                }
                else if(!pn)
                {
                    cur_sub_value += css_input[i];
                }
                break;
                
            /* Case in-string */
			case in_string:
                if(str_char == ')' && (css_input[i] == '"' || css_input[i] == '\'') && str_in_str == false && !escaped(css_input,i))
                {
                    str_in_str = true;
                }
                else if(str_char == ')' && (css_input[i] == '"' || css_input[i] == '\'') && str_in_str == true && !escaped(css_input,i))
                {
                    str_in_str = false;
                }
                temp_add = "";
                temp_add += css_input[i];
                if( (css_input[i] == '\n' || css_input[i] == '\r') && !(css_input[i-1] == '\\' && !escaped(css_input,i-1)) )
                {
                    temp_add = "\\A ";
                }
                if (!(str_char == ')' && char2str(css_input[i]).find_first_of(" \n\t\r\0xb") != string::npos && !str_in_str)) {
                    cur_string += temp_add;
                }
                if(css_input[i] == str_char && !escaped(css_input,i) && str_in_str == false)
                {
                    status = from;
                    if (cur_string.find_first_of(" \n\t\r\0xb") == string::npos && cur_property != "content") {
                        if (str_char == '"' || str_char == '\'') {
                            cur_string = cur_string.substr(1, cur_string.length() - 2);
                        }
                        else if (cur_string.length() > 3 && (cur_string[1] == '"' || cur_string[1] == '\'')) /* () */ {
                            cur_string = cur_string[0] + cur_string.substr(2, cur_string.length() - 4) + cur_string[cur_string.length()-1];
                        }
                    }
                    if(from == in_value)
                    {
                        cur_sub_value += cur_string;
                    }
                    else if(from == in_selector)
                    {
                        cur_selector += cur_string;
                    }
                }
                break;
                
            case in_keyframe:
                if (css_input[i] == '{') {
                    status = in_selector;
                    in_keyframes = true;
                    keyframeRule = [[[NSMutableDictionary alloc] init] autorelease];
                    
                }else if(css_input[i] == ';'){
                    status = in_selector;
                    cur_keyframes = "";
                }
                else{
                    cur_keyframes += css_input[i];
                }
                break;
                
            case in_comment:
                if(css_input[i] == '*' && s_at(css_input,i+1) == '/')
                {
                    status = from;
                    ++i;
                    cur_comment = "";
                }
                else
                {
                    cur_comment += css_input[i];
                }
                break;
		}
	}    
    return [styleSheet autorelease];
}



@end
