#include <iostream>
using namespace std;

int main() {
	int totalChangeAmount;
	int pennies;
	int nickles;
	int dimes;
	int quarters;
	int dollars;

	cin >> totalChangeAmount;

	if (totalChangeAmount <= 0) {
		cout << "No change" << endl;
	}
	else {
		dollars = int(totalChangeAmount / 100);
		totalChangeAmount = totalChangeAmount % 100;

		quarters = int(totalChangeAmount / 25);
		totalChangeAmount = totalChangeAmount % 25;

		dimes = int(totalChangeAmount / 10);
		totalChangeAmount = totalChangeAmount % 10;

		nickles = int(totalChangeAmount / 5);

		pennies = totalChangeAmount % 5;

		if (dollars == 1) {

			cout << dollars << " Dollar" << endl;
		}
		else if (dollars > 1) {
			cout << dollars << " Dollars" << endl;
		}

		if (quarters == 1) {
			cout << quarters << " Quarter" << endl;
		}
		else if (quarters > 1) {
			cout << quarters << " Quarters" << endl;
		}

		if (dimes == 1) {
			cout << dimes << " Dime" << endl;
		}
		else if (dimes > 1) {
			cout << dimes << " Dimes" << endl;
		}

		if (nickles == 1) {
			cout << nickles << " Nickel" << endl;
		}
		else if (nickles > 1) {
			cout << nickles << " Nickels" << endl;
		}

		if (pennies == 1) {
			cout << pennies << " Penny" << endl;
		}
		else if (pennies > 1) {
			cout << pennies << " Pennies" << endl;
		}
	}
	return 0;
}
