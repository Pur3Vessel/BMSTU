(load "unit-test.scm")


(define (factorize exp)
  (if (and (list? (cadr exp)) (list? (caddr exp)))
  (let ((a (cadr (cadr exp)))
        (b (cadr (caddr exp))))
    (cond ((and (eq? (car exp) '+ ) (equal? (caddr (cadr exp)) 3) (equal? (caddr (caddr exp)) 3) (equal? (length exp) 3))
           (list '* (list '+ a b) (list '+ (list '- (list 'expt a 2) (list '* a b)) (list 'expt b 2))))
          ((and (eq? (car exp) '- ) (equal? (caddr (cadr exp)) 3) (equal? (caddr (caddr exp)) 3) (equal? (length exp) 3))
           (list '* (list '- a b) (list '+ (list '+ (list 'expt a 2) (list '* a b)) (list 'expt b 2))))
          ((and (eq? (car exp) '- ) (equal? (caddr (cadr exp)) 2) (equal? (caddr (caddr exp)) 2) (equal? (length exp) 3))
           (list '* (list '- a b) (list '+ a b)))
          (else exp)))
  exp))
          

(define the-tests
  (list (test (factorize '(- (expt x 2) (expt y 2))) '(* (- x y) (+ x y)))
        (test (factorize '(+ (expt (+ first 2) 3) (expt (+ second 2) 3)))
              '(* (+ (+ first 2) (+ second 2)) (+ (- (expt (+ first 2) 2) (* (+ first 2) (+ second 2))) (expt (+ second 2) 2))))
        (test (factorize '(- (expt (+ f 5) 3) (expt (+ s 5) 3)))
              '(* (- (+ f 5) (+ s 5)) (+ (+ (expt (+ f 5) 2) (* (+ f 5) (+ s 5))) (expt (+ s 5) 2))))
        (test (eval (list (list 'lambda '(x y) (factorize '(- (expt x 2) (expt y 2))))
                          1 2)
                      (interaction-environment)) -3)))
(run-tests the-tests)
        

                  