#include <iostream>
#include <iomanip>
using namespace std;

int main() {
   double dollars;
   int quarters;
   int dimes;
   int nickels;
   int pennies;
   
   cin >> quarters;
   cin >> dimes;
   cin >> nickels;
   cin >> pennies;
   
   float quarterValue = quarters * .25;
   float dimeValue = dimes * .10;
   float nickelValue = nickels *.05;
   float pennyValue = pennies * .01;
   dollars = quarterValue + dimeValue + nickelValue + pennyValue;
   
   cout << fixed << setprecision(2)<< "Amount: $" << dollars << endl;  
   
   return 0;
}