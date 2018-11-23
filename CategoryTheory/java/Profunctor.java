import java.util.HashMap;
import java.util.Map;
import java.util.function.Function;

public interface Profunctor<A, B>  {
    default public <C,D> Profunctor<C, D> bimap(Function<C, A> f, Function<B, D> g) {
        return this.first(f).second(g);
    }

    default public <C> Profunctor<C,B> first(Function<C, A> f) {
        return this.bimap(f, x -> x);
    }

    default public <D> Profunctor<A, D> second(Function<B, D> g) {
        return this.bimap(x -> x, g);
    }
}

interface IMap<K, V> {
    V get(K key);
}

/* I think I need to have the "underlying" map specified in the generic type, which is annoying. I couldn't get away from this in Haskell either, so a Map would always be a profunctor in its last two type arguments.
 */
class ImmutableMap<K, V, Kp, Vp> implements Profunctor<Kp, Vp>, IMap<Kp,Vp> {
    private Map<K,V> map;
    private Function<Kp, K> keyFun;
    private Function<V, Vp> valFun;

    public ImmutableMap(Map<K,V> map, Function<Kp, K> keyFun, Function<V, Vp> valFun) {
        this.map = map;
        this.keyFun = keyFun;
        this.valFun = valFun;
    }

    public <Kpp, Vpp> ImmutableMap<K, V, Kpp, Vpp> bimap(Function<Kpp, Kp> f, Function<Vp, Vpp> g) {
        return new ImmutableMap<>(map, keyFun.compose(f), g.compose(valFun));
    }

    public <Kpp> ImmutableMap<K, V, Kpp, Vp> first(Function<Kpp, Kp> f) {
        return new ImmutableMap<>(map, keyFun.compose(f), valFun);
    }

    public <Vpp> ImmutableMap<K, V, Kp, Vpp> second(Function<Vp, Vpp> g) {
        return new ImmutableMap<>(map, keyFun, g.compose(valFun));
    }

    public Vp get(Kp key) {
        K k = keyFun.apply(key);
        V v = map.get(k);
        return valFun.apply(v);
    }

}
