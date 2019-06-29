package com.coder.contest.misslineous;

/* IMPORTANT: Multiple classes and nested static classes are supported */



import java.io.InputStreamReader;

//import for Scanner and other utility classes
import java.util.*;
import java.lang.*;


// Warning: Printing unwanted or ill-formatted data to output will cause the test cases to fail

public class JavaTest {
    public static void main(String args[] ) throws Exception {



        String str=null;

 str="1 2 3 4 9 8";
        int a=findMaxProfit(6,str);
        System.out.println(a);





    }
    static int findMaxProfit( int l,String s){
        int profit=0;
        int vi=0;
        int vj=0;
         s = s.replaceAll("\\s", "");
         int dv=0;
        for( int i=0;i<l-1;i++){

            String a=Character.toString(s.charAt(i));
            vi = Integer.parseInt(a.trim());
            for(int j=1;j<l;j++) {

                String b = Character.toString(s.charAt(j));
                vj = Integer.parseInt(b.trim());


                if (vi == 1) {
                    profit = profit + vi;
                    break;
                } else if (vi < vj && vj % vi == 0) {
                    profit = profit + vi;
                    break;
                }
            }

        }
        return profit;
    }
}
