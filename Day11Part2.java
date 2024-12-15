import java.io.File;
import java.io.FileNotFoundException;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;
import java.util.HashMap;

class Day11Part2 {

    static final int STEP_COUNT = 75;

    static ArrayList<Long> change(Long n) {
        if (n == 0L) {
            return new ArrayList<Long>(List.of(1L));
        }

        Double log = Math.ceil(Math.log10(n.doubleValue() + 1F));
        Long length = log.longValue();
        if (length % 2 == 0) {
            Long pow = ((Double)Math.pow(10, length / 2)).longValue();
            Long n2 = n % pow;
            Long n1 = (n - n2) / pow;
            return new ArrayList<Long>(List.of(n1, n2));
        }

        return new ArrayList<Long>(List.of(n * 2024));
    }

    public static void main(String[] args)
        throws FileNotFoundException
    {
        Scanner sc = new Scanner(new File("11.in"));
        ArrayList<Long> numbers = new ArrayList<>();
        String line = sc.nextLine();
        String[] temporary = line.split(" ");
        for (String string : temporary) {
            numbers.add(Long.parseLong(string));
        }

        HashMap<Long, Long> cache = new HashMap<Long, Long>();
        for (Long n : numbers) {
            cache.merge(n, 1L, Long::sum);
        }

        for (int step = 1; step <= STEP_COUNT; ++step) {
            HashMap<Long,Long> next = new HashMap<Long,Long>();
            for (long stone: cache.keySet()) {
                ArrayList<Long> new_stones = change(stone);
                for (long new_stone: new_stones) {
                    next.merge(new_stone,
                               cache.getOrDefault(stone, 1L),
                               Long::sum);
                }
            }
            cache = next;
        }
        long sum = 0;
        for (long v: cache.values()) sum += v;
        System.out.println(sum);
    }
}
