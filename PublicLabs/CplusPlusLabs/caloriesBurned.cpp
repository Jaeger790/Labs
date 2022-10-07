#include <iostream>
#include <iomanip>
using namespace std;

int main() {

   int age; 
   int weight;
   int heartRate;
   int minutes;
   float Calories;
   
   cin >> age;
   cin >> weight;
   cin >> heartRate;
   cin >> minutes;
   
   
   Calories = ((age * 0.2757) + (weight * 0.03295) + (heartRate * 1.0781) - 75.4991) * minutes / 8.368;

   
   cout << fixed << setprecision(2) << "Calories: " << Calories << " calories" << endl; 
   
   return 0;
}
