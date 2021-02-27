(define (make-one-symbol . elements)
  (define (loop ys xs)
    (if (null? xs)
        (string->symbol ys)
        (loop (string-append ys (car xs)) (cdr xs))))
  (loop "" elements))

(define-syntax create-assoc
  (syntax-rules ()
    ((_ (last-field)) (list (list 'list ''last-field (make-one-symbol (symbol->string 'last-field) "mark"))))
    ((_ (one-field another-fields ...)) (append (list (list 'list ''one-field (make-one-symbol (symbol->string 'one-field) "mark"))) (create-assoc (another-fields ...))))
    ((_ name (box ...)) (append  (quote ('name)) (create-assoc (box ...))))))
   

(define-syntax create-maker
  (syntax-rules ()
    ((_ name (box ...))
     (eval (list (quote define) (list (make-one-symbol "make-" (symbol->string 'name)) (make-one-symbol (symbol->string 'box) "mark") ...)
                 (append (quote (list)) (create-assoc name (box ...)))) (interaction-environment)))))
(define-syntax create-pred
  (syntax-rules ()
    ((_ name) (eval (list (quote define) (list (make-one-symbol (symbol->string 'name) "?") (quote arg))
                          (quote (and (list? arg) (eq? (car arg) 'name)))) (interaction-environment)))))
(define-syntax ref-definition
  (syntax-rules ()
    ((_ name one-field) (eval (list (quote define) (list (make-one-symbol (symbol->string 'name) "-" (symbol->string 'one-field)) (quote arg))
                                    (quote (cadr (assoc 'one-field (cdr arg))))) (interaction-environment)))))
(define-syntax create-ref
  (syntax-rules ()
    ((_ name (last-field)) (ref-definition name last-field))
    ((_ name (one-field another-fields ...))
     (begin
       (ref-definition name one-field)
       (create-ref name (another-fields ...))))))
(define-syntax set!-definition
  (syntax-rules ()
    ((_ name one-field) (eval (list (quote define) (list (make-one-symbol "set-" (symbol->string 'name) "-" (symbol->string 'one-field) "!") (quote arg) (quote value))
                                    (quote (set-car! (cdr (assoc 'one-field (cdr arg))) value))) (interaction-environment)))))
(define-syntax create-set!
  (syntax-rules ()
    ((_ name (last-field)) (set!-definition name last-field))
    ((_ name (one-field another-fields ...))
     (begin
       (set!-definition name one-field)
       (create-set! name (another-fields ...))))))



(define-syntax define-struct
  (syntax-rules ()
    ((_ name (box ...))
     (begin
       (create-maker name (box ...))
       (create-pred name)
       (create-ref name (box ...))
       (create-set! name (box ...))))))

(define-struct pos (row col))
(define p (make-pos 1 2))
(pos? p)
(pos-row p)
(pos-col p)
(set-pos-row! p 3)
(set-pos-col! p 4)
(pos-row p)
(pos-col p)


