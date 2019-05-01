#include <iostream>
#include <algorithm>
#include <map>
#include <string>
#include <vector>
using namespace std;

void yyerror(string s);

bool mp_test(int i){
	cout<<"map map"<<endl;
	cout<<"ls ls"<<endl;
	return true;
}

class symbol
{
public:
    string var_name;
    int var_type;
    bool constant;

};


class SemanticAnalyzer{
public:
    vector<map<string, symbol*> > symbol_table;

    // Printing the table.
    void insertSymbol(string symbol_name, int symbol_type, bool constant, bool new_scope = false){

        // Check if exists before.
        if(new_scope) {
            bool valid = checkValidDeclaration(symbol_name);
            if(valid) {
                symbol* ptr = new symbol;
                ptr->var_name =  symbol_name;
                ptr->var_type = symbol_type;
                ptr->constant = constant;

                map<string, symbol*> mp;

                mp[ptr->var_name] = ptr;
                this->symbol_table.push_back(mp);

            }else{
                string error = "variable: " + symbol_name + " declared before in this scope";
                yyerror(error);
            }

        }else{
            bool valid = checkValidUsage(symbol_name);
            if(!valid){
                string error = "variable: " + symbol_name + " is not declared";
                yyerror(error);
            }
        }

        this->printSymbolTable();

    }

    bool checkValidUsage(string symbol_name){
        if(symbol_table.size() != 0 && (symbol_table[symbol_table.size() - 1]).count(symbol_name))
            return true;
        return false;
    }

    bool checkValidDeclaration(string symbol_name){

        if(symbol_table.size() != 0 && (symbol_table[symbol_table.size() - 1]).count(symbol_name))
            return false;

            return true;
    }
    void printSymbolTable(){
        printf("----------------------SYMBOL TABLE----------------------\n");
        int scope = 0;

        vector<map<string, symbol*> >::iterator it;
        for(it = this->symbol_table.begin(); it != this->symbol_table.end(); it++){
            printf("Scope: %d\n", scope++);

            map<string, symbol*>::iterator mp_it;
            for( auto mp_it = (*it).begin(); mp_it != (*it).end(); mp_it++){
                    dataTypeEnum dt = (dataTypeEnum)mp_it->second->var_type;
                    string data_type;
                    string is_const;
                    if(mp_it->second->constant == 1) {
                        is_const = "constant";
                    }
                    else {
                        is_const = "";
                    }
                    switch(dt){
                        case t_int:
                        data_type = "int";
                        break;
                        case t_float:
                        data_type = "float";
                        break;
                        case t_string:
                        data_type = "string";
                        break;
                    }
                printf("{ Type: %s %s | Name: %s }\n",is_const.c_str(), data_type.c_str(), mp_it->first.c_str());
            }
        }
    }

};
