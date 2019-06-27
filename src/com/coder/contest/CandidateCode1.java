package com.coder.contest;


import java.util.HashSet;
import java.util.Scanner;
import java.util.Set;

public class CandidateCode1 {
        public static void main(String args[]) throws Exception {

            Scanner input = new Scanner(System.in);
            int n = input.nextInt();
            int[] arr = new int[n];
            for (int k = 0; k < n; k++) {
                int v = input.nextInt();
                arr[k] = v;
            }

            printRepeating(arr, n);
        }
            static void printRepeating(int arr[], int size) {
                Set<Integer> store = new HashSet<>();
                int count = 0;
            for (Integer name : arr) {
                    if (store.add(name) == false)
                { count++; }
            }


             System.out.println(count);
        }
    }
