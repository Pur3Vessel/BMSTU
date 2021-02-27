(define call/cc call-with-current-continuation)
(define in-the-end 0)

(define (use-assertions)
  (call/cc (lambda (c)
             (set! in-the-end c))))

(define-syntax assert
  (syntax-rules ()
    ((_ pred?) (if (not pred?)
                   (begin (display "Failed: ")
                          (write (quote pred?))
                          (in-the-end))))))

(use-assertions)

(define (1/x x)
  (assert (not (zero? x)))
  (/ 1 x))
(map 1/x '(1 2 3 4 5))

(newline)

(map 1/x '(-2 -1 0 1 2))




    
    