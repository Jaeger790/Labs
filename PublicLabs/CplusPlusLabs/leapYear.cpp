// ConsoleTest.cpp : This file contains the 'main' function. Program execution begins and ends there.
//
#include <iostream>
using namespace std;

int main (){
	int inputYear;
	bool isLeapYear = false;

	cin >> inputYear;

	if (((inputYear % 4 == 0) && (inputYear % 100 != 0)) || (inputYear % 400 == 0)) {
		isLeapYear = true;
	}
	else {
		isLeapYear = false;
	}
	
	
	if (isLeapYear == true) {
		cout << inputYear << " - leap year" << endl;
	}
	else {
		cout << inputYear << " - not a leap year" << endl;
	}



	return 0;
}



// Run program: Ctrl + F5 or Debug > Start Without Debugging menu
// Debug program: F5 or Debug > Start Debugging menu

// Tips for Getting Started: 
//   5. Go to Project > Add New Item to create new code files, or Project > Add Existing Item to add existing code files to the project
//   6. In the future, to open this project again, go to File > Open > Project and select the .sln file
