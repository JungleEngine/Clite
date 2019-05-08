//
// Created by syrix on 5/1/19.
//

#include <iostream>
#include <algorithm>
#include <map>
#include <string>
#include <vector>
#include "clite.h"

using namespace std;


string getTypeNameFromCode(int type_code){
	switch(type_code){
		case t_int:
			return "int";
		case t_float:
			return "float";
		case t_string:
			return "string";
		case t_bool:
			return "boolean";
	}
	return "unkown";
}

string getTypeNameConstant(bool is_constant){
	return is_constant? "constant":"";
}