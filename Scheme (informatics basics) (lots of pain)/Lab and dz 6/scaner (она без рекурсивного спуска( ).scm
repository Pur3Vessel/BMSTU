(load "Stream.scm")
(load "trace.scm")
(define call/cc call-with-current-continuation)
; Для check и scan:
; <frac> :: = <signed_number> / <unsigned_number>
; <signed_number> :: = <sign> <unsigned_number>
; <unsigned_number> :: = digit <unsigned_number> | e
; <sign> :: = + | - | e

(define (check-frac str)
  (define (sign? token)
    (or (equal? token #\+) (equal? token #\-)))
  (define (number-c? token)
    (and (> token 47) (< token 58)))
  (define (scaner stream error void)
    (if void
        (if (equal? (peek stream) #\♂)
            (error #f)
            (scaner stream error #f))
    (or (equal? (peek stream) #\♂)
        (if (number-c? (char->integer (next stream)))
            (scaner stream error #f)
            (error #f)))))
  (define (start-scaner-part2 stream error)
    (if (not (member #\/ (car stream)))
        (error #f)
        (and (scaner (make-stream (cdr (member #\/ (car stream))) #\♂) error #t)
             (scaner (make-stream (reverse (cdr (member #\/ (reverse (car stream))))) #\♂) error #t))))
  (define (start-scaner stream error)
    (if (sign? (peek stream))
        (begin (next stream) (start-scaner-part2 stream error))
        (start-scaner-part2 stream error)))
  (let* ((eof #\♂)
         (stream (make-stream (string->list str) eof)))
    (call/cc
     (lambda (error)
       (start-scaner stream error)))))


(define (scan-frac str)
  (define (sign? token)
    (or (equal? token #\+) (equal? token #\-)))
  (define (converter num1 num2 sign)
    (if (= sign 0)
        (number->string (quotient num1 (gcd num1 num2)))
        (number->string (* -1 (quotient num1 (gcd num1 num2))))))
  (and (check-frac str)
       (let* ((l (string->list str))
              (p1 (reverse (cdr (member #\/ (reverse l)))))
              (p2 (cdr (member #\/ l))))
         (display "Обработка произошла - ")
         (if (sign? (car l))
             (if (equal? (car l) #\-)
                 (string->symbol (string-append (converter (string->number (list->string (cdr p1))) (string->number (list->string p2)) 1)
                                                (string-append "/" (converter (string->number (list->string p2)) (string->number (list->string (cdr p1))) 0))))
                 (string->symbol (string-append (converter (string->number (list->string (cdr p1))) (string->number (list->string p2)) 0)
                                                (string-append "/" (converter (string->number (list->string p2)) (string->number (list->string (cdr p1))) 0)))))
             (string->symbol (string-append (converter (string->number (list->string p1)) (string->number (list->string p2)) 0)
                                            (string-append "/" (converter (string->number (list->string p2)) (string->number (list->string p1)) 0))))))))
(display "Check:")
(newline)
(check-frac "110/111") 
(check-frac "-4/3")    
(check-frac "+5/10")  
(check-frac "5.0/10")  
(check-frac "FF/10")
(display "Scan:")
(newline)
(scan-frac "110/111")  
(scan-frac "-4/3")     
(scan-frac "+5/10")    
(scan-frac "5.0/10")   
(scan-frac "FF/10")    

(newline)               
(check-frac "/")

(check-frac "/1")

(check-frac "-/")       
       
       

