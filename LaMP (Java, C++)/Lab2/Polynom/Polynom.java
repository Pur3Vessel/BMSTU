public class Polynom {
    public int deg; //степень полинома
    private double[] coefficients; //его коэффициенты
    public double val = 0;
    public Polynom(){
        deg = 0;
        coefficients = new double[1];
        coefficients[0] = 0;
    }

    //отсчет в массиве коофициентов идет справа налево
    public Polynom(double[] k) {
        deg = k.length - 1;
        coefficients = new double[deg + 1];
        for (int i = deg; i >= 0; i--) coefficients[i] = k[i];
    }
    //можно указать степень и дать неполный массив, тогда недостающие кооф = 0 (степень должна быть больше размера массива)
    public Polynom(int n, double[] k) {
        deg = n;
        coefficients = new double[deg + 1];
        if (n == (k.length - 1)) {
            for (int i = deg; i >= 0; i--) coefficients[i] = k[i];
        } else {
            for (int i = deg, j = k.length - 1; j >= 0; j--, i--) {
                coefficients[i] = k[j];
            }
            for (int i = deg - k.length; i >= 0; i--) {
                coefficients[i] = 0;
            }
        }
    }
  //  public double value (double x){
     //   double v = 0;
      //  v += coefficients[0];
     //   for (int i = 1; i <= deg; i++) {
      //      v += Math.pow(x, i) * coefficients[i];
      //  }
       // return v;
   // }

    public void setVal (double x) {
        double v = 0;
        v += coefficients[0];
        for (int i = 1; i <= deg; i++) {
            v += Math.pow(x, i) * coefficients[i];
        }
       val = v;
    }
    public String toString(){
        String str = "";
        if (deg == 0) str += coefficients[0];
        else {
            str += coefficients[deg] + " " + "x" + deg;
            for (int i = deg - 1; i > 1; i--) {
                if (coefficients[i] != 0) {
                    if (coefficients[i] > 0) {
                        str += " " + "+" + " " + coefficients[i] + " " + "x" + i;
                    } else {
                        str += " " + "-" + " " + Math.abs(coefficients[i]) + " " + "x" + i;
                    }
                }
            }
            if (coefficients[1] != 0) {
                if (coefficients[0] > 0) {
                    str += " " + "+" + " " + coefficients[1] + " " + "x";
                } else {
                    str += " " + "-" + " " + Math.abs(coefficients[1]) + " " + "x";
                }
            }
            if (coefficients[0] != 0) {
                if (coefficients[0] > 0) {
                    str += " " + "+" + " " + coefficients[0];
                } else {
                    str += " " + "-" + " " + Math.abs(coefficients[0]);
                }
            }
        }
        return str;
    }

}
