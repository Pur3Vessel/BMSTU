(load "tokenize.scm")
(load "trace.scm")
(define (parse ex)
  (define eof #\♂)
  (define (expr stream ans error)
    (let ((c-s (peek stream)))
      (cond
        ((equal? c-s eof) ans)
        ((eq? c-s '+) (next stream) (expr stream (list ans '+ (term stream (factor stream error) error)) error))
        ((eq? c-s '-) (next stream) (expr stream (list ans '- (term stream (factor stream error) error)) error))
        ((and (not (equal? c-s ")")) (not (equal? c-s eof))) (error #f))
        (else ans))))
  (define (term stream ans error)
    (let ((c-s (peek stream)))
      (cond
        ((equal? c-s eof) ans)
        ((eq? c-s '/) (next stream) (term stream (list ans '/ (factor stream error)) error))
        ((eq? c-s '*) (next stream) (term stream (list ans '* (factor stream error)) error))
        (else ans))))
  (define (factor stream error)
    (let ((ans (power stream error))
          (c-s (peek stream)))
      (cond
        ((equal? c-s eof) ans)
        ((eq? c-s '^) (next stream) (list ans '^ (factor stream error)))
        (else ans))))
  (define (power stream error)
    (let ((c-s (next stream)))
      (cond
        ((equal? c-s eof) (error #f))
        ((or (number? c-s) (symbol? c-s)) c-s)
        ((eq? c-s '-) (list '- (power stream error)))
        ((or (eq? c-s '+) (eq? c-s '/) (eq? c-s '^) (eq? c-s '*)) (error #f))
        ((equal? c-s "(") (let ((ans (expr stream (term stream (factor stream error) error) error)))
                            (if (and (not (equal? (peek stream) eof)) (equal? (next stream) ")"))
                                ans
                                (error #f))))
        (else (display "3") (error #f)))))
  (call/cc
   (lambda (error)
     (let* 
         ((stream (make-stream ex eof))
          (ans (term stream (factor stream error) error)))
       (expr stream ans error)))))

; Ассоциативность левая
;
;(parse (tokenize "a/b/c/d"))


; Ассоциативность правая
;
;(parse (tokenize "a^b^c^d"))


; Порядок вычислений задан скобками
;
;(parse (tokenize "a/(b/c)"))


; Порядок вычислений определен только
; приоритетом операций
;
;(parse (tokenize "a + b/c^2 - d"))
