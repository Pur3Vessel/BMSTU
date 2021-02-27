(define (read-words path)
  (define (make-list ans-list string)
    (let ((symbol (read-char)))
      (cond
        ((eof-object? symbol) ans-list)
        ((and (char-whitespace? symbol) (not (null? (string->list string)))) (make-list (append ans-list (cons string '())) ""))
        ((and (char-whitespace? symbol) (null? (string->list string))) (make-list ans-list string))
        ((char? symbol) (make-list ans-list (list->string (append (string->list string) (cons symbol '()))))))))
  (with-input-from-file path
    (lambda ()
      (make-list '() ""))))

(display (read-words "readw.txt"))