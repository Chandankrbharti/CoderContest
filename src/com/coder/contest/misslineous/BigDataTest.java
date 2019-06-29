package com.coder.contest.misslineous;

public class BigDataTest {
    public static void main (String[] args)
    {
        int arr[] = {-1, 2, -3, 4, 5, 6, -7, 8, 9};
        int n = arr.length;

        System.out.println("Array after rearranging: ");
        printArray(arr,n);
    }
    static void printArray(int arr[], int n)
    {
        for (int i = 0; i < n; i++)
            System.out.print(arr[i] + "   ");
    }
}
