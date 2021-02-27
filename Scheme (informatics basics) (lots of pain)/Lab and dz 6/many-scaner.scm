(load "Stream.scm")
(load "help-scaner.scm")
(load "trace.scm")
(define call/cc call-with-current-continuation)
; <start> :: = <space_syms> <frac> <fracs> <space_syms>
; <fracs> :: = <space_syms> <frac> <fracs> | e
; <frac> :: = <signed_number> / <unsigned_number>
; <signed_number> :: = <sign> <unsigned_number>
; <unsigned_number> :: = digit <unsigned_number> | e
; <sign> :: = + | - | e
; <space_syms> :: = <space> <space_syms> | e
; <space> :: = tab | space | newline 

(define (scan-many-fracs str)
  (define (make-fracs-line fracs ans)
    (cond
      ((null? fracs) (if (null? ans)
                         (check-frac "1")
                         ans))
                         
      (else (and (check-frac (car fracs)) (make-fracs-line (cdr fracs) (append ans (cons (scan-frac (car fracs)) '())))))))
  (define (fracs-scaner stream fracs frac_bufer)
    (let ((c-s (next stream)))
      (cond
        ((equal? c-s #\♂) (if (null? frac_bufer)
                              (make-fracs-line fracs '())
                              (make-fracs-line (reverse (cons frac_bufer (reverse fracs))) '())))
        ((char-whitespace? c-s) (if (null? frac_bufer)
                                    (fracs-scaner stream fracs frac_bufer)
                                    (fracs-scaner stream (reverse (cons frac_bufer (reverse fracs))) '())))
        (else (fracs-scaner stream fracs (append frac_bufer (cons c-s '())))))))
      
  (let* ((eof #\♂)
         (stream (make-stream (string->list str) eof)))
    (fracs-scaner stream '() '())))
    
(scan-many-fracs
 "\t1/2 1/3\n\n10/8")  
(scan-many-fracs
"\t1/2 1/3\n\n2/-5")  

