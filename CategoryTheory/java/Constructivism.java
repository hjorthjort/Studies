import java.util.function.Function;

public class Constructivism {
}

class True {}

class Void {

    private Void v;

    public Void(Void v) {
        this.v = v;
    }

    public <T> T absurd() {
        return v.absurd();
    }
}

class And<A,B> {
    private A a;
    private B b;

    public And(A a, B b) {
        this.a=a;
        this.b=b;
    }
}

class Or<A,B> {
    private A a = null;
    private B b = null;

    private Or() {}
    
    public static <A,B> Or<A,B> left(A a) {
        Or<A,B> left = new Or<>();
        left.a = a;
        return left;
    }

    public static <A,B> Or<A,B> right(B b) {
        Or<A,B> right = new Or<>();
        right.b = b;
        return right;
    }
    public <C> C either(Function<A,C> lf, Function<B,C> rf) {
        if (b == null) return lf.apply(a);
        return rf.apply(b);
    }
}

class Not<A> {
    Function<A, Void> disproof;

    public Not (Function<A,Void> disproof) {
        this.disproof = disproof;
    }

    public Void apply(A a) {
        return disproof.apply(a);
    }
}

class Proofs {

    public static <A,B> Function<
          Not< Or <A ,     B> >
        , And< Not<A>, Not<B> >
        > deMorgan1() {
        return notAorB -> new And<Not<A>, Not<B>>(
                new Not<A>(a -> notAorB.apply(Or.left(a))), // not A
                new Not<B>(b -> notAorB.apply(Or.right(b)))
                    );
    }

}
