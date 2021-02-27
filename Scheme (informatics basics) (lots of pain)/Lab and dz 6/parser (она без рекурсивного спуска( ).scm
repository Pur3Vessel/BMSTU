(define call/cc call-with-current-continuation)
(load "trace.scm")
(load "Stream.scm")

(define (parse tokens)
  (define (make-to-end list ans)
    (if (eq? (car list) 'end)
        ans
        (make-to-end (cdr list) (append ans (cons (car list) '())))))
  (define (skip-to-end list)
    (if (eq? (car list) 'end)
        (cdr list)
        (skip-to-end (cdr list))))
  (define (make-to-if list ans if-depth error)
    (cond
      ((null? list) (error #f))
      ((and (= if-depth 0) (eq? (car list) 'endif)) ans)
      ((eq? (car list) 'endif) (make-to-if (cdr list) (append ans (cons (car list) '())) (- if-depth 1) error))
      ((eq? (car list) 'if) (make-to-if (cdr list) (append ans (cons (car list) '())) (+ if-depth 1) error))
      (else (make-to-if (cdr list) (append ans (cons (car list) '())) if-depth error))))
  (define (skip-to-if list if-depth error)
    (cond
      ((null? list) (error #f))
      ((and (= if-depth 0) (eq? (car list) 'endif)) (cdr list))
      ((eq? (car list) 'endif) (skip-to-if (cdr list) (- if-depth 1) error))
      ((eq? (car list) 'if) (skip-to-if (cdr list) (+ if-depth 1) error))
      (else (skip-to-if (cdr list) if-depth error))))
  (define (body-parser body tree error)
    (cond
      ((null? body) tree)
      ((eq? (car body) 'endif) (error #f))
      ((eq? (car body) 'if) (body-parser (skip-to-if (cdr body) 0 error) (append tree (cons (list 'if (body-parser (make-to-if (cdr body) '() 0 error) '() error)) '())) error))
      (else (body-parser (cdr body) (append tree (cons (car body) '())) error))))
  (define (art-parser arts tree error)
    (cond
      ((null? arts) tree)
      ((eq? (car arts) 'define) (art-parser (skip-to-end arts) (append tree (cons (list (cadr arts) (body-parser (make-to-end (cddr arts) '()) '() error)) '())) error))))     
  (define (art-anal arts error)
    (if (not (eq? (car arts) 'define))
        (error #f)
        (art-parser arts '() error)))
  (define (separator tokens bufer define-mod error)
    (cond
      ((null? tokens) (if (= define-mod 1)
                          (error #f)
                          (cons '() (cons (body-parser bufer '() error) '()))))
      ((eq? (car tokens) 'define) (if (or (null? (cdr tokens)) (eq? (cadr tokens) 'end) (eq? (cadr tokens) 'endif) (eq? (cadr tokens) 'if) (not (symbol? (cadr tokens))) (= define-mod 1))
                                      (error #f)
                                      (separator (cdr tokens) (append bufer (cons (car tokens) '())) 1 error)))
      ((eq? (car tokens) 'end) (cond
                                 ((= define-mod 0) (error #f))
                                 ((null? (cdr tokens)) (cons (art-anal (append bufer (cons (car tokens) '())) error) (cons '() '())))
                                 ((eq? (cadr tokens) 'define) (separator (cdr tokens) (append bufer (cons (car tokens) '())) 0 error))
                                 (else (cons (art-anal (append bufer (cons (car tokens) '())) error) (cons (body-parser (cdr tokens) '() error) '())))))
      ((= define-mod 1) (separator (cdr tokens) (append bufer (cons (car tokens) '())) 1 error))
      (else (separator (cdr tokens) (append bufer (cons (car tokens) '())) 0 error))))
  (call/cc
   (lambda (error)
     (separator (vector->list tokens) '() 0 error))))
  
    
    
