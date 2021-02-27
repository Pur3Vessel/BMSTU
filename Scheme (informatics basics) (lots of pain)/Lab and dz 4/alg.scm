(define (make-one-symbol . elements)
  (define (loop ys xs)
    (if (null? xs)
        (string->symbol ys)
        (loop (string-append ys (car xs)) (cdr xs))))
  (loop "" elements))

(define (my-element? x xs)
  (and (not (null? xs))
       (or (equal? x (car xs))
           (my-element? x (cdr xs)))))

(define-syntax create-pred
  (syntax-rules ()
    ((_ name box ...) (begin (eval (quote (define name (list (quote box) ...))) (interaction-environment))
                             (eval (list (quote define) (list (make-one-symbol (symbol->string 'name) "?") (quote arg))
                                         (quote (and (list? arg) (my-element? (car arg) name)))) (interaction-environment))))))

(define-syntax create-list
  (syntax-rules ()
    ((_ box val ...) (eval (quote (define (box val ...) (list (quote box) val ...))) (interaction-environment)))))

(define-syntax define-data
  (syntax-rules ()
    ((_ name ((box val ...) ...))
     (begin
       (create-pred name box ...)
       (create-list box val ...) ...))))

(define (create-switch exp box-rule)
  (define (assoc-maker exp box ys)
    (if (null? exp)
        ys
        (if (symbol? (car exp))
            (if (equal? (car exp) (car box))
                (assoc-maker (cdr exp) (cdr box) ys)
                #f)
            (assoc-maker (cdr exp) (cdr box) (cons (list (car box) (car exp)) ys)))))
  (define (loop box-rule)
    (if (null? box-rule)
        #f
        (if (assoc-maker exp  (car (car box-rule)) '())
            (eval `(let ,(assoc-maker exp (car (car box-rule)) '()) ,(cadr (car box-rule))) (interaction-environment))
            (loop (cdr box-rule)))))
  (loop box-rule))

(define-syntax match
  (syntax-rules ()
    ((_ exp (box rule) ...) (create-switch exp '((box rule) ...)))))

; Определяем тип
;
(define-data figure ((square a)
                     (rectangle a b)
                     (triangle a b c)
                     (circle r)))

; Определяем значения типа
;
(define s (square 10))
(define r (rectangle 10 20))
(define t (triangle 10 20 30))
(define c (circle 10))

; Пусть определение алгебраического типа вводит
; не только конструкторы, но и предикат этого типа:
;
(and (figure? s)
     (figure? r)
     (figure? t)
     (figure? c))

(define pi (acos -1)) ; Для окружности
  
(define (perim f)
  (match f 
    ((square a)       (* 4 a))
    ((rectangle a b)  (* 2 (+ a b)))
    ((triangle a b c) (+ a b c))
    ((circle r)       (* 2 pi r))))
  
(perim s) 
(perim r) 
(perim t)

(((call-with-current-continuation
   (lambda (c) c))
  (lambda (x) x))
 'hello)

; Код из ачивки: функция call/cc берет контекст c (в данном случае контекстом является символ 'hello) и сразу же возвращает его.
; Затем следует вызов безымянной функции (она просто возвращает свой аргумент), и ей передается этот контекст в качестве аргумента