(define (trib n)
  (cond ((<= n 1) 0)
        ((= n 2) 1)
        (else (+ (trib (- n 1)) (trib (- n 2)) (trib (- n 3))))))

(define mem-trib
  (let ((memo '()))
    (lambda (n)
      (if (assoc n memo)
          (cadr (assoc n memo))
          (let ((res (cond ((<= n 1) 0)
                           ((= n 2) 1)
                           (else (+ (mem-trib (- n 1))
                                    (mem-trib (- n 2))
                                    (mem-trib (- n 3)))))))
            (set! memo (cons (list n res) memo))
            res)))))
            
         
(mem-trib 200)
(newline)
(display "R")
(newline)
(trib 200)   