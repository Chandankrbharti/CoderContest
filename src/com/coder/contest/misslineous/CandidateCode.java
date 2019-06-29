package com.coder.contest.misslineous;/* Read input from STDIN. Print your output to STDOUT*/

import java.io.*;
import java.util.*;
public class CandidateCode {
    public static void main(String args[] ) throws Exception {

        Scanner input = new Scanner(System.in);
        int numberOfTestcases = input.nextInt();
        for (int k = 0; k < numberOfTestcases; k++) {
            int noofP = input.nextInt();
            String str = input.nextLine();
            String str1=null;
            if(str.equals("")){
                 str1 = input.nextLine();
            }else{
                str1=str;
            }
            String str2 = input.nextLine();


            winorlos(noofP, str2, str1);
        }

    }
    static void winorlos(int n, String players_energy, String villain_strength) {

        String[] strp = players_energy.split(" ");
        String[] strv = villain_strength.split(" ");
        int size = n;
        int[] arrp = new int[size];
        int[] arrv = new int[size];
        for (int i = 0; i < size; i++) {
            arrp[i] = Integer.parseInt(strp[i]);
            arrv[i] = Integer.parseInt(strv[i]);
        }
        Arrays.sort(arrp);
        Arrays.sort(arrv);
        boolean result = true;
        for (int i = 0; i < n; i++) {
            if (arrp[i] > arrv[i]) {
                result = true;
            } else {
                result = false;
            }
        }
        if (result) {
            System.out.println("WIN");
        } else {
            System.out.println("LOSE");
        }
    }
}
