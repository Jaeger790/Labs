#include <iostream>
using namespace std;

int main() {
   int highwayNumber;
   int serviceHighway;
   string prefix = "I-";
   string serving = " serving ";
   string primeAux;
   string direction;
   
     cin >> highwayNumber;
     serviceHighway = highwayNumber % 100;

//check if highway number is primary and n/s e/w 

     //even numbered primary highway
     if ((highwayNumber <= 99) && (highwayNumber > 0) && (highwayNumber % 2 == 0)){
          primeAux = " is primary,";
          direction = " going east/west.";
          cout << prefix << highwayNumber << primeAux << direction << endl;
     }
     //odd numbered primary highway
     else if ((highwayNumber <= 99) && (highwayNumber > 0)){
          primeAux = " is primary,";
          direction = " going north/south.";
          cout << prefix << highwayNumber << primeAux << direction << endl;
     }
     //even numbered auxiliary highway
     else if((highwayNumber > 99) && (highwayNumber < 1000) && (highwayNumber % 100 != 0)  && (highwayNumber % 2 == 0)){
          primeAux = " is auxiliary,";
          direction = " going east/west.";
          cout << prefix << highwayNumber << primeAux << serving << prefix << serviceHighway <<","<< direction << endl;
     }
     //odd numbered auxiliary highway
     else if((highwayNumber > 99) && (highwayNumber < 1000) && (highwayNumber % 100 != 0)){
          primeAux = " is auxiliary,";
          direction = " going north/south.";
          cout << prefix << highwayNumber << primeAux << serving << prefix << serviceHighway <<","<< direction << endl;
     }
     //not valid
     else{
         cout << highwayNumber << " is not a valid interstate highway number." << endl;
     }

     return 0;
}
