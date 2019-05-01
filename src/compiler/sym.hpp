#include <iostream>
#include <algorithm>
#include <map>
#include <string>
using namespace std;


bool mp_test(int i){
	cout<<"map map"<<endl;
	cout<<"ls ls"<<endl;
	return true;
}

struct symbol{
	string var_name;
	int var_type;
	bool constant;
	// TODO: Add value if needed.
	struct symbol* next;	
};