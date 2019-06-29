package com.coder.contest.misslineous;

import static java.lang.Character.*;

class Solution {
    public String solution(String s) {
        char c = s.charAt(0);
        if (isUpperCase(c)){  // please fix condition
            return "upper";
        } else if (isLowerCase(c)) {  // please fix condition
            return "lower";
        } else if (isDigit(c)) {  // please fix condition
            return "digit";
        } else {
            return "other";
        }
    }
}