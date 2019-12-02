%option noyywrap

%{
#include "1305028_SymbolTable.h"
#define COMMENT_SIZE 100
#define STR_SIZE 1000


int line_count=1;
int error_count = 0;
char comment_buffer[COMMENT_SIZE];
char string_buffer[STR_SIZE];
char *string_buffer_ptr;
char *comment_buffer_ptr;
int line_counter_2;

FILE* logout;

SymbolTable *Sym_table;

FILE* tokenout;


%}


%x STRING
%x COMMENT

WHITESPACE [ \t\f\r\v]+ 
LETTER [a-zA-Z]
LETTER_[a-zA-Z_]
VARLET[a-zA-Z0-9_]
DIGIT [0-9]
DIGITS {DIGIT}+
DIGITS_INT -?{DIGIT}+
SINGLE_CHAR [^\\]
MULTI_CHAR_ERROR  '[^\\'\n][^\\'\n]+'
INVALID_SUFFIX {DIGITS}{LETTER_}{VARLET}*
SINGLE_COMMENT "//".*
NEWLINE \n
SINGLE_CHAR_ILL  [^\\'\n]
MULTI_comment [/][*][^*]*[*]+([^*/][^*]*[*]+)*[/]
TOO_MANY_DECIMAL_POINTS_ERROR -?(".")+("E"[+-]?{DIGITS})?|-?{DIGITS}((".")+)("E"[+-]?{DIGITS})?|-?{DIGITS}?"."+{DIGITS}("."+{DIGITS}?)*("E"[+-]?{DIGITS})?
FLOAT -?{DIGITS}?("."{DIGITS})?("E"[+-]?{DIGITS})?
ILL_FORMAT -?{DIGITS}?("."{DIGITS})?"E"[+-]?{TOO_MANY_DECIMAL_POINTS_ERROR}|-?{DIGITS}?("."{DIGITS})?"E"[+-]?{DIGITS}?("."{DIGITS})
ILL_SYMBOL -?(".")+|-?{DIGITS}((".")+)|-?{DIGITS}?"."+{DIGITS}("."+{DIGITS}?)*
TOTAL_ILL {ILL_SYMBOL}"E"[+-]?{TOO_MANY_DECIMAL_POINTS_ERROR}|{DIGITS}?("."{DIGITS})?"E"[+-]?{DIGITS}?("."{DIGITS})
MULOP "*"|"/"|"%"
INCOP "++"|"--"
RELOP "=="|"!="|">="|"<="|"<"|">"
LOGICOP "&&"|"||"|"!"
CONST_CHAR '{SINGLE_CHAR}'|'\\n'|'\\t|'\\\\'|'\\\“'|'\\a'|'\\f'|'\\r'|'\\b'|'\\v'|'\\0' 
CHAR_WITHOUT_QUOT  [^\\'\n]
UNFINISHED_CHAR '{CHAR_WITHOUT_QUOT}*$
STRING_START [\"]
STRING_FORWARD [^\\\n\"]+

%%

{NEWLINE} {line_count++;}

{STRING_START}      {
		string_buffer_ptr = string_buffer;
		*string_buffer_ptr++='"';
		line_counter_2=line_count;
		BEGIN(STRING);
	}
     
<STRING>{STRING_START}       { 
                 BEGIN(INITIAL);
		*string_buffer_ptr++='"';
                 *string_buffer_ptr = '\0';

                fprintf(tokenout,"<STRING,%s>",string_buffer);
		fprintf(logout,"\nLine No. %d: ",line_counter_2);
		fprintf(logout,"Token <STRING> Lexeme %s found\n",string_buffer);
		
                 }
<STRING>\\n  *string_buffer_ptr++ = '\n';
<STRING>\\t  *string_buffer_ptr++ = '\t';
<STRING>\\r  *string_buffer_ptr++ = '\r';
<STRING>\\b  *string_buffer_ptr++ = '\b';
<STRING>\\f  *string_buffer_ptr++ = '\f';  
     
<STRING>{NEWLINE}       {
		BEGIN(INITIAL);
		*string_buffer_ptr = '\0';
		fprintf(logout,"\nError at line %d: ",line_counter_2);
                fprintf(logout,"Unterminated String %s found\n",string_buffer);
		error_count++;
                 }
<STRING>\\(.|\n)  {/**string_buffer_ptr++ = yytext[1];*/line_count++;}
     
<STRING>{STRING_FORWARD}       {
                 char *str_pointer = yytext;
     
                 while ( *str_pointer ){
                         if(*str_pointer!='\t'&&*str_pointer!='\v'&&*str_pointer!='\f'&&*str_pointer!='\r')*string_buffer_ptr++ = *str_pointer++;
else *str_pointer++;}
                 }





"/*"         {
		line_counter_2=line_count;
		comment_buffer_ptr =comment_buffer;
		*comment_buffer_ptr++='/';
		*comment_buffer_ptr++='*';
		BEGIN(COMMENT);
}
     
<COMMENT>[^*\n]*        {
                 char *comment_pointer = yytext;
     
                 while ( *comment_pointer )
                         *comment_buffer_ptr++ = *comment_pointer++;
                 }
<COMMENT>"*"+[^*/\n]*   {
                 char *comment_pointer = yytext;
     
                 while ( *comment_pointer )
                         *comment_buffer_ptr++ = *comment_pointer++;
                 }
<COMMENT>\n             {line_count++;*comment_buffer_ptr++='\n';}
<COMMENT>"*"+"/"        {BEGIN(INITIAL);
		char *comment_pointer = yytext;
     
                 while ( *comment_pointer )
                         *comment_buffer_ptr++ = *comment_pointer++;
		*comment_buffer_ptr='\0';
		fprintf(logout,"Line No %d: Token <COMMENT> Lexeme %s found\n",line_counter_2,comment_buffer);
}
<COMMENT><<EOF>>    {
		BEGIN(INITIAL);
		*comment_buffer_ptr = '\0';
                fprintf(logout,"Error at line %d: Unterminated comment %s found\n",line_counter_2,comment_buffer);
		error_count++;
}



{WHITESPACE} {}

{SINGLE_COMMENT} {
			fprintf(tokenout,"<SINGLE_LINE_COMMENT>");
			fprintf(logout,"Line no %d: TOKEN <SINGLE_LINE_COMMENT> Lexeme %s found\n",line_count,yytext);
		}


"if"	{
			fprintf(tokenout,"<IF>");
			fprintf(logout,"Line no %d: TOKEN <IF> Lexeme %s found\n",line_count,yytext);
		}
		
"else"	{
			fprintf(tokenout,"<ELSE>");
			fprintf(logout,"Line no %d: TOKEN <ELSE> Lexeme %s found\n",line_count,yytext);
		}

"for"	{
			fprintf(tokenout,"<FOR>");
			fprintf(logout,"Line no %d: TOKEN <FOR> Lexeme %s found\n",line_count,yytext);
		}
"while"	{
			fprintf(tokenout,"<WHILE>");
			fprintf(logout,"Line no %d: TOKEN <WHILE> Lexeme %s found\n",line_count,yytext);
		}

"do"	{
			fprintf(tokenout,"<DO>");
			fprintf(logout,"Line no %d: TOKEN <DO> Lexeme %s found\n",line_count,yytext);
		}
"break"	{
			fprintf(tokenout,"<BREAK>");
			fprintf(logout,"Line no %d: TOKEN <BREAK> Lexeme %s found\n",line_count,yytext);
		}
{INVALID_SUFFIX} { error_count++;
			fprintf(logout,"Error at line %d:Invalid suffix %s\n",line_count,yytext);
		}

"int"	{
			fprintf(tokenout,"<INT>");
			fprintf(logout,"Line no %d: TOKEN <INT> Lexeme %s found\n",line_count,yytext);
		}
"char"	{
			fprintf(tokenout,"<CAHR>");
			fprintf(logout,"Line no %d: TOKEN <CHAR> Lexeme %s found\n",line_count,yytext);
		}
"float"	{
			fprintf(tokenout,"<FLOAT>");
			fprintf(logout,"Line no %d: TOKEN <FLOAT> Lexeme %s found\n",line_count,yytext);
		}
"double"	{
			fprintf(tokenout,"<DOUBLE>");
			fprintf(logout,"Line no %d: TOKEN <DOUBLE> Lexeme %s found\n",line_count,yytext);
		}

"void"	{
			fprintf(tokenout,"<VOID>");
			fprintf(logout,"Line no %d: TOKEN <VOID> Lexeme %s found\n",line_count,yytext);
		}
"return"	{
			fprintf(tokenout,"<RETURN>");
			fprintf(logout,"Line no %d: TOKEN <RETURN> Lexeme %s found\n",line_count,yytext);
		}
"switch"	{
			fprintf(tokenout,"<SWITCH>");
			fprintf(logout,"Line no %d: TOKEN <SWITCH> Lexeme %s found\n",line_count,yytext);
		}
"case"	{
			fprintf(tokenout,"<CASE>");
			fprintf(logout,"Line no %d: TOKEN <CASE> Lexeme %s found\n",line_count,yytext);
		}

"default"	{
			fprintf(tokenout,"<DEFAULT>");
			fprintf(logout,"Line no %d: TOKEN <DEFAULT> Lexeme %s found\n",line_count,yytext);
		}
"continue"	{
			fprintf(tokenout,"<CONTINUE>");
			fprintf(logout,"Line no %d: TOKEN <CONTINUE> Lexeme %s found\n",line_count,yytext);
		}

"+"		|

"-"		{
			fprintf(tokenout,"<ADDOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <ADDOP> Lexeme %s found\n",line_count,yytext);
		if(Sym_table->LookUp(yytext)<0)
			{ 
				Sym_table->Insert(yytext,"ADDOP"); 
				Sym_table->printHashTable(logout);
			}
			else
				fprintf(logout,"already exist\n");
		
		}

{MULOP} {
			fprintf(tokenout,"<MULOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <MULOP> Lexeme %s found\n",line_count,yytext);
			if(Sym_table->LookUp(yytext)<0)
			{ 
				Sym_table->Insert(yytext,"MULOP"); 
				Sym_table->printHashTable(logout);
			}
			else
				fprintf(logout,"already exist\n");
		
	}

{INCOP}
	{
			fprintf(tokenout,"<INCOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <INCOP> Lexeme %s found\n",line_count,yytext);
			if(Sym_table->LookUp(yytext)<0)
			{ 
				Sym_table->Insert(yytext,"INCOP"); 
				Sym_table->printHashTable(logout);
			}
			else
				fprintf(logout,"already exist\n");
		
	}

{RELOP} {
			fprintf(tokenout,"<RELOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RELOP> Lexeme %s found\n",line_count,yytext);
			if(Sym_table->LookUp(yytext)<0)
			{ 
				Sym_table->Insert(yytext,"RELOP"); 
				Sym_table->printHashTable(logout);
			}
			else
				fprintf(logout,"already exist\n");
		
	}


"=" {
			fprintf(tokenout,"<ASSIGNOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <ASSIGNOP> Lexeme %s found\n",line_count,yytext);
			if(Sym_table->LookUp(yytext)<0)
			{ 
				Sym_table->Insert(yytext,"ASSIGNOP"); 
				Sym_table->printHashTable(logout);
			}
			else
				fprintf(logout,"already exist\n");
		
	}

{LOGICOP} {
			fprintf(tokenout,"<LOGICOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LOGICOP> Lexeme %s found\n",line_count,yytext);
			if(Sym_table->LookUp(yytext)<0)
			{ 
				Sym_table->Insert(yytext,"LOGICOP"); 
				Sym_table->printHashTable(logout);
			}
			else
				fprintf(logout,"already exist\n");
		
	}

"(" {
			fprintf(tokenout,"<LPAREN,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LPAREN> Lexeme %s found\n",line_count,yytext);
			if(Sym_table->LookUp(yytext)<0)
			{ 
				Sym_table->Insert(yytext,"LPAREN"); 
				Sym_table->printHashTable(logout);
			}
			else
				fprintf(logout,"already exist\n");
		
	}

")" {
			fprintf(tokenout,"<RPAREN,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RPAREN> Lexeme %s found\n",line_count,yytext);
			if(Sym_table->LookUp(yytext)<0)
			{ 
				Sym_table->Insert(yytext,"RPAREN"); 
				Sym_table->printHashTable(logout);
			}
			else
				fprintf(logout,"already exist\n");
		
	}


"{" {
			fprintf(tokenout,"<LCURL,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LCURL> Lexeme %s found\n",line_count,yytext);
			if(Sym_table->LookUp(yytext)<0)
			{ 
				Sym_table->Insert(yytext,"LCURL"); 
				Sym_table->printHashTable(logout);
			}
			else
				fprintf(logout,"already exist\n");
		
	}
"}" {
			fprintf(tokenout,"<RCURL,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RCURL> Lexeme %s found\n",line_count,yytext);
			if(Sym_table->LookUp(yytext)<0)
			{ 
				Sym_table->Insert(yytext,"RCURL"); 
				Sym_table->printHashTable(logout);
			}
			else
				fprintf(logout,"already exist\n");
	}


"[" {
			fprintf(tokenout,"<LBRACKET,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LBRACKET> Lexeme %s found\n",line_count,yytext);
			if(Sym_table->LookUp(yytext)<0)
			{ 
				Sym_table->Insert(yytext,"LBRACKET"); 
				Sym_table->printHashTable(logout);
			}
			else
				fprintf(logout,"already exist\n");
		
	}

"]" {
			fprintf(tokenout,"<RBRACKET,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RBRACKET> Lexeme %s found\n",line_count,yytext);
			if(Sym_table->LookUp(yytext)<0)
			{ 
				Sym_table->Insert(yytext,"RBRACKET"); 
				Sym_table->printHashTable(logout);
			}
			else
				fprintf(logout,"already exist\n");
		
	}


"," {
			fprintf(tokenout,"<COMMA,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <COMMA> Lexeme %s found\n",line_count,yytext);
			if(Sym_table->LookUp(yytext)<0)
			{ 
				Sym_table->Insert(yytext,"COMMA"); 
				Sym_table->printHashTable(logout);
			}
			else
				fprintf(logout,"already exist\n");
	}
";" {
			fprintf(tokenout,"<SEMICOLON,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <SEMICOLON> Lexeme %s found\n",line_count,yytext);
			if(Sym_table->LookUp(yytext)<0)
			{ 
				Sym_table->Insert(yytext,"SEMICOLON"); 
				Sym_table->printHashTable(logout);
			}
			else
				fprintf(logout,"already exist\n");
	}
		
{DIGITS_INT} 	{
				fprintf(tokenout,"<CONST_INT,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_INT> Lexeme %s found\n",line_count,yytext);
			if(Sym_table->LookUp(yytext)<0)
			{ 
				Sym_table->Insert(yytext,"CONST_INT"); 
				
				Sym_table->printHashTable(logout);
			}
			else
				fprintf(logout,"already exist\n");
		
                 
     

				
			}
		
{FLOAT}			{
				fprintf(tokenout,"<CONST_FLOAT,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_FLOAT> Lexeme %s found\n",line_count,yytext);
			if(Sym_table->LookUp(yytext)<0)
			{ 
				Sym_table->Insert(yytext,"CONST_FLOAT"); 
				
				Sym_table->printHashTable(logout);
			}
			else
				fprintf(logout,"already exist\n");
		
            
			}



{TOO_MANY_DECIMAL_POINTS_ERROR} { error_count++;
			fprintf(logout,"Error at line %d:Too many decimal point %s\n",line_count,yytext);
		}

{ILL_FORMAT} {error_count++;
			fprintf(logout,"Error at line %d: Ill formed number %s\n",line_count,yytext);
		}

{TOTAL_ILL} {error_count++;
			fprintf(logout,"Error at line %d: Ill formed number %s\n",line_count,yytext);
		}


{LETTER_}{VARLET}* {
					fprintf(tokenout,"<ID,%s>",yytext);
					fprintf(logout,"Line no %d: TOKEN <ID,%s> Lexeme %s  found\n",line_count,yytext,yytext);
			if(Sym_table->LookUp(yytext)<0)
			{ 
				Sym_table->Insert(yytext,"ID"); 
				
				Sym_table->printHashTable(logout);
			}
			else
				fprintf(logout,"already exist\n");
		
            
					
}

{CONST_CHAR}      {
				fprintf(tokenout,"<CONST_CHAR,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_CHAR,%s> Lexeme %s  found\n",line_count,yytext,yytext);
				if(Sym_table->LookUp(yytext)<0)
			{ 
				Sym_table->Insert(yytext,"CONST_CHAR"); 
				
				Sym_table->printHashTable(logout);
			}
			else
				fprintf(logout,"already exist\n");
		
            
			}


{UNFINISHED_CHAR} {error_count++;
				fprintf(logout,"Error at line %d: unterminated character %s\n",line_count,yytext);
				
}

{MULTI_CHAR_ERROR} {error_count++;
				fprintf(logout,"Error at line %d: Ill formed character %s\n",line_count,yytext);
				
}



%%

int main(int argc,char *argv[]){
	
	if(argc!=2){
		printf("Please provide input file name and try again\n");
		return 0;
	}
	Sym_table = new SymbolTable(31);
	
	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout= fopen("1305028_log.txt","w");
	tokenout= fopen("1305028_token.txt","w");

	yyin= fin;
	yylex();
	fprintf(logout,"Total Lines : %d\nTotal Errors : %d",line_count,error_count);
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}
