(define-syntax trace-ex
  (syntax-rules ()
    ((_ expression)
     (begin
       (newline)
       (newline)
       (display 'expression)
       (display " => ")
       (let ((exp expression))
         (display exp)
         (newline)
         (newline)
         exp)))))
     