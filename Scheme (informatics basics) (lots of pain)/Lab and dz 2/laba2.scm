(define (delete pred? xs)
  (define (loop pred? xs ys)
    (cond ((null? xs) ys)
          ((pred? (car xs)) (loop pred? (cdr xs) ys))
          (else (loop pred? (cdr xs) (append ys (cons (car xs) '()))))))
  (loop pred? xs '()))
      