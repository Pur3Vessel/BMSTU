import numpy as np
import pandas as pd

def x_norm(x):
    return max(np.abs(x))

def matrix_norm(f):
    return max(sum(abs(f[i])) for i in range(len(f)))

def zeidel_step(f_up, f_down, x_start, c):
    n = len(x_start)
    x_new = np.zeros(shape=(n,))
    up_part = f_up @ x_start
    for i in range(n):
        x_new[i] = (f_down @ x_new)[i] + up_part[i] + c[i]
    return x_new

if __name__ == "__main__":
    eps = 0.0001
    k = 2
    alpha = 0.1 * k
    beta = 0.1 * k
    a = np.array([
        [10 + alpha, -1, 0.2, 2],
        [1, 12 - alpha, -2, 0.1],
        [0.3, -4, 12 - alpha, 1],
        [0.2, -0.3, -0.5, 8 - alpha]
    ])
    b = np.array([1 + beta, 2 - beta, 3, 1])
    n = len(a)
    f = np.zeros(shape=(n, n))
    c = np.zeros(shape=(n,))
    for i in range(n):
        c[i] = b[i] / a[i][i]
        for j in range(n):
            if i != j:
                f[i][j] = -a[i][j] / a[i][i]
    print(f'f: {f}')
    print(f'c: {c}')
    norm = matrix_norm(f)
    print(f'Норма F: {norm}')

    x_start = np.copy(c)
    i = 0
    delta = 1
    while delta > eps:
        x_new = f @ x_start + c
        delta = x_norm(x_new - x_start)
        i += 1
        absolute = (norm / (1 - norm)) * delta
        relative = absolute / x_norm(x_new)
        print(f'Обычный метод, итерация № {i}, абсолютная ошибка: {absolute}, относительная ошибка: {relative}')
        x_start = x_new
    print()
    simple = a @ x_new
    diff_simple = b - simple

    f_up = np.copy(f)
    f_down = np.copy(f)
    for i in range(n):
        for j in range(n):
            if j > i:
                f_down[i, j] = 0
            else:
                f_up[i, j] = 0

    x_start = np.copy(c)
    i = 0
    delta = 1
    eps = 0.0001
    while delta > eps:
        x_new = zeidel_step(f_up, f_down, x_start, c)
        delta = x_norm(x_new - x_start)
        i += 1
        absolute = (norm / (1 - norm)) * delta
        relative = absolute / x_norm(x_new)
        print(
            f'Метод Зейделя, итерация № {i}, абсолютная ошибка: {absolute}, относительная ошибка: {relative}')
        x_start = x_new

    zeidel = a @ x_new
    zeidel_diff = b - zeidel

    answer = pd.DataFrame({"simple": simple, "zeidel": zeidel, "true": b, "simple_diff": diff_simple, "zeidel_diff": zeidel_diff})
    print(answer)




