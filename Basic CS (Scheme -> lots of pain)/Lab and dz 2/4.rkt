(define (make-multi-vector sizes . fill)
  (let ((m (make-vector (+ 1 (apply * sizes)))))
    (if (not (null? fill))
        (vector-fill! m (car fill)))
    (vector-set! m 0 sizes)
    m))

(define (multi-vector? m)
  (and (vector? m)
       (pair? (vector-ref m 0))
       (equal? (vector-length m) (+ 1 (apply * (vector-ref m 0))))))

(define (multi-vector-ref m indices)
  (define (get-index m indices)
    (define (loop all indices index)
      (if (pair? all)
          (loop (cdr all) (cdr indices) (+ index (* (car indices) (apply * all))))
          (+ index (car indices))))
    (loop (cdr (reverse (vector-ref m 0))) indices 1))
  (vector-ref m (get-index m indices)))

(define (multi-vector-set! m indices x)
  (define (get-index m indices)
    (define (loop all indices index)
      (if (pair? all)
          (loop (cdr all) (cdr indices) (+ index (* (car indices) (apply * all))))
          (+ index (car indices))))
    (loop (cdr (reverse (vector-ref m 0))) indices 1))
  (vector-set! m (get-index m indices) x))
          


