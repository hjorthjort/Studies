public class Either<A, B> {

    private A left;
    private B right;
    private Tag tag;

    private Either(Tag t, Object o) {
        this.tag = t;
        if (t == Tag.LEFT) {
            this.left = (A)o;
        } else {
            this.right = (B)o;
        }
    }

    public static <A, B> Either<A, B> left(A obj) {
        return new Either(Tag.LEFT, obj);
    }

    public static <A, B> Either<A, B> right(B obj) {
        return new Either(Tag.RIGHT, obj);
    }

    public <C> C factorize(Functor<A, C> leftFun, Functor<B,C> rightFun) {
        if (this.tag == Tag.LEFT) {
            return leftFun.f(this.left);
        }
        return rightFun.f(this.right);
    }

    public String toString() {
        StringBuilder sb = new StringBuilder();
        sb.append(this.tag.toString());
        sb.append(": ");
        if (this.tag == Tag.LEFT) {
            sb.append(this.left.toString());
        } else {
            sb.append(this.right.toString());
        }
        return sb.toString();
    }

    @FunctionalInterface
    public interface Functor<X, C> {
        public C f(X obj);
    }

    public enum Tag {
        LEFT,
        RIGHT;
    }

}

