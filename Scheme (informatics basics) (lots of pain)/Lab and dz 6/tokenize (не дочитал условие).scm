(load "Stream.scm")
(define call/cc call-with-current-continuation)
; <Start> :: = <Ex> <Expr>
; <Expr> :: = <Ex> <Expr> | e
; <Ex> :: = <Number> | <Variable> | <Sign>
; <Number> :: = digit <Number> | e
; <Variable> :: = letter <Variable> | e
; <Sign> :: = + | - | / | * | ^ | ( | )
(define (tokenize str)
  (define (number-c? token)
    (and (> (char->integer token) 47) (< (char->integer token) 58)))
  (define (operator? token)
    (or (equal? token #\+)  (equal? token #\/) (equal? token #\-) (equal? token #\^) (equal? token #\*)))
  (define (bracket? token)
    (or (equal? token #\() (equal? token #\))))
  (define (variable? token)
    (and (> (char->integer token) 96)
         (< (char->integer token) 123)))
  (define (var-scaner stream tokens variable error)
    (let ((c-s (peek stream)))
      (cond
        ((variable? c-s) (next stream) (var-scaner stream tokens (string-append variable (make-string 1 c-s)) error))
        ((or (bracket? c-s) (operator? c-s) (number-c? c-s) (char-whitespace? c-s) (equal? c-s #\♂))
         (scaner stream (append tokens (cons (string->symbol variable) '())) error))
        (else (error #f)))))
  (define (number-scaner stream tokens number error)
    (let ((c-s (peek stream)))
      (cond
        ((number-c? c-s) (next stream) (number-scaner stream tokens (string-append number (make-string 1 c-s)) error))
        ((or (bracket? c-s) (operator? c-s) (variable? c-s) (char-whitespace? c-s) (equal? c-s #\♂))
         (scaner stream (append tokens (cons (string->number number) '())) error))
        (else (error #f)))))
  (define (scaner stream tokens error)
    (let ((c-s (next stream)))
      (cond
        ((equal? c-s #\♂) tokens)
        ((operator? c-s) (scaner stream (append tokens (cons (string->symbol (make-string 1 c-s)) '())) error))
        ((bracket? c-s) (scaner stream (append tokens (cons (make-string 1 c-s) '())) error))
        ((variable? c-s) (var-scaner stream tokens (make-string 1 c-s) error))
        ((number-c? c-s) (number-scaner stream tokens (make-string 1 c-s) error))
        ((char-whitespace? c-s) (scaner stream tokens error))
        (else (error #f)))))
  (let* ((eof #\♂)
         (stream (make-stream (string->list str) eof)))
    (call/cc
     (lambda (error)
       (scaner stream '() error)))))

;(tokenize "1")


;(tokenize "-a")
  

;(tokenize "-a + b * x^2 + dy")


;(tokenize "(a - 1)/(b + 1)")
