class Reader<R, T> implements Function<R, T>, Functor<T> {

    private Function<R,T> fun;

    public Reader(Function<R, T> f) {
        this.fun = f;
    }

    @Override
    public T f(R x) {
        return this.fun.f(x);
    }

    public <B> Reader<R, B> fmap(Function<T,B> fun) {
        return new Reader<>((R x) -> fun.f(this.fun.f(x)));
    }

}

@FunctionalInterface
interface Function<A,B> {
    B f(A x);
}

interface Functor<T> {
    <S> Functor<S> fmap(Function<T,S> fun);
}
