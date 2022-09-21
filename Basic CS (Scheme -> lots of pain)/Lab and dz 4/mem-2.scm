(define memoized-factorial
  (let ((memo '()))
    (lambda (n)
      (if (assoc n memo)
          (cadr (assoc n memo))
          (let ((res (if (= n 1)
                         1
                         (* n (memoized-factorial (- n 1))))))
          (set! memo 
                (cons (list n res) memo))
                res))))) 
(display (memoized-factorial 10)) (newline)
(display (memoized-factorial 50)) (newline)