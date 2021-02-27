(load "unit-test.scm")
(load "trace.scm")
(define (derivative exp)
  (define (cut-first  ys a)
    (if (null? a)
        ys
        (cut-first (append ys (cons (car a) '())) (cdr a))))
  (define (sum-build a b)
    (cond ((equal? a 0) b)
          ((equal? b 0) a)
          (else (list '+ a b))))
  (define (difference-build a b)
    (cond ((equal? a 0) (list '* -1 b))
          ((equal? b 0) a)
          (else (list '- a b))))
  (define (prod-build a b)
   (cond
         ((or (equal? a 0) (equal? b 0)) 0)
         ((equal? a 1) b)
         ((equal? b 1) a)
         (else (list '* a b))))
    
  (define (sum? var)
    (eq? (car var) '+))
  (define (difference? var)
    (eq? (car var) '-))
  (define (prod? var)
    (and (eq? (car var) '*) (equal? (length var) 3)))
  (define (multi-prod? var)
    (and (eq? (car var) '*) (> (length var) 3)))
  (define (var? a)
    (symbol? a))
  (define (number-e? a)
    (and (not (symbol? a)) (not (< (length a) 3)) (number? (cadr a)) (number? (caddr a))))
  (define (sin? a)
    (eq? (car a) 'sin))
  (define (cos? a)
    (eq? (car a) 'cos))
  (define (expt? a)
    (and (eq? (car a) 'expt) (var? (cadr a)) (not (eq? (cadr a) 'e))))
  (define (expot? a)
    (and (eq? (car a) 'expt) (var? (caddr a)) (not (eq? (cadr a) 'e))))
  (define (exp? a)
    (and (eq? (car a) 'exp)))
  (define (ln? a)
    (eq? (car a) 'ln))
  (define (segmentation-1? a)
    (and (eq? (car a) '/) (var? (caddr a))))
  (define (segmentation-2? a)
    (and (eq? (car a) '/) (not (var? (caddr a))) (not (number? (caddr a)))))
  (define (segmentation-rebuild ys a)
    (cond
      ((null? a) ys)
      ((number? (car a)) (segmentation-rebuild (append ys (cons (list '/ 1 (car a)) '())) (cdr a)))
      ((symbol? (car a)) (segmentation-rebuild (append ys (cons (car a) '())) (cdr a)))
      ((eq? (car (car a)) 'expt) (segmentation-rebuild (append ys (cons (list 'expt (cadr (car a)) (* -1 (caddr (car a)))) '())) (cdr a)))))
  (cond ((number? exp) 0)
        ((number-e? exp) 0)
        ((var? exp) (if (equal? (car (string->list (symbol->string exp))) #\-) -1 1))
        ((sum? exp) (sum-build (derivative (cadr exp)) (derivative (caddr exp))))
        ((prod? exp) (sum-build (prod-build (derivative (cadr exp)) (caddr exp)) (prod-build (cadr exp) (derivative (caddr exp)))))
        ((difference? exp) (difference-build (derivative (cadr exp)) (derivative (caddr exp))))
        ((sin? exp) (prod-build (derivative (cadr exp)) (list 'cos (cadr exp))))
        ((cos? exp) (prod-build (derivative (cadr exp)) (list '* -1 (list 'sin (cadr exp)))))
        ((expt? exp) (prod-build (derivative (cadr exp)) (list '* (caddr exp) (list 'expt (cadr  exp) (- (caddr exp) 1)))))
        ((expot? exp) (prod-build (derivative (caddr exp)) (list '* exp (list 'ln (cadr exp)))))
        ((exp? exp) (prod-build (derivative (cadr exp)) exp))
        ((ln? exp) (prod-build (derivative (cadr exp)) (list '/ 1 (cadr exp))))
        ((multi-prod? exp) (sum-build (prod-build (derivative (cadr exp)) (cut-first (list '*) (cdr (cdr exp))))
                                      (prod-build (cadr exp) (derivative (cut-first (list '*) (cdr (cdr exp)))))))
        ((segmentation-1? exp) (if (equal? (cadr exp) 1)
                                   (list '* -1 (list 'expt (caddr exp) -1))
                                   (list '* (cadr exp) (list '* -1 (list 'expt (caddr exp) -1)))))
        ((segmentation-2? exp) (list '* (cadr exp) (derivative (trace-ex (segmentation-rebuild '() (caddr exp))))))
        (else 'rabotay_dalshe)))

3/(2*x^2) => 3 * x^(-2) * (1 / 2)
(define the-tests (list
                   (test (derivative 2) 0)
                   (test (derivative 'x) 1)
                   (test (derivative '-x) -1)
                   (test (derivative '(* 1 x)) 1)
                   (test (derivative '(* -1 x)) -1)
                   (test (derivative '(* -4 x)) -4)
                   (test (derivative '(* 10 x)) 10)
                   (test (derivative '(- (* 2 x) 3)) 2)
                   (test (derivative '(expt x 10)) '(* 10 (expt x 9)))
                   (test (derivative '(* 2 (expt x 5))) '(* 2 (* 5 (expt x 4))))
                   (test (derivative '(expt x -2)) '(* -2 (expt x -3)))
                   (test (derivative '(expt 5 x)) '(* (expt 5 x) (ln 5)))
                   (test (derivative '(cos x)) '(* -1 (sin x)))
                   (test (derivative '(sin x)) '(cos x))
                   (test (derivative '(exp x)) '(exp x))
                   (test (derivative '(* 2 (exp x))) '(* 2 (exp x)))
                   (test (derivative '(* 2 (exp (* 2 x)))) '(* 2 (* 2 (exp (* 2 x)))))
                   (test (derivative '(ln x)) '(/ 1 x))
                   (test (derivative '(* 3 (ln x))) '(* 3 (/ 1 x)))
                   (test (derivative '(+ (expt x 3) (expt x 2))) '(+ (* 3 (expt x 2)) (* 2 (expt x 1))))
                   (test (derivative '(- (* 2 (expt x 3)) (* 2 (expt x 2)))) '(- (* 2 (* 3 (expt x 2))) (* 2 (* 2 (expt x 1)))))
                   (test (derivative '(/ 3 x)) '(* 3 (* -1 (expt x -1))))
                   (test (derivative '(/ 3 (* 2 (expt x 2)))) '(* 3 (* (/ 1 2) (* -2 (expt x -3)))))
                   (test (derivative '(* 2 (sin x) (cos x))) '(* 2 (+ (* (cos x) (cos x)) (* (sin x) (* -1 (sin x))))))
                   (test (derivative '(* 2 (exp x) (sin x) (cos x))) '(* 2 (+ (* (exp x) (* (sin x) (cos x))) (* (exp x) (+ (* (cos x) (cos x)) (* (sin x) (* -1 (sin x))))))))
                   (test (derivative '(sin (* 2 x))) '(* 2 (cos (* 2 x))))
                   (test (derivative '(sin (ln (expt x 2)))) '(* (* (* 2 (expt x 1)) (/ 1 (expt x 2))) (cos (ln (expt x 2)))))
                   (test (derivative '(cos (* 2 (expt x 2)))) '(* (* 2 (* 2 (expt x 1))) (* -1 (sin (* 2 (expt x 2))))))
                   (test (derivative '(+ (sin (* 2 x)) (cos (* 2 (expt x 2))))) '(+  (* 2 (cos (* 2 x))) (* (* 2 (* 2 (expt x 1))) (* -1 (sin (* 2 (expt x 2)))))))
                   (test (derivative '(* (sin (* 2 x)) (cos (* 2 (expt x 2))))) '(+ (* (* 2 (cos (* 2 x))) (cos (* 2 (expt x 2)))) (* (sin (* 2 x)) (* (* 2 (* 2 (expt x 1))) (* -1 (sin (* 2 (expt x 2))))))))))

(run-tests the-tests)
