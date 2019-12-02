#include<bits/stdc++.h>
#include "1405081_symbolinfo.h"
using namespace std;
int r=0,col=0;
ofstream output;
class ScopeTable
{
    int bucket_num;
    int id;     

public:
	SymbolInfo** ara;
    ScopeTable(int n);   
    ~ScopeTable();

    void setid(int n);
    int getid();

    int hash_func(string name);     
    ScopeTable* ParentScope;

    SymbolInfo* Lookup(string nam);
    bool Insert(string nam,string typ);
    bool Delete(string nam);
    void Print();

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
    this->id=n;
}

int ScopeTable::getid()
{
    return id;
}

SymbolInfo* ScopeTable::Lookup(string nam)
{
   
	  int value = hash_func(nam);
      SymbolInfo *temp=ara[value];
      int col=0;
      while(temp!=NULL)
        {
            if(temp->getname()==nam) return temp;
            temp=temp->next;
            col++;
        }
        return NULL;

}

bool ScopeTable::Insert(string nam,string typ)
{

	col=0;
	int value = hash_func(nam);
	SymbolInfo *p=ara[value];
	SymbolInfo *x;
        SymbolInfo *newNode;
        newNode= new SymbolInfo();
       	newNode->setname(nam);
		newNode->settype(typ);
		newNode->next=NULL;
        x=Lookup(nam);
        if(x==NULL)
        {
        ara[value]=newNode;
		r=value;    
		col=0;           

		return true;
		}
        else
        {
            if(x->getname()==nam) return false;
		
		ara[value]=newNode;
		r=value;    
		x->next=newNode;
		newNode->next=NULL;
		return true;
        }

}


bool ScopeTable::Delete(string nam)
{
    r=0;
    col=0;
	int index=hash_func(nam);
	SymbolInfo* ptr= ara[index];
	SymbolInfo *x;
	x=Lookup(nam);
	if(x==NULL) return false;
	else
	{
		if(x->getname()==nam )
		{
			if(x->next==NULL)
			{
				ara[index]=NULL;
				delete x;

				ara[index]=new SymbolInfo;     // :v :p
		    	ara[index]->setname("empty");
		    	ara[index]->settype("empty");
		    	ara[index]->next=NULL;

				return true;
			}
			else
			{
				ara[index]=x->next;
				delete ptr;
				return true;

			}

		}
		else
		{
			SymbolInfo* prev;   
			prev=x;
			ptr=ptr->next;
			col++;
			while(ptr !=NULL)
			{
				if(ptr->getname()==nam)
				{
				    r=index;
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
		cout<<k<<" --> ";
		output<<k<<" --> ";
		ptr=ara[k];
		if(ptr->getname()=="empty")
		{
			cout<<endl;
		    output<<endl;
			continue;
		}
		else
		{
			while(ptr!=NULL)
			{
				cout<<" <"<<ptr->getname()<<" : "<<ptr->gettype()<<">";
				output<<" <"<<ptr->getname()<<" : "<<ptr->gettype()<<">";
				ptr=ptr->next;
			}

		}
		cout<<endl;
		output<<endl;
	}

}

