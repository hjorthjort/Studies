// Can't get the tests to work, the generics hate me, and I hate them.
public class BifunctorTest {

    public static void main(String[] args) {
        Pair<Integer, Boolean> pair = new Pair<>(10, true);
        Bifunctor<Integer, Boolean> p1 = pair.bimap(x -> x * 2,  y -> y);
        Bifunctor< Integer,  String> p2 = pair.bimap(x -> x, (Boolean x) -> x ? "hej" : "du");
        assert(p1.equals(pair.first(x -> x * 2)));
        assert(p2.equals(pair.second(x -> x ? "hej" : "du")));
    }
}
