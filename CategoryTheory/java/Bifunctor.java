import java.util.function.Function;

public interface Bifunctor<A, B> {

    default public <C,D> Bifunctor< C,  D> bimap(Function<A,C> f, Function<B, D> g) {
        return this.first(f).second(g);
    }
    default public <C> Bifunctor< C,B>    first(Function<A,C> f) {
        return this.bimap(f, x -> x);
    }
    default public <D> Bifunctor<A, D>    second(Function<B,D> g) {
        return this.bimap(x -> x, g);
    }
}

class Pair<A,B> implements Bifunctor<A,B> {
    private A a;
    private B b;

    public Pair(A a, B b) {
        this.a = a;
        this.b = b;
    }

    public <C> Bifunctor< C, B> first(Function<A,C> f) {
        return new Pair<>(f.apply(a), b);
    }

    public <D> Bifunctor<A, D> second(Function<B,D> g) {
        return new Pair<>(a, g.apply(b));
    }

    public boolean equals(Object o) {
        if (o == null) return true;
        if (!(o instanceof Pair)) return false;
        Pair newO = (Pair) o;
        return this.a.equals(newO.a) && this.b.equals(newO.b);

    }
}
