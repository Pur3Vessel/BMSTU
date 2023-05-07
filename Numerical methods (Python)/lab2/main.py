import math
import pandas as pd


def func(x):
    return x * math.sqrt(x**2) + 16

def rectangles_step(f, a, b, n):
    h = (b - a) / n
    return h * sum(f(a + i * h - h / 2) for i in range(1, n + 1))


def trapeze_step(f, a, b, n):
    h = (b - a) / n
    return h * (((f(a) + f(b)) / 2) + sum(f(a + i * h) for i in range(1, n)))


def simpson_step(f, a, b, n):
    h = (b - a) / n
    return h / 6 * (f(a) + f(b) + 4 * sum(f(a + i * h - h / 2) for i in range(1, n + 1)) +
                    2 * sum(f(a + i * h) for i in range(1, n)))


def check_method(eps, method, a, b, k, f):
    r = eps + 1
    n = 1
    i = 0
    integral = 0
    while abs(r) > eps:
        n *= 2
        integral_past = integral
        integral = method(f, a, b, n)
        r = (integral - integral_past) / (2 ** k - 1)
        i += 1
    return integral, i, integral + r, r


if __name__ == "__main__":
    a = 0
    b = 3
    eps = 0.001

    result_rec, i_rec, result_r_rec, r_rec = check_method(eps, rectangles_step, a, b, 2, func)
    result_trapeze, i_trapeze, result_r_trapeze, r_trapeze = check_method(eps, trapeze_step, a, b, 2, func)
    result_simp, i_simp, result_r_simp, r_simp = check_method(eps, simpson_step, a, b, 4, func)

    pd.options.display.float_format = '{:,.13f}'.format
    answer = pd.DataFrame({
         "n": [i_rec, i_trapeze, i_simp],
        "I": [result_rec, result_trapeze, result_simp],
        "I + R": [result_r_rec, result_r_trapeze, result_r_simp],
        "R": [r_rec, r_trapeze, r_simp]
    })
    pd.set_option('display.max_columns', None)
    answer.index = ["Метод ср. прямоугольников", "Метод трапеций", "Метод Симпсона"]

    print(eps)
    print(answer)
