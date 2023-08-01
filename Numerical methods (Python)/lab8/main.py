import math


def q(i, j, n, m):
    if i in [0, n] and j in [0, m]:
        return 1 / 4
    if i in [0, n] or j in [0, m]:
        return 1 / 2
    return 1


def integrate(n, m, a, b, c, d, func):
    h_x = (b - a) / n
    h_y = (d - c) / m

    x_i = lambda i: a + i * h_x
    y_j = lambda i: c + i * h_y

    inner = 0
    for i in range(n + 1):
        for j in range(m + 1):
            inner += q(i, j, n, m) * func(x_i(i), y_j(j))
    return h_x * h_y * inner


def cell(n, m, a, b, c, d, func):
    h_x = (b - a) / n
    h_y = (d - c) / m

    x_i = lambda i: a + i * h_x
    y_j = lambda i: c + i * h_y

    inner = 0
    for i in range(n):
        for j in range(m):
            inner += func(x_i(i) + h_x / 2, y_j(j) + h_y / 2)
    return h_x * h_y * inner


def phi_1(x):
    return 0


def phi_2(x):
    return 1 + math.log(x)


def f(x, y):
    return math.exp(y)


if __name__ == '__main__':
    eps = 0.001
    a = 1
    b = 2


    y = lambda u, v: phi_1(u) + v * (phi_2(u) - phi_1(u))
    j = lambda u, v: phi_2(u) - phi_1(u)
    f_new = lambda u, v: f(u, y(u, v)) * abs(j(u, v))

    d = 1
    c = 0
    h = math.sqrt(eps)
    n = int((b - a) / h)
    m = int((d - c) / h)

    p = 2
    s1 = integrate(n, m, a, b, c, d, f_new)
    delta = abs((s1 - integrate(n * 2, m * 2, a, b, c, d, f_new))) / (2 ** p - 1)
    print("Повторное интегрирование:")
    print(n, m)
    while delta > eps:
        n *= 2
        m *= 2
        print(n, m)
        s1 = integrate(n, m, a, b, c, d, f_new)
        delta = (s1 - integrate(n * 2, m * 2, a, b, c, d, f_new)) / (2 ** p - 1)

    print(s1)
    print(delta)
    n = int((b - a) / h)
    m = int((d - c) / h)
    print("CELL:")
    res_cell = cell(n, m, a, b, c, d, f_new)
    delta = abs(res_cell - cell(n * 2, m * 2, a, b, c, d, f_new)) / (2 ** p - 1)
    print(n, m)
    while delta > eps:
        n *= 2
        m *= 2
        print(n, m)
        res_cell = cell(n, m, a, b, c, d, f_new)
        delta = abs(res_cell - cell(n * 2, m * 2, a, b, c, d, f_new)) / (2 ** p - 1)

    print(res_cell)
    print(delta)

    analityc = 3.0774
    print(f"Diff повторное интегрирование: {s1 - analityc}")
    print(f"Diff cell: {res_cell - analityc}")
