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
    public int compareTo(Matrix obj) {
        int countM1 = 0;
        int countM2 = 0;
        for (int i = 0; i < this.n; i++) {
            for (int j = 0; j < this.n; j++) {
                if (this.elements[i][j] != this.elements[j][i]) countM1++;
            }
        }
        for (int i = 0; i < obj.n; i++) {
            for (int j = 0; j < obj.n; j++) {
                if (obj.elements[i][j] != obj.elements[j][i]) countM2++;
            }
        }
        return countM1 - countM2;
    }
}
