(define (simplify exp)
  (define (loop ys exp)
    (cond
      ((number? exp) exp)
      ((null? exp) (if (or (equal? ys 0) (not (equal? (length ys) 2)))
                       ys
                       (cadr ys)))
      ((and (not (null? ys)) (eq? (car ys) '+) (equal? (car exp) 0)) (loop ys (cdr exp)))
      ((and (not (null? ys)) (eq? (car ys) '*) (equal? (car exp) 1)) (loop ys (cdr exp)))
      ((and (not (null? ys)) (eq? (car ys) '*) (equal? (car exp) 0)) (loop 0 '() ))
      ((list? (car exp)) (loop (append ys (cons (loop '() (car exp)) '())) (cdr exp)))
      ((null? exp) (if (equal? (length ys) 2)
                       (cadr ys)
                       ys))
      (else (loop (append ys (cons (car exp) '())) (cdr exp)))))
  (let ((a (loop '() exp)))
    (if (equal? exp a)
        a
        (simplify a))))

(simplify '(+ 1 0))
(simplify '(* 1 8))
(simplify '(* 1 2 3 4 0))
(simplify '(+ 0 7 6 '(* 1 8) '(+ 6 7 0)))

    

                                        