from sympy import diff, symbols, lambdify

def f(x, y):
    return 2 * x ** 2 + y ** 2 + x * y + y + x

def df_dx(x, y):
    x_arg, y_arg = symbols('x y')
    d = diff(f(x_arg, y_arg), x_arg)
    #print(f'df_dx: {d}')
    l = lambdify([x_arg, y_arg], d)
    return l(x, y)

def df_dy(x, y):
    x_arg, y_arg = symbols('x y')
    d = diff(f(x_arg, y_arg), y_arg)
    #print(f'df_dy: {d}')
    l = lambdify([x_arg, y_arg], d)
    return l(x, y)

def df_dxdx(x, y):
    x_arg, y_arg = symbols('x y')
    d = diff(df_dx(x_arg, y_arg), x_arg)
    #print(f'df_dxdx: {d}')
    l = lambdify([x_arg, y_arg], d)
    return l(x, y)

def df_dxdy(x, y):
    x_arg, y_arg = symbols('x y')
    d = diff(df_dx(x_arg, y_arg), y_arg)
    #print(f'df_dxdy: {d}')
    l = lambdify([x_arg, y_arg], d)
    return l(x, y)

def df_dydy(x, y):
    x_arg, y_arg = symbols('x y')
    d = diff(df_dy(x_arg, y_arg), y_arg)
    #print(f'df_dydy: {d}')
    l = lambdify([x_arg, y_arg], d)
    return l(x, y)


if __name__ == "__main__":
    eps = 0.001
    x_k = 0
    y_k = 0
    while max(abs(df_dx(x_k, y_k)), abs(df_dy(x_k, y_k))) > eps:
        bar = -df_dx(x_k, y_k) ** 2 - df_dy(x_k, y_k) ** 2
        bar_twice = df_dxdx(x_k, y_k) * df_dx(x_k, y_k) ** 2 + 2 * df_dxdy(x_k, y_k) * df_dx(x_k, y_k) * df_dy(x_k, y_k) + df_dydy(x_k, y_k) * df_dy(x_k, y_k) ** 2
        t = -bar / bar_twice
        x_new = x_k - t * df_dx(x_k, y_k)
        y_new = y_k - t * df_dy(x_k, y_k)
        x_k, y_k = x_new, y_new
    print(x_k, y_k)
    x_anal, y_anal = -1/7, -3/7
    print(x_anal, y_anal)



