package com.coder.contest.misslineous;

import java.util.ArrayList;
import java.util.Collections;

public class Comprat {
    public static void main(String[] args)
    {
        ArrayList<Movies> list = new ArrayList<Movies>();
        list.add(new Movies("Force Awakens", 8.3, 2015));
        list.add(new Movies("Star Wars", 8.7, 1977));
        list.add(new Movies("Empire Strikes Back", 8.8, 1980));
        list.add(new Movies("Return of the Jedi", 8.4, 1983));


        System.out.println("Sorted by rating");
        RatingCompare ratingCompare = new RatingCompare();
        Collections.sort(list, ratingCompare);
        for (Movies movie: list)
            System.out.println(movie.getRating() + " " +
                    movie.getName() + " " +
                    movie.getYear());



    }
}
