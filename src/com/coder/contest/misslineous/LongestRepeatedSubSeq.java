package com.coder.contest.misslineous;

import static java.lang.Math.max;

public class LongestRepeatedSubSeq {

    static String longestRepeatedSubSeq(String str)
    {
        // THIS PART OF CODE IS SAME AS BELOW POST.
        // IT FILLS dp[][]
        // https://www.geeksforgeeks.org/longest-repeating-subsequence/
        // OR the code mentioned above.
        int n = str.length();
        int dp[][]=new int[n+1][n+1];
        for (int i=0; i<=n; i++)
            for (int j=0; j<=n; j++)
                dp[i][j] = 0;
        for (int i=1; i<=n; i++)
            for (int j=1; j<=n; j++)
                if (str.charAt(i-1) == str.charAt(j-1) && i != j)
                    dp[i][j] =  1 + dp[i-1][j-1];
                else
                    dp[i][j] = max(dp[i][j-1], dp[i-1][j]);


        String res = "";


        int i = n, j = n;
        while (i > 0 && j > 0)
        {
            // If this cell is same as diagonally
            // adjacent cell just above it, then
            // same characters are present at
            // str[i-1] and str[j-1]. Append any
            // of them to result.
            if (dp[i][j] == dp[i-1][j-1] + 1)
            {
                res = res + str.charAt(i-1);
                i--;
                j--;
            }

            // Otherwise we move to the side
            // that that gave us maximum result
            else if (dp[i][j] == dp[i-1][j])
                i--;
            else
                j--;
        }

        // Since we traverse dp[][] from bottom,
        // we get result in reverse order.
      //  Reverse(res.begin(), res.end());

        return res;
    }
public static void main(String []arg){
    String str = "aabbcdee";
    System.out.print(longestRepeatedSubSeq(str));
}
}
