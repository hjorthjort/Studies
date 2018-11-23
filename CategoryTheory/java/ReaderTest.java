import java.util.*;

public class ReaderTest {
    public static void main(String[] args) {
        Reader<Integer, Integer> r1 = new Reader<>(x -> x + 1);
        Reader<Integer, Boolean> r2 = r1.fmap(x -> x % 2 == 0);
        assert(!r2.f(10));
        assert(r2.f(11));
    }
}
