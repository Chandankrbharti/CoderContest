package com.coder.contest.opps;
class A1{
    protected void x(){
        System.out.println("X=A1");
    }
}
public class B1 extends A1{

    protected void x(){
        System.out.println("X=B1");
    }
    public static void main(String arg[]){
        B1 b1=new B1();
        A1 a1=new A1();
        b1.x();
         a1.x();
    }
}
