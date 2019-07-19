package com.coder.contest.opps;

public class B extends A {
//    private B(){
//        System.out.println("Cust-B default"); //this works fine
//    }
//   public B(){
//
//       System.out.println("Cust-B default");
//    }
//   public B(String s){
//        System.out.println("Cust-B S"+s);
//    }

    public void m2(){
        System.out.println("M2-B");
    }
    public void m3(){
        System.out.println("M3-B");
    }
    public void display(){
        System.out.println("B");
    }
    public static void main(String r[]){
       A b=new B();
        b.display();

        A a=new B();
        ((B) a).m3();
        a.m1();
        a.m2();

        A a11=new A();
        a11.m2();
        a11.m1();
        a11.display();

        A a1=new B();
        a1.display();
        a1.m1();
        a1.m2();
       ((B) a1).m3();


    }
}
