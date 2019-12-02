#include<bits/stdc++.h>
using namespace std;
//int r=0,col=0;
class SymbolInfo
{
    string name;
    string type;
public:
    SymbolInfo();    

    void setname(string nam);
    void settype(string typ);
    string getname();
    string gettype();

    SymbolInfo* next=NULL;
};


SymbolInfo::SymbolInfo() 
{

}

void SymbolInfo::setname(string nam)
{
   this-> name=nam;
}
string SymbolInfo::getname()
{
    return name;
}

void SymbolInfo::settype(string typ)
{
    this->type=typ;
}
string SymbolInfo::gettype()
{
    return type;
}
