#include<bits/stdc++.h>
#include "1405081_scopetable.h"
using namespace std;

ifstream input;
//ofstream output;

//int r=0,col=0;
int scope_id_for_lookup=0;
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


};

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
	curr=curr->ParentScope;
	cnt--;
	
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
	cout<<"ScopeTable # "<<curr->getid()<<endl;
	curr->Print();
	cout<<endl;

}

void SymbolTable::print_all_scope_table()
{
	ScopeTable* myptr;
	myptr=curr;
	while(myptr!=NULL)
	{
		cout<<"ScopeTable # "<<myptr->getid()<<endl;
		myptr->Print();
		cout<<endl<<endl;
		myptr=myptr->ParentScope;
	}

}


////////////////////


int main()
{
    input.open("input.txt");
	output.open("output.txt");
    int n;
    input>>n;
    SymbolTable* k=new SymbolTable(n);

    char c;
    string a,b;
    int del_id;
    while(input >> c)
    {
    	if(c=='I')
    	{
    		input >>a>>b;
    		cout<<c<<" "<<a<<" "<<b<<endl;
    		output<<c<<" "<<a<<" "<<b<<endl;
        if(k->Insert(a,b)==true )
        {
            cout<<" Inserted in ScopeTable# "<<k->curr->getid()<<" at position "<<r<<","<<col<<endl<<endl;
            output<<" Inserted in ScopeTable# "<<k->curr->getid()<<" at position "<<r<<","<<col<<endl<<endl;
        }
        else
        {
           cout<<"<"<<a<<","<<b<<"> already exits in current ScopeTable. "<<endl<<endl;
           output<<"<"<<a<<","<<b<<"> already exits in current ScopeTable. "<<endl<<endl;
        }
    		
		}
		else if(c=='L')
		{
			input>>a;
        cout<<c<<" "<<a<<endl;
         output<<c<<" "<<a<<endl;
        if(k->Look_up(a)==NULL) {
		cout<<" Not found"<<endl<<endl;
		output<<" Not found"<<endl<<endl;
	}
        else {
		cout<<" Found in ScopeTable #"<<scope_id_for_lookup<<" at position "<<r<<","<<col<<endl<<endl;
        output<<" Found in ScopeTable #"<<scope_id_for_lookup<<" at position "<<r<<","<<col<<endl<<endl;
    }
			
		}
		else if(c=='D')
		{
			input>>a;
        cout<<c<<" "<<a<<endl;
        output<<c<<" "<<a<<endl;
        if(k->Remove(a)==true)
        {
            cout<<" Found in ScopeTable#"<<k->curr->getid()<<" at position "<<r<<","<<col<<endl;
            cout<<"Deleted entry at "<<r<<","<<col<<" from current ScopeTable"<<endl<<endl;
            output<<" Found in ScopeTable#"<<k->curr->getid()<<" at position "<<r<<","<<col<<endl;
            output<<"Deleted entry at "<<r<<","<<col<<" from current ScopeTable"<<endl<<endl;
        }
        else {
		cout<<"Not found" <<endl<<a<<" not founnd"<<endl<<endl;
        output<<"Not found" <<endl<<a<<" not founnd"<<endl<<endl;
    }
		}
		else if(c=='S')
		{
			cout<<"S"<<endl;
			output<<"S"<<endl;
        k->enter_scope();
        cout<<"New ScopeTable with id "<<k->curr->getid()<<" created"<<endl<<endl;
        output<<"New ScopeTable with id "<<k->curr->getid()<<" created"<<endl<<endl;
		}
		else if(c=='E')
		{
		cout<<"E"<<endl;
		output<<"E"<<endl;
        del_id=k->curr->getid();
        k->exit_scope();
        cout<<"ScopeTable with id "<<del_id<<" removed"<<endl<<endl;
		output<<"ScopeTable with id "<<del_id<<" removed"<<endl<<endl;	
		}
		else if(c=='P')
		{
			 char scope;
        input>>scope;
        if(scope=='A')
        {
            cout<<"P  A"<<endl;
            output<<"P  A"<<endl;
            k->print_all_scope_table();
        }
        else{
            cout<<"P C"<<endl;
            output<<"P C"<<endl;
            k->print_curr_scope_table();
        }
		}
	}
	free(k);
    return 0;
}
