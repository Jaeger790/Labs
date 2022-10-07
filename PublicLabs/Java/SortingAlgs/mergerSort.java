import java.util.Arrays;

public class MergeSortDemo {
   private static void merge(int[] numbers, int i, int j, int k) {
      int mergedSize = k - i + 1;                // Size of merged partition
      int[] mergedNumbers = new int[mergedSize]; // Dynamically allocates temporary
                                                 // array for merged numbers
      int mergePos = 0;                          // Position to insert merged number
      int leftPos = i;                           // Initialize left partition position
      int rightPos = j + 1;                      // Initialize right partition position
      
      // Add smallest element from left or right partition to merged numbers
      while (leftPos <= j && rightPos <= k) {
         if (numbers[leftPos] <= numbers[rightPos]) {
            mergedNumbers[mergePos] = numbers[leftPos];
            leftPos++;
         }
         else {
            mergedNumbers[mergePos] = numbers[rightPos];
            rightPos++;
         }
         mergePos++;
      }
      
      // If left partition is not empty, add remaining elements to merged numbers
      while (leftPos <= j) {
         mergedNumbers[mergePos] = numbers[leftPos];
         leftPos++;
         mergePos++;
      }
   
      // If right partition is not empty, add remaining elements to merged numbers
      while (rightPos <= k) {
         mergedNumbers[mergePos] = numbers[rightPos];
         rightPos++;
         mergePos++;
      }
   
      // Copy merged numbers back to numbers
      for (mergePos = 0; mergePos < mergedSize; mergePos++) {
         numbers[i + mergePos] = mergedNumbers[mergePos];
      }
   }
   
   private static void mergeSort(int[] numbers, int i, int k) {
      int j = 0;
      
      if (i < k) {
         j = (i + k) / 2;  // Find the midpoint in the partition

         // Recursively sort left and right partitions
         mergeSort(numbers, i, j);
         mergeSort(numbers, j + 1, k);
            
         // Merge left and right partition in sorted order
         merge(numbers, i, j, k);
      }
   }

   public static void main(String[] args) {
      // Create an array of numbers to sort
      int[] numbers = { 61, 76, 19, 4, 94, 32, 27, 83, 58 };
      
      // Display the contents of the array
      System.out.println("UNSORTED: " + Arrays.toString(numbers));
      
      // Call the mergeSort method
      mergeSort(numbers, 0, numbers.length - 1);
      
      // Display the sorted contents of the array
      System.out.println("SORTED:   " + Arrays.toString(numbers));
   }
}