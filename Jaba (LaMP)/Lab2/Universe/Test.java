public class Test {
    public static void main(String[] args) {
        Universe u = new Universe();
        u.addElement(3);
        double[] ms = new double[] {1, 2, 3, 4 ,5};
        u.addElements(ms);
        System.out.println(u.getCount());
        System.out.println(u.totalWeight());
        System.out.println(u.midWeight());
    }
}

