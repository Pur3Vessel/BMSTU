(define-syntax my-let
  (syntax-rules ()
    ((_ ((value exp) . (values exps)) actions) ((lambda (value . values) actions)
                                    exp . exps))))

(let ((a 10)
      (b  (* 8 9))
      (c (- 9 7)))
  (+ a b c))


(my-let ((a 10)
         (b  (* 8 9))
         (c (- 9 7)))
        (+ a b c))


(define-syntax my-let*
  (syntax-rules ()
    ((_ ((value exp) (other_value other_exp) . (values exps)) actions)
     (begin (define value exp) (my-let* ((other_value other_exp) . (values exps)) actions)))
    ((_ () actions) actions)))

(let* ((a 10)
       (b (+ a 1)))
  (+ a b))

(my-let* ((a 10)
         (b (+ a 1)))
         (+ a b))