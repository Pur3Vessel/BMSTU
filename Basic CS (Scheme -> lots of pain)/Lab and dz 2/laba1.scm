(define (count x xs)
  (cond ((null? xs) 0)
        ((equal? (car xs) x) (+ 1 (count x (cdr xs))))
        (else (count x (cdr xs)))))

    
         
    
    

  