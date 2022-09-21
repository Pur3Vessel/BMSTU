(define-syntax lazy-cons
  (syntax-rules ()
    ((_ val prom) (cons val (delay prom)))))

(define (lazy-car p)
  (car p))

(define (lazy-cdr p)
  (force (cdr p)))


(define (lazy-head xs k)
  (define (loop ys xs k)
    (if (= k 0)
        ys
        (loop (append ys (cons (lazy-car xs) '())) (lazy-cdr xs) (- k 1))))
  (loop '() xs k))

(define (lazy-ref xs k)
  (car (reverse (lazy-head xs k))))

(define (naturals start)
  (lazy-cons start (naturals (+ 1 start))))

(define (lazy-factorial n)
  (define (fact N)
      (define (loop i res)
        (if (<= i N)
            (loop (+ i 1)
                  (* res i))
            res))
      (loop 1 1))
  (define (make-lazy-factorials start)
    (lazy-cons (fact start) (make-lazy-factorials (+ start 1))))
  (lazy-ref (make-lazy-factorials 0) n))

(display (lazy-head (naturals 10) 12))
(newline)

(begin
  (display (lazy-factorial 10)) (newline)
  (display (lazy-factorial 50)) (newline))
