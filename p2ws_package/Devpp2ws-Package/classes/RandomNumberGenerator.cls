public with sharing class RandomNumberGenerator {
	public static Integer randomWithLimit(Integer upperLimit){
        Integer rand = Math.round(Math.random()*1000);
        return Math.mod(rand, upperLimit);
    }

    public static Integer randomWithRange(Integer minimum, Integer maximum){
    	Integer n = maximum - minimum + 1;
        return randomWithLimit(n) + minimum;
    }
}