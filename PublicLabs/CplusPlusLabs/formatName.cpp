#include <iostream>
#include<cctype>
#include <string>
using namespace std;

int main() {
	string fullName, firstName, middleName, lastName;


	std::getline(std::cin, fullName);
	
	size_t nameSpace = fullName.find(" ");
	
	firstName = fullName.substr(0, nameSpace);

	size_t nameSpace2 = fullName.find(" ", nameSpace +1);
	
	
	
	if ((nameSpace != std::string::npos) && (nameSpace2 != std::string::npos)) {
		
		middleName = fullName.substr(nameSpace +1, nameSpace2 - nameSpace -1);
		lastName = fullName.substr(nameSpace2 + 1, fullName.length() - nameSpace2 - 1);
		
		cout << lastName << ", " << firstName[0] << "." << middleName[0] << "." << endl;
	}
	else {
		
		lastName = fullName.substr(nameSpace + 1);
		cout << lastName << ", " << firstName[0] << "." << endl;
	}
		
	
	return 0;
}

