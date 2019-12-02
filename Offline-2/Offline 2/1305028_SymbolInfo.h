#include<bits/stdc++.h>

using namespace std;
#define NULL_VALUE -99999
#define SUCCESS_VALUE 99999

class SymbolInfo
{
public:
    string Name;
    string Type;
    SymbolInfo *next;
    SymbolInfo *prev;
};
