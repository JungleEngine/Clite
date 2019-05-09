#include <iostream>
#include <algorithm>
#include <map>
#include <string>
#include <vector>
#include "utilities.cpp"
#include <stdio.h>
#include <stdlib.h>
#include <string>
using namespace std;

void yyerror(string s);


class symbol
{
public:
    string name;
    int type;
    bool constant;

};


class SemanticAnalyzer{
public:
    bool syntaxError = false; //This is set to true whenever a syntax error is found.

    vector<map<string, symbol*> > symbol_table;
    string symbol_table_to_print = "";

    void addScope(){
        this->symbol_table_to_print += " Adding new scope \n";
        printSymbolTable();
        map<string, symbol*> mp;
        this->symbol_table.push_back(mp);
    }

    void removeScope(){
        this->symbol_table.pop_back();
    }


    void operationValidity(oprNodeType & opr){
        dataTypeEnum op_types[2]; //type of each operand that we're trying to evaluate
        nodeType * ops[2]; //contains the left and right operands ( actual operands not just the type)
        
        ops[0] = opr.op[0];
        if(opr.nops ==1){
            ops[1] = opr.op[0];     
        }else if(opr.nops == 2){
            ops[1] = opr.op[1];
        }else{
            cout<<"unexpected number of operands when trying to check for operation validity"<<endl;
            cout<<"are you missing an operation check like check if this is not a while loop or something?"<<endl;
        }
        
        //iterate over two operands and get type of each operand
        for(int i = 0;i<2; i ++){
            if(ops[i]->type == typeOpr){
                op_types[i] = ops[i]->opr.eval;
            }else if(ops[i]->type == typeId){
                bool is_const = false;
                string var_name(ops[i]->id.var_name);
                int type = 0;
                this->getLastType(string(var_name), type, is_const);
                op_types[i] = (dataTypeEnum)type;
                // TODO: watch out from having to deem this variable used before declaration if this is an assigment operation!
                // Check if left node exist in this scope.
                if(this->checkValidUsage(var_name) == false){
                    //TODO: check if we can typecast
                    //TODO: check if we should break or continue parsing
                    return ;
                }
                if(i == 0){
                    //if it's constant then we cannot assign anything to it
                    //if this variable is on the left then we're declaring it
                    //TODO: we can assign if it's the declaration
                    //TODO: we need to allow constant to be assigned a value in the line it's declared only!
                    //      leaving this as it is will cause us to always say that you cannot assign a value
                    //      to a constant variable
                    //      this will give an error if left like this!
                    // if(opr.type == EQDEC){
                    //     if(this->checkValidDeclaration(var_name)){
                    //         cout<<"Redeclaration of variable: " << var_name<<endl;
                    //         return;
                    //     }
                    // }
                    if(is_const && opr.type != EQDEC ){
                        if(opr.type >=EQ && opr.type <= MULEQ){
                            this->syntaxError = true;
                            yyerror("Assigning value to a constant variable!");
                            return ;
                        }
                    }
                }
                op_types[i] = (dataTypeEnum)type;
//                printf("type of %s is:%s %s  \n", i?"right":"left" , getTypeNameConstant(is_const).c_str(),
//            getTypeNameFromCode(op_types[i]).c_str();
            }else if(ops[i]->type == typeCon){
                op_types[i] = t_int;
            }else if(ops[i]->type == typeChar){
                op_types[i] = t_string;
            }else if(ops[i]->type == typeFloat){
                op_types[i] = t_float;
            }else if(ops[i]->type == typeBool){
                op_types[i] = t_bool;
            }
        }

        //find the resulting type depending on the operation
        //TODO: type casting will be done here

        //operation returns bool expression
        if(opr.type >= NOT && opr.type <= NTEQ){
            if (opr.type <= AND) {
                if (op_types[0]==t_string && opr.type != NOT) {
                    this->syntaxError = true;
                    yyerror( "Type of left operand is string!");
                    return;
                }
                if (op_types[1]==t_string) {
                    this->syntaxError = true;
                    yyerror("Type of right operand is string!");
                    return;
                }
                if (op_types[0]==t_int || op_types[0]==t_float) {

                }
                if (op_types[1]==t_int || op_types[1]==t_float) {
                    cout << "Type of right operand is: " << getTypeNameFromCode(op_types[1]);
                    cout << ", casting to bool" << endl;
                }
            }
            else if( (op_types[0]==t_int || op_types[0]==t_float || op_types[0]==t_bool)  
                &&
                (op_types[1]==t_int || op_types[1]==t_float || op_types[1]==t_bool) ){

            }
            opr.eval = t_bool;
        }

        //operation returns numerical expression
        if(opr.type >= UMIN && opr.type <= MUL) {
            if( (op_types[0] != t_float && op_types[0] != t_int)
                ||
                (op_types[1] != t_float && op_types[1] != t_int)) {
                this->syntaxError = true;
                yyerror("Error: Non numerical operand!");
                return;
            }
            else if( op_types[0] == t_float || op_types[1] == t_float) {
                opr.eval = t_float;
            }
            else {
                opr.eval = t_int;
            }
        }

        if(opr.type == EQ || opr.type == EQDEC){
            if(op_types[0] == op_types[1]){
                opr.eval = op_types[0];
                return;
            }
            if(op_types[0]==t_bool && (op_types[1]==t_int)){
                cout<<"type of left operand is: "<<getTypeNameFromCode(op_types[0]) << endl;
                cout<<"type of right operand is: "<<getTypeNameFromCode(op_types[1]) << endl;
                cout<<"casting right operand to bool"<<endl;
                cout<<"resulting expression is: "<<getTypeNameFromCode(op_types[0])<<endl;
                opr.eval = op_types[0];
                return;
            }
        }
        if(opr.type >= EQ && opr.type <= MULEQ) {

            if (op_types[0] == t_string || op_types[1] == t_string) {
                // if(opr.type == EQDEC){
                //     removeSymbol(ops[0]->id.var_name);
                // }
                this->syntaxError =  true;
                yyerror("Non numerical operand!");
                return;
            }
            //if(opr.type>EQDEC){
            if (op_types[0] == t_bool && op_types[1] != t_bool) {
                // if(opr.type == EQDEC){
                //     removeSymbol(ops[0]->id.var_name);
                // }
                this->syntaxError =  true;
                yyerror("in right operand! Expected boolean operand.");
                return;
            }
            //}
            if(op_types[0] == t_float && (op_types[1] == t_float || op_types[1] == t_int)) {

                opr.eval = t_float;
            }
            else {

                opr.eval = t_int;
            }
        }
    }

    void getLastType(string name, int& type, bool& is_constant){

        for (int i = this->symbol_table.size() - 1; i >=0; i--){
            // If the symbol was found.
            if(this->symbol_table[i].count(name)){
                type = this->symbol_table[i][name]->type;
                is_constant = this->symbol_table[i][name]->constant;
            return;
            }

        }
    }

    // dataTypeEnum resolveTypes(nodeType* opr, nodeType* op1, nodeType* op2){
    //     dataTypeEnum op_types[2];
    //     nodeType * ops[2];
    //     ops[0] = op1;
    //     ops[1] = op2; 
    //     for(int i = 0;i<2; i ++){
    //         //get operands types:
    //         if(ops[i]->type == typeOpr){
    //             op_types[i] = ops[i]->opr->eval;
    //         }else if(ops[i]->type == typeId){
    //             op_types[i] = this->getLastType(ops[i]->id.var_name);
    //         }else if(ops[i]->type == typeCon){
    //             op_types[i] = t_int;
    //         }else if(ops[i]->type == typeChar){
    //             op_types[i] = t_string;
    //         }else if(ops[i]->type == typeFloat){
    //             op_types[i] = t_float;
    //         }
    //     }

    //     switch(opr->type){
    //         case 
    //     }



    //     //set opr->eval = ..
    // }
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
                this->syntaxError = true;
                yyerror(error);
            }

        this->printSymbolTable();

    }

    // void removeSymbol(string symbol_name){

    //     symbol_table[symbol_table.size() - 1].erase(symbol_name);

    //     this->printSymbolTable();

    // }

    bool checkValidUsage(string symbol_name){
        // Valid if defined in any of the above scopes.
        if(symbol_table.size() != 0){
            for (int i = 0; i < this->symbol_table.size(); i++){
                if(this->symbol_table[i].count(symbol_name)){
                    return true;
                }
            }
        }
            this->syntaxError = true;
            string error = "Undefined variable " + symbol_name;
            yyerror(error);
            return false;
    }

    bool checkValidDeclaration(string symbol_name){

        if(symbol_table.size() != 0 && (symbol_table[symbol_table.size() - 1]).count(symbol_name)){
            return false;
        }

            return true;
    }

    // Printing the table.
    void printSymbolTable(){
        this->symbol_table_to_print += "----------------------SYMBOL TABLE----------------------\n";

        int scope = 0;

        vector<map<string, symbol*> >::iterator it;
        for(it = this->symbol_table.begin(); it != this->symbol_table.end(); it++){
            this->symbol_table_to_print += "Scope: " + to_string(scope++) + "\n";

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
                        case t_bool:
                        data_type = "bool";
                        break;
                    }
                this->symbol_table_to_print +=
                    "{ Type: " + is_const +" " + data_type + " | Name:" + mp_it->first + "}\n";

            }
            this->symbol_table_to_print +="--------------------------------------------------------\n";

        }
        this->symbol_table_to_print += "----------------------SYMBOL TABLE----------------------\n";
        this->symbol_table_to_print +="----------------------END SYMBOL TABLE-------------------\n";

        cout<<this->symbol_table_to_print;
    }

};
