import math
import pandas as pd


def f(x):
    return 5


def check(x):
    return 1/12 * (4 * math.exp(3*x) + 3 * math.exp(4*x) + 5)


def gun(n, a, b, h, p, q, x_0, o_h):
    y_0 = [0] * (n + 1)
    y_1 = [0] * (n + 1)
    y_0[0] = a
    y_0[1] = a + o_h
    y_1[1] = o_h

    for i in range(1, n):
        y_0[i + 1] = (h * h * f(x_0 + i * h) - (1 - h / 2 * p) * y_0[i - 1] - (h * h * q - 2) * y_0[i]) / (1 + h / 2 * p)
        y_1[i + 1] = ((h / 2 * p - 1) * y_1[i - 1] - (h * h * q - 2) * y_1[i]) / (1 + h / 2 * p)

    if y_1[n] == 0:
        return gun(n, a, b, h, p, q, x_0, o_h + 1)
    else:
        c1 = (b - y_0[n]) / y_1[n]
        return [y_0[i] + c1 * y_1[i] for i in range(n+1)]


def run(mid, top, bot, b):
    n = len(b)
    x = [0] * n
    v = [0] * n
    u = [0] * n

    v[0] = -top[0] / mid[0]
    u[0] = b[0] / mid[0]
    for i in range(1, n):
        v[i] = -top[i] / (bot[i] * v[i - 1] + mid[i])
        u[i] = (b[i] - bot[i] * u[i - 1]) / (bot[i] * v[i - 1] + mid[i])

    x[n - 1] = u[n - 1]
    for i in range(n - 1, 0, -1):
        x[i - 1] = v[i - 1] * x[i] + u[i - 1]
    return x


def make_equation(h, p, q, n, x_0, a, b):
    bot = []
    mid = []
    top = []
    result = []

    mid.append(h * h * q - 2)
    top.append(1 + h / 2 * p)
    result.append(h * h * f(x_0 + h) - a * (1 - h / 2 * p))
    bot.append(0)

    for i in range(2, n - 1):
        bot.append(1 - h / 2 * p)
        mid.append(h * h * q - 2)
        top.append(1 + h / 2 * p)
        result.append(h * h * f(x_0 + h * i))

    bot.append(1 - h / 2 * p)
    mid.append(h * h * q - 2)
    result.append(h * h * f(x_0 + (n - 1) * h) - b * (1 + h / 2 * p))
    top.append(0)

    return bot, mid, top, result


if __name__ == "__main__":
    p = -7
    q = 12
    n = 50
    x_0 = 0
    x_n = 1
    h = (x_n - x_0) / n
    a = check(x_0)
    b = check(x_n)
    print(b)

    bot, mid, top, result = make_equation(h, p, q, n, x_0, a, b)
    x_arr = [x_0 + i * h for i in range(n + 1)]
    y_true_arr = [check(x_0 + i * h) for i in range(n + 1)]
    y_ev_arr = [a] + run(mid, top, bot, result) + [b]
    delta = [y_true_arr[i] - y_ev_arr[i] for i in range(n + 1)]
    y_gun = gun(n, a, b, h, p, q, x_0, h)
    delta_gun = [y_true_arr[i] - y_gun[i] for i in range(n + 1)]

    #pd.options.display.float_format = '{:,.13f}'.format
    #pd.set_option('display.max_columns', None)
    answer = pd.DataFrame({"x": x_arr, "y_true": y_true_arr, "y_ev": y_ev_arr, "diff": delta, "gun": y_gun, "delta_gun": delta_gun})
    print(answer)
    print()
    for i in range(n + 1):
       print(delta_gun[i] - delta[i])

