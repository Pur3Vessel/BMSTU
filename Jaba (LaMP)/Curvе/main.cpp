#include <iostream>
#include "Curve.h"
using namespace std;
int main() {
    Curve<double> curv1(true);
    cout << curv1;
    Curve<double> curv2(false);
    cout << curv2;
    curv1 += curv2;
    cout << curv1;
    Curve<double> curv3 = curv1 + curv2;
    cout << curv3;
    Curve<double> curv4 = curv3 * 3;
    cout << curv4;
    Curve<double> curv5 = curv4 - curv1;
    cout << curv5;
    !curv4;
    cout << curv4;
    -curv4;
    cout << curv4;
    cout << curv1(3) << endl;
    return 0;
}
