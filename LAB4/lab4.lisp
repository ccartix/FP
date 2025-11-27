(defun find-min-pair (pair-lst test)
  (if (null (cdr pair-lst))
      (car pair-lst)
      (let* ((head (car pair-lst))
             (tail-min (find-min-pair (cdr pair-lst) test)))
        (if (funcall test (car head) (car tail-min))
            head
            tail-min))))

(defun remove-one (element lst)
  (cond ((null lst) nil)
        ((equal element (car lst)) (cdr lst))
        (t (cons (car lst) (remove-one element (cdr lst))))))

(defun sort-pairs-recursive (pair-lst test)
  (if (or (null pair-lst) (null (cdr pair-lst)))
      pair-lst
      (let ((min-pair (find-min-pair pair-lst test)))
        (cons min-pair
              (sort-pairs-recursive (remove-one min-pair pair-lst) test)))))

(defun sort-func (lst &key (key #'identity) (test #'<))
  (let* ((decorated-lst (mapcar (lambda (x) (cons (funcall key x) x)) lst))
         (sorted-pairs (sort-pairs-recursive decorated-lst test)))
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
