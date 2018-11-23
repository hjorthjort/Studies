public class ShapeTest {
    public static void main(String[] args) {
        Shape c = new Circle(1);
        Shape r = new Rect(3.1415, 3.1415);

        assert(r.area() - 0.1 < c.area() && c.area() < r.area() + 0.1);
        assert(r.circ() - 0.1 < 2 * c.circ() && 2 * c.circ() < r.circ() + 0.1);

        System.out.println("Success!");
    }
}
