(load "parser.scm")

(parse #(1 2 +))

(parse #(x dup 0 swap if drop -1 endif))
    

(parse #( define -- 1 - end
          define =0? dup 0 = end
          define =1? dup 1 = end
          define factorial
              =0? if drop 1 exit endif
              =1? if drop 1 exit endif
              dup --
              factorial
              *
          end
          0 factorial
          1 factorial
          2 factorial
          3 factorial
          4 factorial ))

(parse #(define word w1 w2 w3))

(parse #(1 if dup dup dup if dup drop drop if rot endif dup endif endif))
(parse #(end define ++ 1 + end 4 ++))
(parse #(1 + define ++ 1 + end 3 ++))
(parse #(4 if 2 2 if 77 endif 6))
(parse #(4 2 2 endif if 6 endif))

(parse #(define endif x y z end))
(parse #(define 1 end))
(parse #(define if endif end))
(parse #(if if if if endif endif endif endif))