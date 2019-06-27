package com.coder.contest;


import java.util.Scanner;

abstract class Distance {
    protected int feet;
    protected float inches;

    abstract public void setFeetAndInches(int feet, float inches);
    abstract public int getFeet();
    abstract public float getInches();
    abstract String getDistanceComparison(Distance dist2);
}



class DistanceImplementation extends Distance{
    protected int feet;
    protected float inches;
    @Override
    public void setFeetAndInches(int feet, float inches) {
        this.feet=feet;
        this.inches=inches;
    }

    @Override
    public int getFeet() {
        return feet;
    }

    @Override
    public float getInches() {
        return inches;
    }

    String getDistanceComparison(Distance dist2){
            if(getFeet()>dist2.getFeet()&& getInches()>dist2.getInches()){
                return  "first is greater than second";
            }
            else{
                return "second is greater than first" ;
            }

    }

}



public class DistanceCalculator {
    private static final Scanner scan = new Scanner(System.in);

    public static void main(String[] args) {
        Distance dist1 = new DistanceImplementation();
        Distance dist2 = new DistanceImplementation();

        int feet1 = scan.nextInt();
        float inches1 = scan.nextFloat();

        int feet2 = scan.nextInt();
        float inches2 = scan.nextFloat();

        dist1.setFeetAndInches(feet1, inches1);
        dist2.setFeetAndInches(feet2, inches2);

        System.out.println(dist1.getDistanceComparison(dist2));
    }
}