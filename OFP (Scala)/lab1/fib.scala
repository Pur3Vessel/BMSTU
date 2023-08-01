val fib_tail: (Int, Int => Boolean, Int, Int) => List[Int] = 
    (n, pred, a, b) =>  if (a > n) List() else if (pred(a)) a :: fib_tail(n, pred, b, a + b) else fib_tail(n, pred, b, a + b)

val fib: (Int, Int => Boolean) => List[Int] = (n, pred) => {
    fib_tail(n, pred, 0, 1)
}



