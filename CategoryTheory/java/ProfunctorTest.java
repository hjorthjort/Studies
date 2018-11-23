import java.util.HashMap;

public class ProfunctorTest {
    public static void main(String[] args) {
        HashMap<Integer, Integer> map = new HashMap<>();
        map.put(11, 10);
        map.put(1, 99);
        ImmutableMap<Integer, Integer, Integer, Integer> imap = new ImmutableMap<>(map, x -> x, x -> x);
        ImmutableMap<Integer, Integer, String, Boolean> bimapped = imap.bimap(s -> s.length(), x -> x % 2 == 0);
        assert(bimapped.get("rikardhjort") == Boolean.TRUE);
        assert(bimapped.get("a") == Boolean.FALSE); // Yes, comparing with boolean is unnecessary, but clearer that it is actually getting returned from the map.
    }
}
