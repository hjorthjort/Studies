import java.util.*;

public class EitherTest {

    public static void main(String[] args) {
        List<Either<String, Object>> results = new ArrayList<>();
        results.add(testLeftConstruction());
        results.add(testRightConstruction());
        results.add(testFactorize());
        for (Either<String, Object> either : results) {
            either.factorize((String s) -> errorReader(s), (Object e) -> successReader(e));
        }
    }

    private static Integer errorReader(String errorString) {
        System.err.println("Test Failed:");
        System.err.println(errorString);
        return 1;
    }

    private static Integer successReader(Object e) {
        System.out.println("Succesfully returned Object:");
        System.out.println(e);
        return 0;
    }

    public static Either<String, Object> testLeftConstruction() {
        try {
            Either<Integer, Boolean> e1 = Either.left(42);
            return Either.right(e1);
        } catch (Exception e) {}
        return Either.left("Failed to create Either<Integer, Bool> with left(42)");
    }

    public static Either<String, Object> testRightConstruction() {
        try {
            Either<Integer, Boolean> e1 = Either.right(true);
            return Either.right(e1);
        } catch (Exception e) {}
        return Either.left("Failed to create Either<Integer, Bool> with left(42)");
    }

    public static Either<String, Object> testFactorize() {
        try {
            Either<Integer, Boolean> e1 = Either.left(10);
            Either<Integer, Boolean> e2 = Either.right(true);
            StringBuilder sb = new StringBuilder();

            Double f1 = e1.factorize((Integer i) -> 3.1415, (Boolean b) -> b ? 0.0000 : -1.1);
            Double f2 = e2.factorize((Integer i) -> 3.1415, (Boolean b) -> b ? 0.0000 : -1.1);

            return Either.right(f1 + f2);
        } catch (Exception e) {}
        return Either.left("Failed to create Either<Integer, Bool> with left(42)");
    }
}
