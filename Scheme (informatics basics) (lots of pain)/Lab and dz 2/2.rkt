(define (any? x xs)
    (and (not (null? xs))
         (or (equal? x (car xs))
             (any? x (cdr xs)))))

(define (list->set xs)
  (define (loop xs ys)
    (cond ((null? xs) (reverse ys))
          ((any? (car xs) ys) (loop (cdr xs) ys))
          (else (loop (cdr xs) (append ys (cons (car xs) '()))))))
  (loop xs '()))

(define (set? xs)
  (or (null? xs)
      (and (not (any? (car xs) (cdr xs)))
           (set? (cdr xs)))))

(define (union xs ys)
  (cond ((null? xs) ys)
        ((any? (car xs) ys) (union (cdr xs) ys))
        (else (union (cdr xs) (append ys (cons (car xs) '()))))))

(define (intersection xs ys)
  (define (loop xs ys zs)
    (cond ((null? xs) zs)
          ((any? (car xs) ys) (loop (cdr xs) ys (append zs (cons (car xs) '()))))
          (else (loop (cdr xs) ys zs))))
  (loop xs ys '()))

(define (difference xs ys)
  (define (loop xs ys zs)
    (cond ((null? xs) zs)
          ((any? (car xs) ys) (loop (cdr xs) ys zs))
          (else (loop (cdr xs) ys (append zs (cons (car xs) '()))))))
  (loop xs ys '()))

(define (sym-dif xs ys)
  (difference (union xs ys) (intersection xs ys)))

(define (set-eq? xs ys)
  (define (loop xs ys)
        (or (null? xs)
            (and (any? (car xs) ys)
                 (loop (cdr xs) ys))))
  (or (and (null? xs) (null? ys))
      (and (not (or (null? xs) (null? ys)))
           (if (>= (length xs) (length ys))
               (loop xs ys)
               (loop ys xs)))))


           
          
           
    
  
           