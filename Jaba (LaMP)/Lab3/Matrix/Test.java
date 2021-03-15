import java.util.Arrays;

public class Test {
    public static void main(String[] args) {
        System.out.println("До сортировки");
        int [][] arg = {{1, 2, 3}, {4, 5, 6}, {7, 8, 9}};
        Matrix m1 = new Matrix(3, arg);
        int [][] arg2 = {{1, 2, 3, 4}, {2, 5, 7, 8}, {3, 7, 4, 9}, {4, 8, 9, 3}};
        Matrix m2 = new Matrix(4, arg2);
        int [][] arg3 = {{3, 4, 5}, {5, 6 ,7}, {5, 7, 6}};
        Matrix m3 = new Matrix(3, arg3);
        int [][] arg4 = {{2, 3}, {3, 6}};
        Matrix m4 = new Matrix(2, arg4);
        int [][] args5 = {{4,5,6}, {5, 6, 7}, {3, 4, 9}};
        Matrix m5 = new Matrix(3, args5);
        Matrix[] mArray = new Matrix[5];
        mArray[0] = m1;
        mArray[1] = m2;
        mArray[2] = m3;
        mArray[3] = m4;
        mArray[4] = m5;
        for (int i = 0; i < 5; i++) System.out.println(mArray[i]);
        Arrays.sort(mArray);
        System.out.println("После сортировки");
        for (int i = 0; i < 5; i++) System.out.println(mArray[i]);
    }
}
/*
1 2 3
4 5 6
7 8 9

1 2 3 4
2 5 7 8
3 7 4 9
4 8 9 3

3 4 5
5 6 7
5 7 6

2 3
3 6

4 5 6
5 6 7
3 4 9
*/
