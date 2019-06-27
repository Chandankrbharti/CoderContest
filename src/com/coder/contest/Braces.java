package com.coder.contest;

import java.io.*;
import java.math.*;
import java.security.*;
import java.text.*;
import java.util.*;
import java.util.concurrent.*;
import java.util.regex.*;

public class Braces {



    // Complete the braces function below.
    static String[] braces(String[] values) {
        String s[]=new String[values.length];

        for(int i=0;i<values.length;i++){
            String str=values[i];

            s[i]=   abc(str);


        }
        return s;
    }

    static String abc(String expr){
        if (expr.isEmpty())
            return "YES";
        Stack<Character> stack = new Stack<Character>();
        for (int i = 0; i < expr.length(); i++)
        {
            char current = expr.charAt(i);
            if (current == '{' || current == '(' || current == '[')
            {
                stack.push(current);
            }
            if (current == '}' || current == ')' || current == ']')
            {
                if (stack.isEmpty())
                    return "NO";
                char last = stack.peek();
                if (current == '}' && last == '{' || current == ')' && last == '(' || current == ']' && last == '[')
                    stack.pop();
                else
                    return "NO";
            }
        }
        return stack.isEmpty()?"YES":"NO";
    }

    private static final Scanner scanner = new Scanner(System.in);
    public static void main(String[] args) throws IOException {
//        BufferedWriter bufferedWriter = new BufferedWriter(new FileWriter(System.getenv("OUTPUT_PATH")));

        int valuesCount = scanner.nextInt();
      //  scanner.skip("(\r\n|[\n\r\u2028\u2029\u0085])?");

        String[] values = new String[valuesCount];

        for (int i = 0; i < valuesCount; i++) {
            String valuesItem = scanner.nextLine();
            values[i] = valuesItem;
        }

        String[] res = braces(values);

        for (int i = 0; i < res.length; i++) {
           System.out.println(res[i]);


        }


        scanner.close();
    }
}
/*
2
{}[]()
{[}]}
           System.out.println(res[i]);

                   if (i != res.length - 1) {
                   bufferedWriter.write("\n");
                   }
                   }

                   bufferedWriter.newLine();

                   bufferedWriter.close();
*/