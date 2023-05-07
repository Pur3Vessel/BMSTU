import pandas as pd
import math


#def f(x):
    #return math.exp(x)
def f(x):
   return (x ** 4) + 2 * (x ** 3) + 3 * (x ** 2) + 4 * x

def solve_equation(a, b):
    n = len(b)
    t = [[0] * n for _ in range(m)]
    x = [0] * n
    y = [0] * n

    for i in range(n):
        for j in range(i):
            s = sum(t[i][k] * t[j][k] for k in range(j))
            t[i][j] = (a[i][j] - s) / t[j][j]
        s = sum(t[i][k] ** 2 for k in range(i))
        t[i][i] = math.sqrt(a[i][i] - s)

    for i in range(n):
        s = sum(t[i][j] * y[j] for j in range(i))
        y[i] = (b[i] - s) / t[i][i]
    for i in reversed(range(n)):
        s = sum(t[j][i] * x[j] for j in range(i + 1, n))
        x[i] = (y[i] - s) / t[i][i]
    return x


def make_equation(m, n, x, y):
    a = [[0] * m for _ in range(m)]
    b = [0] * m
    for i in range(m):
        for j in range(m):
            a[i][j] = sum(x[k] ** (i + j) for k in range(n + 1))
        b[i] = sum(y[k] * x[k] ** i for k in range(n + 1))
    return a, b


if __name__ == "__main__":
    x_0 = 0
    x_n = 1
    n = 10
    h = (x_n - x_0) / n
    x = [0] * (n + 1)
    y = [0] * (n + 1)

    for i in range(n + 1):
        x[i] = x_0 + i * h
        y[i] = f(x[i])

    m = 4
    a, b = make_equation(m, n, x, y)
    coofs = solve_equation(a, b)

    x_arr = []
    y_arr = []
    true_arr = []
    delta_arr = []
    for i in range(2 * n + 1):
        x_i = x_0 + 0.5 * i * h
        y_i = coofs[0] + coofs[1] * x_i + coofs[2] * x_i ** 2 + coofs[3] * x_i ** 3
        x_arr.append(x_i)
        y_arr.append(y_i)
        true_arr.append(f(x_i))
        delta_arr.append(y_i - f(x_i))
    MSE = math.sqrt(sum(d ** 2 for d in delta_arr)) / len(delta_arr)
    delta = MSE / math.sqrt(sum(y_i ** 2 for y_i in true_arr))
    print(f'MSE: {MSE}')
    print(f"Delta: {delta}")
    answer = pd.DataFrame({"x": x_arr, "ev": y_arr, "true": true_arr, "diff": delta_arr})
    print(answer)
