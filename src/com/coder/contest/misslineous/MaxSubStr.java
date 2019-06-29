package com.coder.contest.misslineous;

import java.util.Arrays;

public class MaxSubStr {

    public static void main(String ...strings){

        System.out.println(maxsubStr("banana"));

    }
    public static String lcp(String s, String t) {
        int n = Math.min(s.length(), t.length());
        for (int i = 0; i < n; i++) {
            if (s.charAt(i) != t.charAt(i))
                return s.substring(0, i);
        }
        return s.substring(0, n);
    }

    static   String  maxsubStr(String s){
      // form the N suffixes
      int N  = s.length();
      String[] suffixes = new String[N];
      for (int i = 0; i < N; i++) {
          suffixes[i] = s.substring(i, N);
      }

      // sort them
      Arrays.sort(suffixes);

      // find longest repeated substring by comparing adjacent sorted suffixes
      String lrs = "";
      for (int i = 0; i < N - 1; i++) {
          String x = lcp(suffixes[i], suffixes[i+1]);
          if (x.length() > lrs.length())
              lrs = x;
      }
        return lrs;
    }
}
