#include <iostream>
#include <vector>   // Must include vector library to use vectors
using namespace std;

int main() {
    vector<int> userInts; // A vector to hold the user's input integers
    int i;
    int inputInts;

    cin >> inputInts;
    userInts.resize(inputInts);


    for (i = 0; i < userInts.size(); i++) {
        cin >> userInts.at(i);
    }

    for (i = 0; i < userInts.size(); i++) {
        cout << userInts.at(i);
    }

    return 0;
}
