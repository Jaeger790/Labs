#include <vector>
#include <math.h>
#include <iostream>

int square_sum(const std::vector<int>& numbers)
{
   int sum = 0;
   int sqaure = 0;
   std::vector<int> squaredNumbers(0);

   for (auto i : numbers) {
       sqaure = pow(i, 2);
       squaredNumbers.push_back(sqaure);
       
   }
   for (auto i : squaredNumbers) {
       sum = sum + i;
   }
   std::cout << sum;
   return  sum;
}

int main() {
    square_sum({ 1, 2});
    return 0;
}