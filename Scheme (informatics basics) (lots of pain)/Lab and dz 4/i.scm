(define-syntax my-if
  (syntax-rules ()
    ((_ pred true false) (let ((then (delay true))
                               (else (delay false)))
                           (force (or (and pred then) else))))))
(my-if #t 1 (/ 1 0))
(my-if #f (/ 1 0) 1)

(my-if #t #f (/ 1 0))


