import pandas as pd


#def f(x):
#   return (x ** 4) + 2 * (x ** 3) + 3 * (x ** 2) + 4 * x

#def f(x):
#    return math.exp(x)

def run(n, h, y):
    top = [1] * n
    top[n-1] = 0
    mid = [4] * n
    bot = [1] * n
    bot[0] = 0
    answer = [0] * n
    for i in range(n):
        answer[i] = 3 * (y[i + 2] - 2 * y[i + 1] + y[i]) / (h ** 2)

    v = [0] * n
    u = [0] * n
    x = [0] * n

    v[0] = - top[0] / mid[0]
    u[0] = answer[0] / mid[0]

    for i in range(1, n):
        v[i] = - top[i] / (bot[i] * v[i - 1] + mid[i])
        u[i] = (answer[i] - bot[i] * u[i - 1]) / (bot[i] * v[i - 1] + mid[i])

    x[n - 1] = u[n - 1]
    for i in range(n - 1, 0, -1):
        x[i - 1] = v[i - 1] * x[i] + u[i - 1]

    return [0] + x + [0]


def calculate_coefficients(c, y, n, h):
    a = [0] * n
    b = [0] * n
    d = [0] * n
    for i in range(n):
        a[i] = y[i]
        b[i] = (y[i + 1] - y[i]) / h - h * (c[i + 1] + 2 * c[i]) / 3
        d[i] = (c[i + 1] - c[i]) / (3 * h)
    return a, b, d


if __name__ == '__main__':
    x_0 = 1
    x_n = 5
    n = 8
    h = (x_n - x_0) / n

    #x = [0] * (n + 1)
    #y = [0] * (n + 1)

    #for i in range(n + 1):
    #    x[i] = x_0 + i * h
    #    y[i] = f(x[i])
    x = [1, 1.5, 2, 2.5, 3, 3.5, 4, 4.5, 5]
    y = [3.33, 2.30, 1.60, 1.27, 1.18, 0.99, 1.41, 0.80, 1.12]
    c = run(n - 1, h, y)
    a, b, d = calculate_coefficients(c, y, n, h)
    print(a)
    print(b)
    print(c)
    print(d)

    func_arr = []
    spline_arr = []
    delta = []
    x_arr = [1, 1.25, 1.5, 1.75, 2, 2.25, 2.5, 2.75, 3, 3.25, 3.5, 3.75, 4, 4.25, 4.5, 4.75, 5]
    for i in range(2 * n + 1):
        x_i = x_0 + 0.5 * i * h
        j = i // 2
        if j == n:
            j -= 1
        spline_i = a[j] + b[j] * (x_i - x[j]) + c[j] * (x_i - x[j]) ** 2 + d[j] * (x_i - x[j]) ** 3
    #    y_i = f(x_i)

    #    func_arr.append(y_i)
        spline_arr.append(spline_i)
    #    delta.append(spline_i - y_i)
    #    x_arr.append(x_i)

    answer = pd.DataFrame({'x': x_arr, 'interpolation': spline_arr})
    print(answer)
