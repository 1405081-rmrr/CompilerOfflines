#include "1305028_SymbolInfo.h"
#define _SIZE 100
class SymbolTable
{
    SymbolInfo *hashTableHead[_SIZE];
    SymbolInfo *hashTableTail[_SIZE];
    int TABLE_SIZE;
public:
    SymbolTable(int n)
    {
        this->TABLE_SIZE=n;
        for(int i=0; i<TABLE_SIZE; i++)
        {
            hashTableHead[i]=hashTableTail[i]=0;
        }
    }
    int hashFunc(string Name)
    {
        int l= Name.length();
        int sum=0;
        for(int i=0; i<l; i++) sum+=Name[i];
        int x=sum%TABLE_SIZE;
        return x;
    }
    int LookUp(string Name)
    {
        int value = hashFunc(Name);
        SymbolInfo *temp;
        temp = hashTableHead[value];
        int pos = 0;
        while(temp!=0)
        {
            if(temp->Name==Name) return pos;
            temp=temp->next;
            pos++;
        }
        return NULL_VALUE;
    }
	
    void Insert(string Name, string Type)
    {
        int value = hashFunc(Name);
        SymbolInfo *newNode;
        newNode= new SymbolInfo();
        newNode->Name=Name;
        newNode->Type=Type;
        newNode->next=0;
        if(hashTableHead[value]==0)
        {
            hashTableHead[value]= newNode;
            newNode->prev = 0;
            hashTableTail[value]= newNode;
        }
        else
        {
            hashTableTail[value]->next=newNode;
            newNode->prev=hashTableTail[value];
            hashTableTail[value]=newNode;
        }

    }

    int Delete(string Name)
    {
        int check = LookUp(Name);
        if(check == NULL_VALUE) return NULL_VALUE;
        if(check!= NULL_VALUE)
        {
            int value = hashFunc(Name);
            SymbolInfo *temp;
            temp = hashTableHead[value];
            if (check ==0)
            {
                if(hashTableHead[value]==hashTableTail[value])
                {
                    hashTableHead[value]=hashTableTail[value]=0;
                }
                else
                {
                    hashTableHead[value]= hashTableHead[value]->next;
                    hashTableHead[value]->prev=0;
                }
            }
            else
            {
                while(temp->Name!=Name) temp=temp->next;
                if(temp->next==0)
                {
                    temp->prev->next=0;
                    hashTableTail[value]=temp->prev;
                }
                else
                {
                    temp->prev->next=temp->next;
                    temp->next->prev=temp->prev;
                }
            }
            delete temp;
            return SUCCESS_VALUE;

        }
    }
    void printHashTable(FILE *logout)
    {
        SymbolInfo *temp;
        for(int i=0 ; i<TABLE_SIZE ; i++)
        {

            //output<<i<<"->";
            temp = hashTableHead[i];
            if(temp == NULL) continue;
			fprintf(logout,"%d -->");
            while(temp!=0)
            {
                fprintf(logout,"<%s,%s>",(temp->Name).c_str(),(temp->Type).c_str());
                temp=temp->next;
            }
            fprintf(logout,"\n");
           
        }
    }
};


