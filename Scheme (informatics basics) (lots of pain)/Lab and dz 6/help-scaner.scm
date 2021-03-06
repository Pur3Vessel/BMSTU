(load "Stream.scm")
(load "trace.scm")
(define call/cc call-with-current-continuation)
(define (check-frac str)
  (define (sign? token)
    (or (equal? token #\+) (equal? token #\-)))
  (define (number-c? token)
    (and (> token 47) (< token 58)))
  (define (scaner stream error)
    (or (equal? (peek stream) #\`)
        (if (number-c? (char->integer (next stream)))
            (scaner stream error)
            (error #f))))
  (define (start-scaner-part2 stream error)
    (if (not (member #\/ (car stream)))
        (error #f)
        (and (scaner (make-stream (cdr (member #\/ (car stream))) #\`) error)
             (scaner (make-stream (reverse (cdr (member #\/ (reverse (car stream))))) #\`) error))))
  (define (start-scaner stream error)
    (if (sign? (peek stream))
        (begin (next stream) (start-scaner-part2 stream error))
        (start-scaner-part2 stream error)))
  (let* ((eof #\`)
         (stream (make-stream str eof)))
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
       (let* ((l  str)
              (p1 (reverse (cdr (member #\/ (reverse l)))))
              (p2 (cdr (member #\/ l))))
         (if (sign? (car l))
             (if (equal? (car l) #\-)
                 (string->symbol (string-append (converter (string->number (list->string (cdr p1))) (string->number (list->string p2)) 1)
                                                (string-append "/" (converter (string->number (list->string p2)) (string->number (list->string (cdr p1))) 0))))
                 (string->symbol (string-append (converter (string->number (list->string (cdr p1))) (string->number (list->string p2)) 0)
                                                (string-append "/" (converter (string->number (list->string p2)) (string->number (list->string (cdr p1))) 0)))))
             (string->symbol (string-append (converter (string->number (list->string p1)) (string->number (list->string p2)) 0)
                                           (string-append "/" (converter (string->number (list->string p2)) (string->number (list->string p1)) 0))))))))