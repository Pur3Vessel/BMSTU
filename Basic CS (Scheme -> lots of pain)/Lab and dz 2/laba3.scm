(define (iterate f x n)
  (define (loop f x n xs)
    (if (= n 1)
        xs
        (loop f (f x) (- n 1) (append xs (cons (f x) '())))))
  (if (= n 0)
      '()
      (loop f x n (cons x '()))))
    
  
      