#include <iostream>
#include <algorithm>
#include <map>
#include <string>
#include <vector>
#include "utilities.cpp"


using namespace std;

void yyerror(string s);

bool mp_test(int i){
	// cout<<"map map"<<endl;
	map<int,string> mp;
	mp[i]= "w";
	return mp[i]=="w";
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
    vector<map<string, symbol*>> symbol_table;

    void assignmentValidity(string left, nodeType* right){
        // Check if left node exist in this scope.
        bool valid = this->checkValidUsage(left);
        if(!valid){
            string error = "variable: " + left + " used before declaration before in this scope";
            yyerror(error);
        }else{
            // Valid usage.
            // Check valid assignment.
            // Get last assigned type.
            int left_type = 0;
            bool is_constant = false;
            this->getLastType(left, left_type, is_constant);


            typedef enum { typeCon, typeChar, typeFloat, typeId, typeOpr } nodeEnum;

            int right_type = right->type;

            printf("type of left is:%s %s  \n", getTypeNameConstant(is_constant).c_str(),
                   getTypeNameFromCode(left_type).c_str());

        }
    }

    void getLastType(string& var_name, int& type, bool& is_constant){

        for (int i = this->symbol_table.size() - 1; i >=0; i--){
            // If the symbol was found.
            if(this->symbol_table[i].count(var_name)){
                type = this->symbol_table[i][var_name]->var_type;
                is_constant = this->symbol_table[i][var_name]->constant;
            return;
            }

        }
    }
    // Printing the table.
    void insertSymbol(string symbol_name, int symbol_type, bool constant){

        // Check if exists before.
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

//        }else{
//            bool valid = checkValidUsage(symbol_name);
//            if(!valid){
//                string error = "variable: " + symbol_name + " is not declared";
//                yyerror(error);
//            }
//        }

        this->printSymbolTable();

    }

    bool checkValidUsage(string symbol_name){
        // Valid if defined in any of the above scopes.
        if(symbol_table.size() != 0){
            for (int i = 0; i < this->symbol_table.size(); i ++){
                if(this->symbol_table[i].count(symbol_name)){
                    return true;
                }
            }
        }
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
