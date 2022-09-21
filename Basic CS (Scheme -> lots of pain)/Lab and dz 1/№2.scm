
(define (quadratic a b c)
  (if (> (- (* b b) (* 4 a c)) 0)
      (list (/ (+ (* -1 b) (sqrt (- (* b b) (* 4 a c)))) (* 2 a)) (/ (- (* -1 b) (sqrt (- (* b b) (* 4 a c)))) (* 2 a)))
      (if (= (- (* b b) (* 4 a c)) 0)
          (list (/ (* -1 b) (* 2 a)))
          (list ))))


