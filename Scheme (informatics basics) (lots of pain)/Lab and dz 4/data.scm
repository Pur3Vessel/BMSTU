(load "trace.scm")


(define (save-data data path)
  (with-output-to-file path
    (lambda ()
      (write data)
      (newline))))
(define (load-data path)
  (with-input-from-file path
    (lambda ()
      (read))))
                     
                  

;(save-data "hello" "Data_x")
;(load-data "Data_x")

(define (string-num path)
  (define (count-string count string)
    (let ((symbol (read-char)))
      ;(display string)
      ;(display "-")
      ;(display count)
      ;(newline)
      (cond
        ((eof-object? symbol) count)
        ((and (equal? symbol #\newline) (null? string)) (count-string count string))
        ((and (equal? symbol #\newline) (not (null? string))) (count-string (+ 1 count) '()))
        ((char-whitespace? symbol) (count-string count string))
        (else (count-string count (cons symbol string))))))
  (with-input-from-file path
    (lambda ()
      (count-string 0 '()))))


  
(string-num "assert.scm")
(string-num "mem.scm")
(string-num "i.scm")

(save-data '(1 2 3 4) "1.txt")
(apply * (load-data "1.txt"))

