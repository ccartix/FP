(defun find-min-pair (pairs test)
  (if (null (cdr pairs))
      (car pairs)
      (let* ((head-pair (car pairs))
             (tail-min-pair (find-min-pair (cdr pairs) test)))
        (if (funcall test (car head-pair) (car tail-min-pair))
            head-pair
            tail-min-pair))))

(defun remove-one (item lst)
  (cond ((null lst) nil)
        ((equal item (car lst)) (cdr lst)) 
        (t (cons (car lst) (remove-one item (cdr lst))))))

(defun sort-pairs (pairs test)
  (if (or (null pairs) (null (cdr pairs)))
      pairs
      (let ((min-pair (find-min-pair pairs test)))
        (cons min-pair
              (sort-pairs (remove-one min-pair pairs) test)))))

(defun sort-func (lst &key (key #'identity) (test #'<))
  (let* ((pairs (mapcar (lambda (x) (cons (funcall key x) x)) lst))
         (sorted-pairs (sort-pairs pairs test)))
    (mapcar #'cdr sorted-pairs)))
  
(defun check-sort-func (name input expected &key (key #'identity) (test #'<))
  (format t "~:[FAILED~;passed~]... ~a~%" 
          (equal (sort-func input :key key :test test) expected) name))

(defun test-sort-func ()
  (check-sort-func "test 1" '(3 1 2) '(1 2 3))
  (check-sort-func "test 2" nil nil)
  (check-sort-func "test 3" '(5 5 1 3) '(1 3 5 5))
  (check-sort-func "test 4" '(7) '(7))
  (check-sort-func "test 6" '(-5 2 -3 8 -1 4) '(-1 2 -3 4 -5 8) :key #'abs)
  (check-sort-func "test 7" '(1 2 3 4 5)   '(5 4 3 2 1)   :test #'>))


(defun rpropagation-reducer (&key (comparator #'<))
  (lambda (current acc)
    (let* ((rightmost (car acc))
           (best (if (and rightmost
                          (not (funcall comparator current rightmost)))
                     rightmost    
                     current)))   
      (cons best acc))))


(defun check-rpropagation (name input expected &key (comparator #'<))
  (let* ((result (reduce (rpropagation-reducer :comparator comparator)
                         input
                         :from-end t
                         :initial-value nil)))
    (format t "~:[FAILED~;passed~]... ~a~%"
            (equal result expected)
            name)))

(defun test-rpropagation ()
  (check-rpropagation "test 1" '(3 2 1 2 3) '(1 1 1 2 3))
  (check-rpropagation "test 2" '(3 1 4 2) '(1 1 2 2))
  (check-rpropagation "test 3" '(1 2 3) '(3 3 3) :comparator #'>))

(defun run-tests ()
  (format t "~%=== Functional Sort Tests ===~%")
  (test-sort-func)
  (format t "~%===  Tests rpropagation-reducer ===~%")
  (test-rpropagation))

(run-tests)
