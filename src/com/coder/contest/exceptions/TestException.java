package com.coder.contest.exceptions;

import java.io.IOException;

public class TestException {
    public static void main(String arg[]) throws Exception {
        exception x=new exception();
        try {
            x.exception(null);
        } catch (Exception e) {
            try {
                throw new  Exception("chadnan");
            } catch (Exception e1) {
                e1.printStackTrace();
            }
        }
    }
}
