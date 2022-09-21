(define (my-range a b d)
  (define (loop a b d xs)
    (if (>= a b)
        xs
        (loop (+ a d) b d (append xs (cons a '())))))
  (loop a b d '()))

(define (my-element? x xs)
  (and (not (null? xs))
       (or (equal? x (car xs))
           (my-element? x (cdr xs)))))

(define (my-filter? pred? xs)
  (define (loop pred? xs ys)
    (cond ((null? xs) ys)
          ((pred? (car xs)) (loop pred? (cdr xs) (append ys (cons (car xs) '()))))
          (else (loop pred? (cdr xs) ys))))
  (loop pred? xs '()))


(define (my-flatten xs)
  (cond ((null? xs) '())
        ((not (list? (car xs))) (cons (car xs) (my-flatten (cdr xs))))
        (else (append (my-flatten (car xs)) (my-flatten (cdr xs))))))

(define (my-fold-left op xs)
   (define (loop op ans xs)
     (if (null? xs)
         ans
         (loop op (op ans (car xs)) (cdr xs))))
  (loop op (car xs) (cdr xs)))

(define (my-fold-right op xs)
  (define (loop op ans xs)
    (if (null? xs)
        ans
        (loop op (op (car (reverse xs)) ans) (reverse (cdr (reverse xs))))))
  (loop op (car (reverse xs)) (reverse (cdr (reverse xs)))))

(define (rubles n)
  (cond ((and (= (remainder n 10) 1) (not (= (remainder n 100) 11))) (cons n (cons "рубль" '())))
        ((and (or (= (remainder n 10) 2) (= (remainder n 10) 3) (= (remainder n 10) 4)) (not (or (= (remainder n 100) 12) (= (remainder n 100) 13) (= (remainder n 100) 14)))  (cons n (cons "рубля" '()))))
        (else (cons n (cons "рублей" '())))))
        
  
  
  

          
          
   
 
  


