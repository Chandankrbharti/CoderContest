package com.coder.contest;

import java.io.UnsupportedEncodingException;
import java.util.Base64;

public class HelloWorld {

    public static void main(String args[]) {

        try {

            // Encode using basic encoder
            String B = Base64.getEncoder().encodeToString(
                    "B".getBytes("utf-8"));
            System.out.println("Base64 Encoded String (Basic) :" + B);

            String P = Base64.getEncoder().encodeToString(
                    "P".getBytes("utf-8"));
            System.out.println("Base64 Encoded String (Basic) :" + P);

            String c=B+P;
            System.out.println("Base64 Encoded String (Basic) :" + c);
            byte[] base64decodedBytes = Base64.getDecoder().decode(c);

            System.out.println("ori :" + new String(base64decodedBytes));


        } catch(UnsupportedEncodingException e) {
            System.out.println("Error :" + e.getMessage());
        }
    }
}
