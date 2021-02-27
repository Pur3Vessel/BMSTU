(define (all? pred? xs)
  (or (null? xs)
      (and (pred? (car xs))
           (all? pred? (cdr xs)))))
(define (any? pred? xs)
  (and (not (null? xs))
       (or (pred? (car xs))
           (any? pred? (cdr xs)))))
                  
  
  