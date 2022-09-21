public class Element {
    private double weight;
    private static int count = 0;
    public double getWeight() {
        return weight;
    }
    public static double getCount() {
        return count;
    }
    // по умолчанию масса = 1
    public Element() {
        weight = 1;
        count++;
    }
    public Element(double m) {
        weight = m;
        count++;
    }

}
