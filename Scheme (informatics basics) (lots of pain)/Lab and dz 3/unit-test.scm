(load "trace.scm")
(define-syntax test
  (syntax-rules ()
    ((_ func ans)
     (list (quote func) ans))))

(define (run-test exp)
  (let ((e (car exp)))
         (write e)
         (let ((res (eval e (interaction-environment))))
           (if (equal? res (cadr exp))
               (begin
                 (display " - ok")
                 (newline)
                 (newline)
                 #t)
               (begin
                 (display " - fail")
                 (newline)
                 (display " Expected: ") (write (cadr exp))
                 (newline)
                 (display " Returned: ") (write res)
                 (newline)
                 (newline)
                 #f)))))
(define (run-tests xs)
  (define (loop bool xs)
    (if (null? xs)
        bool
        (loop (and bool (car xs)) (cdr xs))))
  (loop #t (map run-test xs)))



