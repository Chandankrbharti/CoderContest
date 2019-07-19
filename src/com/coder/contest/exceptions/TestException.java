package com.coder.contest.exceptions;

import java.io.IOException;

public class TestException extends exception{
    public void exception(Object o){
        System.out.println("exception method");
    }
    public static void main(String arg[]) throws Exception {
        exception x=new exception();

            x.exception(null);


    }
}
