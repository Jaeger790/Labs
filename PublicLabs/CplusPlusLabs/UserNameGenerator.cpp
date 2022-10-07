#include <iostream>
#include<cctype>
#include <string>
#include <stdio.h>
#include <ctype.h>
using namespace std;

int main() {
	
	string login;
	string first;
	string last;
	string message = "Your login name: ";
	int number;
	

	
	//get input and convert to login name format
	cin >> first >> last >> number;
	number = number % 100;
	login = last;
	login.append(first.substr(0, 1));
	login.append(to_string(number));
	
	//userName conditions
	if (last.length() > 5) {
		login = last.substr(0, 5);
		login.append(first.substr(0, 1));
		login.append(to_string(number));
		
		cout << message << login << endl;
	}
	else {
		cout << message << login << endl;
	}
	
	return 0;
}



