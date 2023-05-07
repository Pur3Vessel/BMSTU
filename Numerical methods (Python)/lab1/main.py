import numpy as np

type = np.longdouble


def make_matrix(mid, top, bot):
    n = len(mid)
    a = np.zeros((n, n), dtype=type)
    a[0][0] = mid[0]
    a[0][1] = top[0]
    a[n - 1][n - 1] = mid[n - 1]
    a[n - 1][n - 2] = bot[n - 2]
    for i in range(1, n - 1):
        a[i][i] = mid[i]
        a[i][i - 1] = bot[i - 1]
        a[i][i + 1] = top[i]
    return a


def run(mid, top, bot, b):
    n = len(b)
    x = np.zeros(n, dtype=type)
    v = np.zeros(n, dtype=type)
    u = np.zeros(n, dtype=type)

    v[0] = -top[0] / mid[0]
    u[0] = b[0] / mid[0]
    for i in range(1, n):
        if i == n - 1:
            v[i] = 0
        else:
            v[i] = -top[i] / (bot[i - 1] * v[i - 1] + mid[i])
        u[i] = (b[i] - bot[i - 1] * u[i - 1]) / (bot[i - 1] * v[i - 1] + mid[i])

    x[n - 1] = u[n - 1]
    for i in range(n - 1, 0, -1):
        x[i - 1] = v[i - 1] * x[i] + u[i - 1]
    return x


if __name__ == "__main__":
    n = 4
    mid = np.array([4, 4, 4, 4], dtype=type)
    top = np.array([1, 1, 1], dtype=type)
    bot = np.array([1, 1, 1], dtype=type)
    b = np.array([5, 6, 6, 5], dtype=type)

    x = run(mid, top, bot, b)
    a = make_matrix(mid, top, bot)
    res_err = a @ x
    r = b - res_err

    a_inv = np.linalg.inv(a.astype(np.float32))
    e = a_inv @ r
    print(x)
    print(e)
