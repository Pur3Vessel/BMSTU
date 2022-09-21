(Define (Day-of-week x y z)
(remainder (- (+ x (quotient (* 31 (+ y -2 (* 12 (quotient (- 14 y) 12)))) 12) (- z (quotient (- 14 y) 12)) (quotient (- z (quotient (- 14 y) 12)) 4)
                 (quotient (- z (quotient (- 14 y) 12)) 400)) (quotient (- z (quotient (- 14 y) 12)) 100)) 7))