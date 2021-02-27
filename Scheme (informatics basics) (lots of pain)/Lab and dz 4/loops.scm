(display "When and Unless:")
(newline)
(define-syntax when
  (syntax-rules ()
    ((_ pred? . exps) (if pred? (begin . exps)))))
(define-syntax unless
  (syntax-rules ()
    ((_ pred? . exps) (if (not pred?) (begin . exps)))))
(define x 1)
(when (> x 0) (display "x > 0") (newline))
(unless (= x 0) (display "x != 0") (newline))
(display "For:")
(newline)
(define-syntax for
  (syntax-rules (in as)
    ((_ x in xs . exps) (for-each (lambda (x) (begin . exps)) xs))
    ((_ xs as x . exps) (for-each (lambda (x) (begin . exps)) xs))))

(for i in '(1 2 3)
  (for j in '(4 5 6)
    (display (list i j))
    (newline)))

(newline)
(display "While:")
(newline)

(define-syntax while
  (syntax-rules ()
    ((_ pred . exps) (letrec ((repeat (lambda () 
                                        (if pred
                                            (begin (begin . exps) (repeat))))))
                       (repeat)))))



(let ((p 0)
      (q 0))
  (while (< p 3)
         (set! q 0)
         (while (< q 3)
                (display (list p q))
                (newline)
                (set! q (+ q 1)))
         (set! p (+ p 1))))

(newline)
(display "Repeat:")
(newline)

(define-syntax repeat
  (syntax-rules (until)
    ((_ (exps ...) until pred) (letrec ((repeat (lambda ()
                                                  (begin exps ...)
                                                  (if (not pred)
                                                      (repeat)))))
                                 (repeat)))))
                                                  
(let ((i 0)
      (j 0))
  (repeat ((set! j 0)
           (repeat ((display (list i j))
                    (set! j (+ j 1)))
                   until (= j 3))
           (set! i (+ i 1))
           (newline))
          until (= i 3)))

(newline)
(display "Cout:")
(newline)
(define-syntax cout
  (syntax-rules (<< endl)
    ((_ ) (begin))
    ((_ << endl) (newline))
    ((_ << endl . exps) (begin (newline) (cout . exps)))
    ((_ << exp . exps) (begin (display exp) (cout . exps)))))

(cout  << "a = " << 1 << endl << "b = " << 2 << endl)
                          
                   
