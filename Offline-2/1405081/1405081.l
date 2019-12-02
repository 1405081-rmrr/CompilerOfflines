%option noyywrap
%x MYSTRING
%x MYSTATE



%{
#include<cstdio>
#include<cstdlib>
#include<string>
#include<vector>

using namespace std;

int line_count=1;
int error_count=0;

FILE *logout;
FILE *tokenout;

int row=0,col=0;
int scope_id_for_lookup=0;

class SymbolInfo
{
    string name;
    string type;
public:
    SymbolInfo();    //constructor

    void setname(string nam);
    void settype(string typ);
    string getname();
    string gettype();

    SymbolInfo* next=NULL;
};

////
SymbolInfo::SymbolInfo() //constructor
{

}

void SymbolInfo::setname(string nam)
{
    name=nam;
}
string SymbolInfo::getname()
{
    return name;
}

void SymbolInfo::settype(string typ)
{
    type=typ;
}
string SymbolInfo::gettype()
{
    return type;
}






class ScopeTable:public SymbolInfo
{
    int bucket_num;
    int id;    

public:
	SymbolInfo** ara;
    ScopeTable(int n);   //constructor
    ~ScopeTable();

    void setid(int n);
    int getid();

    int hash_func(string name);    

    ScopeTable* ParentScope;

    SymbolInfo* Lookup(string nam);
    bool Insert(string nam,string typ);
    bool Delete(string nam);
    void Print();
    
    int no(string typ)
    {
    	int c=0;
    	SymbolInfo* ptr;
    	for(int i=0;i<bucket_num;i++)
    	{
    		ptr=ara[i];
    		for(int j=0;ptr!=NULL;j++)
			{
				if(ptr->gettype()=="empty") break;
				if(ptr->gettype()==typ) c++;
				ptr=ptr->next;
			}
		}
		return c;
	}

};



ScopeTable::ScopeTable(int n)
{
    bucket_num=n;

    ara=new SymbolInfo* [bucket_num];
    int k;
    for(k=0;k<n;k++)
    {
    	ara[k]=new SymbolInfo;
    	ara[k]->setname("empty");
    	ara[k]->settype("empty");
    	ara[k]->next=NULL;

	}
	

}

ScopeTable::~ScopeTable()
{

	delete *ara;

}


int ScopeTable::hash_func(string name)
{
    int k,sum=0,index;
    for(k=0;k<name.length();k++)
    {
        sum=sum+int(name[k]);
    }
    index=sum%bucket_num;
    return index;
}

void ScopeTable::setid(int n)
{
    id=n;
}

int ScopeTable::getid()
{
    return id;
}




SymbolInfo* ScopeTable::Lookup(string nam)
{
    col=0;
	int index=hash_func(nam);

	SymbolInfo* ptr= ara[index];
	if(ara[index]->getname()=="empty")
	{
		return NULL;
	}
	else
	{
		if(ptr->getname()==nam)
        {
            row=index;      
			col=0;          
			return ptr;
        }

		while(ptr->next!= NULL)
		{
			ptr=ptr->next;
			if(ptr->getname()==nam)
            {
                row=index;  
                col++;      
                return ptr;  
            }

		}
		return NULL;

	}

}

bool ScopeTable::Insert(string nam,string typ)
{
    col=0;
	int index=hash_func(nam);
	SymbolInfo* ptr= ara[index];

	if(ara[index]->getname()=="empty")
	{
		ara[index]->setname(nam);
		ara[index]->settype(typ);
		row=index;    //
		col=0;           //

		return true;
	}
	else
	{
		if(ptr->getname()==nam) return false;

		while(ptr->next!= NULL)
		{
		    col++;    //
			ptr=ptr->next;
			if(ptr->getname()==nam) return false;

		}
		SymbolInfo* n=new SymbolInfo;     
		n->setname(nam);
		n->settype(typ);
		n->next=NULL;
		ptr->next=n;
		col++;
		return true;

	}

}


bool ScopeTable::Delete(string nam)
{
    row=0;
    col=0;
	int index=hash_func(nam);
	SymbolInfo* ptr= ara[index];

	if(ara[index]->getname()=="empty")
	{
		return false;
	}
	else
	{
		if(ptr->getname()==nam )
		{
			if(ptr->next==NULL)
			{
				ara[index]=NULL;
				delete ptr;

				ara[index]=new SymbolInfo;    
		    	ara[index]->setname("empty");
		    	ara[index]->settype("empty");
		    	ara[index]->next=NULL;

				return true;
			}
			else
			{
				ara[index]=ptr->next;
				delete ptr;
				return true;

			}

		}
		else
		{
			SymbolInfo* prev;   
			prev=ptr;
			ptr=ptr->next;
			col++;
			while(ptr !=NULL)
			{
				if(ptr->getname()==nam)
				{
				    row=index;
					prev->next=ptr->next;
					delete ptr;
					return true;
				}
				else
				{
					ptr=ptr->next;
					prev=prev->next;
				}

			}
			return false;

		}

	}

}



void ScopeTable::Print()
{
	int k;
	SymbolInfo* ptr;
	for(k=0;k<bucket_num;k++)
	{
		
		ptr=ara[k];
		if(ptr->getname()=="empty")
		{
			continue;
		}
		else
		{
			fprintf(logout,"%d -->",k);
			while(ptr!=NULL)
			{
				fprintf(logout,"<%s,%s>",ptr->getname().c_str(),ptr->gettype().c_str()); 
	
				ptr=ptr->next;
			}

		}
		fprintf(logout,"\n");
	}

}





int cnt=1;
class SymbolTable
{
public:

	int buc_num;
	ScopeTable* curr;

    ScopeTable* ptr;
	SymbolTable(int n)
	{
		buc_num=n;
		ptr=new ScopeTable(n);
		curr=ptr;
		curr->ParentScope=NULL;
		curr->setid(1);
	}
	~SymbolTable()
	{
	     free(ptr);
	}
	void enter_scope();
	void exit_scope();
	bool Insert(string nam,string typ);
	bool Remove(string nam);   
	SymbolInfo* Look_up(string nam);
	void print_curr_scope_table();
	void print_all_scope_table();

	int no(string typ)
	{
		ScopeTable* ptr;
		int retnum=0;
		ptr=curr;
		while(ptr!=NULL)
		{
			retnum=retnum+ ptr->no(typ);
			ptr=ptr->ParentScope;
		}
		return retnum;
	}


};

/////


void SymbolTable::enter_scope()
{
	ScopeTable* ptr=new ScopeTable(buc_num);
	ptr->ParentScope=curr;
	curr=ptr;
	cnt++;
	curr->setid(cnt);

}

void SymbolTable::exit_scope()
{
	ScopeTable* temp=curr;
	curr=curr->ParentScope;
	cnt--;
	//temp->~ScopeTable();
}

bool SymbolTable::Insert(string nam,string typ)
{
	return curr->Insert(nam,typ);

}

bool SymbolTable::Remove(string nam)
{
	return curr->Delete(nam);

}

SymbolInfo* SymbolTable::Look_up(string nam)
{
	ScopeTable* myptr;
	myptr=curr;
	while(myptr!= NULL)
	{
		if(myptr->Lookup(nam)!=NULL)
		{
		    scope_id_for_lookup=myptr->getid();
			return myptr->Lookup(nam);
		}
		myptr=myptr->ParentScope;
	}
	return NULL;

}

void SymbolTable::print_curr_scope_table()
{
	fprintf(logout,"ScopeTable # <%d> \n",curr->getid());
	
	curr->Print();
	fprintf(logout,"\n");

}

void SymbolTable::print_all_scope_table()
{
	ScopeTable* myptr;
	myptr=curr;
	while(myptr!=NULL)
	{
		fprintf(logout,"ScopeTable # <%d> \n",curr->getid());
		//cout<<"ScopeTable # "<<myptr->getid()<<endl;
		myptr->Print();
		//cout<<endl<<endl;
		fprintf(logout,"\n\n");
		myptr=myptr->ParentScope;
	}

}



SymbolTable st(5);

%}

WHITESPACE[ \t\v\f\r]+

NEWLINE [\n]



CHAR [ -~]{-}[']
CHARS {CHAR}+

CHARACTER ('{CHAR}')

SPECIAL_CHAR ['\n''\t''\\'\a''\f''\r''\b''\v''\0']


DIGIT [0-9]
DIGITS {DIGIT}+
DECP {\.}*


INTEGER {DIGITS}
FLOATING_POINT {DIGITS}*(\.{DIGITS})(E[+-]?{DIGITS})?



IDENTIFIER ([A-Za-z_]([A-Za-z0-9_]*)?)
NOT_IDENTIFIER [0-9]+[A-Za-z0-9_]+

SINGLE_LINE_COMMENT "//"[^\n]*

DECIMAL_POINT_ERROR [0-9]*[.][0-9]*([.]+[0-9]*)*
ILL_FORMATTED_NUMBER  [0-9]*((E[+-]?[0-9]+)([.][0-9]+)*)(E[+-]?[0-9]+)?([.][0-9]+)*
ILL_FORMATTED_CHAR '[A-Za-z0-9][A-Za-z0-9]+'
UNDETERMINED_CHAR '[A-Za-z0-9]*

UNFINISHED_STRING \"([^\"\n]|(\\{NEWLINE}))*








%%


{WHITESPACE}    {}
{NEWLINE}  	{line_count++;}

{INTEGER} 	{
				fprintf(tokenout,"<CONST_INT,%s>",yytext);
				fprintf(logout,"Line no %d: TOKEN <CONST_INT> Lexeme %s found\n\n",line_count,yytext);
				st.Insert(string(yytext),"CONST_INT");

				st.print_curr_scope_table();

		}

{FLOATING_POINT} {

		fprintf(tokenout,"<CONST_FLOAT,%s>",yytext);
		fprintf(logout,"Line no %d: TOKEN <CONST_FLOAT> Lexeme %s found\n\n",line_count,yytext);
		//SymbolInfo *si=new SymbolInfo(string(yytext),"CONST_FLOAT");
		st.Insert(string(yytext),"CONST_FLOAT");
		st.print_curr_scope_table();	
}


{CHARACTER} {
		fprintf(tokenout,"<CONST_CHAR,%s>",yytext);
		fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n\n",line_count,yytext);
		//SymbolInfo *si=new SymbolInfo(string(yytext),"CONST_CHAR");
		st.Insert(string(yytext),"CONST_CHAR");
		st.print_curr_scope_table();
}

{SPECIAL_CHAR} { 
		fprintf(tokenout,"<CONST_CHAR,%s>",yytext);
		fprintf(logout,"Line no %d: TOKEN <CONST_CHAR> Lexeme %s found\n\n",line_count,yytext);
		//SymbolInfo *si=new SymbolInfo(string(yytext),"CONST_CHAR");
		st.Insert(string(yytext),"CONST_CHAR");
		st.print_curr_scope_table();
}




"if" 	   {
		fprintf(tokenout,"<IF>");
		fprintf(logout,"Line no %d: TOKEN <IF> Lexeme if found\n\n",line_count);
}


"for" 	   {
		fprintf(tokenout,"<FOR>");
		fprintf(logout,"Line no %d: TOKEN <FOR> Lexeme for found\n\n",line_count);
}
"do"	   {
		fprintf(tokenout,"<DO>");
		fprintf(logout,"Line no %d: TOKEN <DO> Lexeme do found\n\n",line_count);
}
"int" 	   {
		fprintf(tokenout,"<INT>");
		fprintf(logout,"Line no %d: TOKEN <INT> Lexeme int found\n\n",line_count);
}
"float"    {
		fprintf(tokenout,"<FLOAT>");
		fprintf(logout,"Line no %d: TOKEN <FLOAT> Lexeme float found\n\n",line_count);
}
"void"     {
		fprintf(tokenout,"<VOID>");
		fprintf(logout,"Line no %d: TOKEN <VOID> Lexeme void found\n\n",line_count);
}
"switch"   {
		fprintf(tokenout,"<SWITCH>");
		fprintf(logout,"Line no %d: TOKEN <SWITCH> Lexeme switch found\n\n",line_count);
}
"default"  {
		fprintf(tokenout,"<DEFAULT>");
		fprintf(logout,"Line no %d: TOKEN <DEFAULT> Lexeme default found\n\n",line_count);
}
"else"     {
		fprintf(tokenout,"<ELSE>");
		fprintf(logout,"Line no %d: TOKEN <ELSE> Lexeme else found\n\n",line_count);
}
"while"    {
		fprintf(tokenout,"<WHILE>");
		fprintf(logout,"Line no %d: TOKEN <WHILE> Lexeme while found\n\n",line_count);
}
"break"    {
		fprintf(tokenout,"<BREAK>");
		fprintf(logout,"Line no %d: TOKEN <BREAK> Lexeme break found\n\n",line_count);
}
"char"     {
		fprintf(tokenout,"<CHAR>");
		fprintf(logout,"Line no %d: TOKEN <CHAR> Lexeme char found\n\n",line_count);
}
"double"   {
		fprintf(tokenout,"<DOUBLE>");
		fprintf(logout,"Line no %d: TOKEN <DOUBLE> Lexeme double found\n\n",line_count);
}
"return"   {
		fprintf(tokenout,"<RETURN>");
		fprintf(logout,"Line no %d: TOKEN <RETURN> Lexeme return found\n\n",line_count);
}
"case"     { 
		fprintf(tokenout,"<CASE>");
		fprintf(logout,"Line no %d: TOKEN <CASE> Lexeme case found\n\n",line_count);
}
"continue" { 
		fprintf(tokenout,"<CONTINUE>");
		fprintf(logout,"Line no %d: TOKEN <CONTINUE> Lexeme continue found\n\n",line_count);
}


[+-]		{
			fprintf(tokenout,"<ADDOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <ADDOP> Lexeme %s found\n\n",line_count,yytext);
			
}

[*/%]		{
			fprintf(tokenout,"<MULOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <MULOP> Lexeme %s found\n\n",line_count,yytext);
			
                }

"++"|"--"	{
			fprintf(tokenout,"<INCOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <INCOP> Lexeme %s found\n\n",line_count,yytext);
		}

">"	                       {
			fprintf(tokenout,"<RELOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RELOP> Lexeme %s found\n\n",line_count,yytext);
			
			}

">="                                   {
			fprintf(tokenout,"<RELOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RELOP> Lexeme %s found\n\n",line_count,yytext);
			
			}
		            {
"<"			fprintf(tokenout,"<RELOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RELOP> Lexeme %s found\n\n",line_count,yytext);
			
			}
"<="			{
			fprintf(tokenout,"<RELOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RELOP> Lexeme %s found\n\n",line_count,yytext);
			
			}
"=="			{
			fprintf(tokenout,"<RELOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RELOP> Lexeme %s found\n\n",line_count,yytext);
			
			}
"!="			{
			fprintf(tokenout,"<RELOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RELOP> Lexeme %s found\n\n",line_count,yytext);
			
			}
			
"="		{
			fprintf(tokenout,"<ASSIGNOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <ASSIGNOP> Lexeme %s found\n\n",line_count,yytext);
			
			}

"&&"		            {
			fprintf(tokenout,"<LOGICOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LOGICOP> Lexeme %s found\n\n",line_count,yytext);
			
			}
"||"			{
			fprintf(tokenout,"<LOGICOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LOGICOP> Lexeme %s found\n\n",line_count,yytext);
			
			}
"!"			{
			fprintf(tokenout,"<LOGICOP,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LOGICOP> Lexeme %s found\n\n",line_count,yytext);
			
			}
"("		{
			fprintf(tokenout,"<LPAREN,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LPAREN> Lexeme %s found\n\n",line_count,yytext);
			
			}
")"		{
			fprintf(tokenout,"<RPAREN,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RPAREN> Lexeme %s found\n\n",line_count,yytext);
			
			}
"{"		{
			fprintf(tokenout,"<LCURL,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LCURL> Lexeme %s found\n\n",line_count,yytext);
			
			}
"}"		{
			fprintf(tokenout,"<RCURL,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RCURL> Lexeme %s found\n\n",line_count,yytext);
			
			}
"["		{
			fprintf(tokenout,"<LTHIRD,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <LTHIRD> Lexeme %s found\n\n",line_count,yytext);
			
			}
"]"		{
			fprintf(tokenout,"<RTHIRD,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <RTHIRD> Lexeme %s found\n\n",line_count,yytext);
			
			}
","		{
			fprintf(tokenout,"<COMMA,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <COMMA> Lexeme %s found\n\n",line_count,yytext);
			
			}
";"		{
			fprintf(tokenout,"<SEMICOLON,%s>",yytext);
			fprintf(logout,"Line no %d: TOKEN <SEMICOLON> Lexeme %s found\n\n",line_count,yytext);
			}



{IDENTIFIER} { 
		fprintf(tokenout,"<ID,%s>",yytext);
		fprintf(logout,"Line no %d: TOKEN <ID> Lexeme %s found\n\n",line_count,yytext);
	
		st.Insert(string(yytext),"ID");
		st.print_curr_scope_table();

}




<MYSTRING>{NEWLINE}     {
			line_count++;			
			fprintf(logout,"%s",yytext);
			}
\"      { 
			BEGIN (MYSTRING);
			fprintf(tokenout,"<STRING>,%s",yytext);
			fprintf(logout,"Line no %d: TOKEN <STRING> Lexeme %s ",line_count,yytext);
			
		}

<MYSTRING>\"    {
			fprintf(tokenout,"\">");			
			fprintf(logout,"%s found\n\n",yytext);
			BEGIN INITIAL;
			
			}


<MYSTRING>([\.])*     {
			fprintf(logout,"%s",yytext);
			}




{SINGLE_LINE_COMMENT} { 
			
			fprintf(logout,"Line no %d: TOKEN <COMMENT> Lexeme %s found\n\n",line_count,yytext);
}
		

{DECIMAL_POINT_ERROR} {
			fprintf(logout,"Error at line no %d: Too many decimal point %s\n\n",line_count,yytext);
			error_count++;
			}
{ILL_FORMATTED_NUMBER} {
			fprintf(logout,"Error at line no %d: Ill formatted number %s\n\n",line_count,yytext);
			error_count++;
			}
{NOT_IDENTIFIER}  {
			fprintf(logout,"Error at line no %d: Invalid prefix on ID or invalid suffix on Number %s\n\n",line_count,yytext);
			error_count++;
		}
{ILL_FORMATTED_CHAR} {
			fprintf(logout,"Error at line no %d: Ill formatted character %s\n\n",line_count,yytext);
			error_count++;
			}
{UNDETERMINED_CHAR} {
			fprintf(logout,"Error at line no %d: Undetermined character %s\n\n",line_count,yytext);
			error_count++;
			}
{UNFINISHED_STRING} {
			fprintf(logout,"Error at line no %d: Unfinished string %s\n\n",line_count,yytext);
			error_count++;
			}


%%

int main(int argc,char *argv[]){

	FILE *fin=fopen(argv[1],"r");
	if(fin==NULL){
		printf("Cannot open specified file\n");
		return 0;
	}
	
	logout= fopen("1405081_log.txt","w");
	tokenout= fopen("1405081_token.txt","w");
	yyin= fin;
	yylex();
	
	fclose(yyin);
	fclose(tokenout);
	fclose(logout);
	return 0;
}






