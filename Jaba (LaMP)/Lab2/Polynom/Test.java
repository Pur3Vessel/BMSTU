public class Test {
    public static void main(String[] args) {
        Polynom p1 = new Polynom();
        System.out.println(p1);
        double[] k = new double [] {1, -2, 3, -4, 5};
        Polynom p2 = new Polynom(k);
        System.out.println(p2);
        Polynom p3 = new Polynom(10 ,k);
        System.out.println(p3);
       // System.out.println(p2.value(5));
        //System.out.println(p3.value(-2.5));
        k = new double[]{1, 1, 1, 1, 1};
        Polynom p4 = new Polynom(k);
        System.out.println(p4);
        //System.out.println(p4.value(1));
        System.out.println(p4.val);
        p4.setVal(1);
        System.out.println(p4.val);
    }
}
