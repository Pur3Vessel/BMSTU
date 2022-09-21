(load "parse_num2.scm")

(define (tree->scheme ex)
  (if (and (list? ex) (= (length ex) 3))
      (if (eq? (cadr ex) '^)
          (list 'expt (tree->scheme (car ex)) (tree->scheme (caddr ex)))
          (list (cadr ex) (tree->scheme (car ex)) (tree->scheme (caddr ex))))
      ex))
         

(tree->scheme (parse (tokenize "x^(a + 1)")))


(eval (tree->scheme (parse (tokenize "2^2^2^2")))
      (interaction-environment))
