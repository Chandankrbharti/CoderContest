package com.coder.contest;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.io.PrintWriter;


public class TestClass {
    final static int NO_OF_CHARS = 256;
    public static void main(String[] args) throws IOException {
        BufferedReader br = new BufferedReader(new InputStreamReader(System.in));
        PrintWriter wr = new PrintWriter(System.out);
        String S = br.readLine();

        int out_ = SmallestSubString(S);
        wr.println(out_);

        wr.close();
        br.close();
    }

    static int SmallestSubString(String str) {
        int n = str.length();

        int max_distinct = max_distinct_char(str, n);
        int minl = n;   // result

        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {

                String subs = null;
                if(i<j)
                    subs = str.substring(i, j);
                else
                    subs = str.substring(j, i);
                int subs_lenght = subs.length();
                int sub_distinct_char = max_distinct_char(subs, subs_lenght);


                if (subs_lenght < minl && max_distinct == sub_distinct_char) {
                    minl = subs_lenght;
                }
            }
        }
        return minl;


    }


    static int max_distinct_char(String str, int n) {

        int count[] = new int[NO_OF_CHARS];

        for (int i = 0; i < n; i++) {
            count[str.charAt(i)]++;
        }

        int max_distinct = 0;
        for (int i = 0; i < NO_OF_CHARS; i++) {
            if (count[i] != 0) {
                max_distinct++;
            }
        }

        return max_distinct;
    }
}