package com.coder.contest;

import java.util.Comparator;

class RatingCompare implements Comparator<Movies>
{
    public int compare(Movies m1, Movies m2)
    {
        if (m1.getRating() < m2.getRating()) return -1;
        if (m1.getRating() > m2.getRating()) return 1;
        else return 0;
    }
}
