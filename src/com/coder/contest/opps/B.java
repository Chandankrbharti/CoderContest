package com.coder.contest.opps;

public class B extends A {
    B(){
        System.out.println("Cust-B default");
    }
    B(String s){
        System.out.println("Cust-B S"+s);
    }

    public void display(){
        System.out.println("B");
    }
    public static void main(String r[]){
       B b=new B();
        B b1=new B("chandan");
        b.display();
        b1.display();
    }
}
