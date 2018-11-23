public interface Shape {
    double PI = 3.15156;
    double area();
    double circ(); // Adding circ: 1 line.
}

// Adding Square: 15 lines
/* In Haskell (* for modified)
   data Shape = Circle Float | Rect Float Float | Square Float  -- *
   area :: Shape -> Float
   area (Circle r) = pi * r * r
   area (Rect w h) = w * h
*/ area 
class Square implements Shape {
    private Rect rect;

    public Square(double side) {
        this.rect = new Rect(side, side);
    }

    public double area() {
        return this.rect.area();
    }

    public double circ() {
        return this.rect.circ();
    }
}

class Circle implements Shape {
    private double radius;
    public Circle(double radius) {
        this.radius = radius;
    }

    @Override
    public double area() {
        return this.radius * Shape.PI * Shape.PI;
    }

    // Adding circ: 3 lines.
    @Override
    public double circ() {
        return this.radius * 2 * Shape.PI;
    }
}

class Rect implements Shape {
    private double width, height;
    public Rect(double width, double height) {
        this.width = width;
        this.height = height;
    }

    @Override
    public double area() {
        return this.width * this.height;
    }

    // Adding circ: 3 lines.
    @Override
    public double circ() {
        return this.height * 2 + this.width * 2;
    }
}
