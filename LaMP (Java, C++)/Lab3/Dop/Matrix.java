public class Matrix implements Comparable<Matrix>{
    private int n;
    private int [][] elements;
    // Создается единичная матрица
    public Matrix(int n) {
        this.n = n;
        elements = new int [n][n];
        for (int i = 0; i < n; i++) elements[i][i] = 1;
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++){
                if (i == j) continue;
                else {
                    elements[i][j] = 0;
                }
            }
        }
    }
    public Matrix(int n, int [][] e) {
        this.n = n;
        elements = new int[n][n];
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j++) {
                elements[i][j] = e[i][j];

            }
        }
    }
    public String toString() {
        String s = "";
        for (int i = 0; i < n; i++) {
            for (int j = 0; j < n; j ++) {
                s += elements[i][j] + " ";
            }
            s += "\n";
        }
        return s;
    }
    public int matrixDeterminant() {
        int det = 0;
        switch (n) {
            case 1:
                det = elements[0][0];
                break;
            case 2:
                det = elements[0][0] * elements[1][1] - elements[0][1] * elements[1][0];
                break;
            case 3:
                int h1 = elements[0][0] * elements[1][1] * elements[2][2];
                int h2 = elements[0][1] * elements[1][2] * elements[2][0];
                int h3 = elements[1][0] * elements[2][1] * elements[0][2];
                int h4 = elements[0][2] * elements[1][1] * elements[2][0];
                int h5 = elements[0][1] * elements[1][0] * elements[2][2];
                int h6 = elements[0][0] * elements[1][2] * elements[2][1];
                det = h1 + h2 + h3 - h4 - h5 - h6;
                break;
            default:
                System.out.println("Матрица не содержится в исх. множестве");
                break;
        }
        return det;
    }
    public int compareTo(Matrix obj) {
        int det1 = this.matrixDeterminant();
        int det2 = obj.matrixDeterminant();
        return det1 - det2;
    }
}
