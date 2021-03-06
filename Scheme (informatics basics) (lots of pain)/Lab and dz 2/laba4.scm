(define (interprise e xs)
  (define (loop e xs ys)
    (cond ((null? xs) ys)
          ((null? (cdr xs)) (append ys xs))
          (else (loop e (cdr xs) (append ys (cons (car xs) '()) (cons e '()))))))
  (loop e xs '()))
