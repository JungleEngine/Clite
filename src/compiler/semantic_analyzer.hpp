#include <iostream>
#include <algorithm>
#include <map>
#include <string>
#include <vector>
#include "utilities.cpp"


using namespace std;

void yyerror(string s);

bool mp_test(int i){
	cout<<"map map"<<endl;
	return true;
}

class symbol
{
public:
    string name;
    int type;
    bool constant;

};


class SemanticAnalyzer{
public:
    vector<map<string, symbol*> > symbol_table;


    void addScope(){
        map<string, symbol*> mp;
        this->symbol_table.push_back(mp);    }

    void removeScope(){
        this->symbol_table.pop_back();
    }


    void assignmentValidity(string left, nodeType* right){
        // Check if left node exist in this scope.
        bool valid = this->checkValidUsage(left);
        if(!valid){
            string error = "Undefined variable " + left;
            yyerror(error);
        }else{

            // Valid usage.
            // Check valid assignment.
            // Get last assigned type.
            int left_type = 0;
            bool left_is_constant = false;
            this->getLastType(left, left_type, left_is_constant);

            printf("type of left is:%s %s  \n", getTypeNameConstant(left_is_constant).c_str(),
                   getTypeNameFromCode(left_type).c_str());

            if(right->type = typeId) {
                string right_var_name = right->id.var_name;
                bool valid = this->checkValidUsage(right_var_name);
                if(!valid) {
                    string error = "Undefined variable " + right_var_name;
                    yyerror(error);
                }

                int right_type = 0;
                bool right_is_constant = false;
                this->getLastType(right_var_name, right_type, right_is_constant);

                if(left_type == t_int && right_type != t_int     ||
                   left_type == t_float && right_type != t_float ||
                   left_type == t_string && right_type != t_string) {
                
                    string error = "Type mismatch! Expected " + getTypeNameFromCode(left_type) + " type";
                    yyerror(error);
                }

            } else {

                if(left_type == t_int && right->type != typeCon     ||
                   left_type == t_float && right->type != typeFloat ||
                   left_type == t_string && right->type != typeChar) {
                    
                    string error = "Type mismatch! Expected " + getTypeNameFromCode(left_type) + " type";
                    yyerror(error);
                }
            }
        }
    }

    void getLastType(string& name, int& type, bool& is_constant){

        for (int i = this->symbol_table.size() - 1; i >=0; i--){
            // If the symbol was found.
            if(this->symbol_table[i].count(name)){
                type = this->symbol_table[i][name]->type;
                is_constant = this->symbol_table[i][name]->constant;
            return;
            }

        }
    }
    void insertSymbol(string symbol_name, int symbol_type, bool constant){

        // Check if exists before.
            bool valid = checkValidDeclaration(symbol_name);
            if(valid) {
                symbol* ptr = new symbol;
                ptr->name = symbol_name;
                ptr->type = symbol_type;
                ptr->constant = constant;

                if (this->symbol_table.size() == 0) {
                    map < string, symbol * > mp;
                    mp[ptr->name] = ptr;
                    this->symbol_table.push_back(mp);
                }else{
                    this->symbol_table[this->symbol_table.size() - 1][ptr->name] = ptr;
                }
            }else{
                string error = "variable: " + symbol_name + " declared before in this scope";
                yyerror(error);
            }

        this->printSymbolTable();

    }

    bool checkValidUsage(string symbol_name){
        // Valid if defined in any of the above scopes.
        if(symbol_table.size() != 0){
            for (int i = 0; i < this->symbol_table.size(); i++){
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

    // Printing the table.
    void printSymbolTable(){
        printf("----------------------SYMBOL TABLE----------------------\n");


        int scope = 0;

        vector<map<string, symbol*> >::iterator it;
        for(it = this->symbol_table.begin(); it != this->symbol_table.end(); it++){
            printf("--------------------------------------------------------\n");
            printf("Scope: %d\n", scope++);

            map<string, symbol*>::iterator mp_it;
            for( auto mp_it = (*it).begin(); mp_it != (*it).end(); mp_it++){
                    dataTypeEnum dt = (dataTypeEnum)mp_it->second->type;
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
            printf("--------------------------------------------------------\n");

        }
    }

};
