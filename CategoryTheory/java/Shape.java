public interface Shape {
    double PI = 3.15156;
    double area();
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
}
