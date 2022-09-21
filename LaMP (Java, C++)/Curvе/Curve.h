// A*sin(x) + B*cos(x)
#include <math.h>
using namespace std;
template <typename T>
class Curve {
private:
    T sinK;
    T cosK;
public:
    Curve(bool s) {
        if (s) {
            sinK = 1;
            cosK = 0;
        } else {
            cosK = 1;
            sinK = 0;
        }
    }
    T getS () {
        return sinK;
    }
    T getC() {
        return cosK;
    }
    Curve &operator+=(const Curve &obj) {
        sinK += obj.sinK;
        cosK += obj.cosK;
        return *this;
    };
    Curve operator+(const Curve &other) {
        return Curve(*this) += other;
    }

    Curve &operator-=(const Curve &obj) {
        sinK -= obj.sinK;
        cosK -= obj.cosK;
        return *this;
    }
    Curve operator-(const Curve other) {
        return Curve(*this) -= other;
    }

    Curve &operator*=(const T m) {
        sinK *= m;
        cosK *= m;
        return *this;
    }
    Curve& operator*(const T m) {
        return Curve(*this) *= m;
    }
    Curve& operator-() {
        return *this *= -1;
    }
    Curve& operator!() {
        T b1 = sinK;
        T b2 = cosK;
        cosK = b1;
        sinK = -1 * b2;
        return *this;
    }
    T operator()(T x) {
        T ans = 0;
        ans += sinK * sin(x);
        ans += cosK * cos(x);
        return ans;
    }
};
template <typename T>
ostream& operator<<(ostream& os, Curve<T>& curve) {
    os << curve.getS();
    os << " * sin(x) + ";
    os << curve.getC();
    os << " * cos(x)";
    os << endl;
    return os;
}
