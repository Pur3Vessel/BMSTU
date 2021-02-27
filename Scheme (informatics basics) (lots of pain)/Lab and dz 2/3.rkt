(define (string-trim-left str)
  (define (loop xs)
    (if  (not (char-whitespace? (car xs)))
         (list->string xs)
         (loop (cdr xs))))
  (loop (string->list str)))

(define (string-trim-right str)
  (define (loop xs)
    (if  (not (char-whitespace? (car xs)))
         (list->string (reverse xs))
         (loop (cdr xs))))
  (loop (reverse (string->list str))))

(define (string-trim str)
  (string-trim-right (string-trim-left str)))
                                  

(define (string-prefix? a b)
  (define (loop as bs)
    (if (> (length as) (length bs))
        (= 0 1)    
        (or (null? as)
            (and (equal? (car as) (car bs))
                 (loop (cdr as) (cdr bs))))))
  (loop (string->list a) (string->list b)))

(define (string-suffix? a b)
  (define (loop as bs)
    (and (< (length as) (length bs))
         (or (null? as)
             (and (equal? (car as) (car bs))
                  (loop (cdr as) (cdr bs))))))
  (loop (reverse (string->list a)) (reverse (string->list b))))

(define (string-infix? a b)
  (define (compare as bs)
    (or (null? as)
        (and (not  (null? bs))
             (equal? (car as) (car bs))
             (compare (cdr as) (cdr bs)))))
  (define (loop as bs)
    (and (not (null? bs))
         (or (compare as bs)
             (loop as (cdr bs)))))
  (loop (string->list a) (string->list b)))
    
        
(define (string-split str sep)
  (define (cut xs ys)
    (if (null? ys)
        xs
        (cut (cdr xs) (cdr ys))))
  (define (coincedence? xs ys)
    (or (null? ys)
        (and (not (null? xs))
             (equal? (car xs) (car ys))
             (coincedence? (cdr xs) (cdr ys)))))
  (define (loop xs sep ys)
    (cond ((null? xs) ys)
          ((coincedence? xs sep) (loop (cut xs sep) sep ys))
          (else (loop (cdr xs) sep (append ys (cons (string (car xs)) '()))))))
  (loop (string->list str) (string->list sep) '()))

(define (string-split-2 str sep)
  (define (cut xs ys)
    (if (null? ys)
        xs
        (cut (cdr xs) (cdr ys))))
  (define (coincedence? xs ys)
    (or (null? ys)
        (and (not (null? xs))
             (equal? (car xs) (car ys))
             (coincedence? (cdr xs) (cdr ys)))))
  (define (loop xs sep ys zs)
    (cond ((null? xs) (if (null? zs)
                          (reverse ys)
                          (reverse (cons (list->string zs) ys))))
          ((coincedence? xs sep) (loop (cut xs sep) sep (cons (list->string zs) ys) '()))
          (else (loop (cdr xs) sep ys (reverse (cons (car xs) zs))))))
  (loop (string->list str) (string->list sep) '() '()))


(define (string-prefix-2? a b)
  (define (loop as bs)
    (and (< (length as) (length bs))
         (or (null? as)
             (and (equal? (car as) (car bs))
                  (loop (cdr as) (cdr bs))))))
  (loop (string->list a) (string->list b)))
  
                                 
                      
        
                  
    
  


  
