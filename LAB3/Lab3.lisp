
(defun find-min (lst)
  (if (null lst)
      nil
      (if (null (cdr lst))
          (car lst)
          (let ((min-rest (find-min (cdr lst))))
            (if (<= (car lst) min-rest)
                (car lst)
                min-rest)))))

(defun remove-one (item lst)
  (cond ((null lst) nil)
        ((= item (car lst)) (cdr lst))
        (t (cons (car lst) (remove-one item (cdr lst))))))


(defun sort-func (lst)
  (if (or (null lst) (null (cdr lst)))
      lst
      (let ((min (find-min lst)))
        (cons min (sort-func (remove-one min lst))))))

(defun check-sort-func (name input expected)
  (format t "~:[FAILED~;passed~]... ~a~%" 
          (equal (sort-func input) expected) name))

(defun test-sort-func ()
  (check-sort-func "test 1" '(3 1 2) '(1 2 3))
  (check-sort-func "test 2" nil nil)
  (check-sort-func "test 3" '(5 5 1 3) '(1 3 5 5))
  (check-sort-func "test 4" '(7) '(7))
  (check-sort-func "test 5" '(4 -2 0 -1) '(-2 -1 0 4))
  (check-sort-func "test 6" '(2 2 2 2) '(2 2 2 2)))
  
  
(defun sort-imp (lst)
  (let* ((input-copy (copy-list lst)) 
         (result input-copy))
    (loop for current on result while (cdr current) do
      (let ((min-elt (car current))
            (min-tail current))
        (loop for tail on (cdr current) do
          (when (< (car tail) min-elt)
            (setf min-elt (car tail)
                  min-tail tail)))
        (when (not (eq current min-tail))
          (rotatef (car current) (car min-tail)))))
    result))


(defun check-sort-imp (name input expected)
  (format t "~:[FAILED~;passed~]... ~a~%" 
          (equal (sort-imp input) expected) name))

(defun test-sort-imp ()
  (check-sort-imp "test 1" '(3 1 2) '(1 2 3))
  (check-sort-imp "test 2" nil nil)
  (check-sort-imp "test 3" '(5 5 1 3) '(1 3 5 5))
  (check-sort-imp "test 4" '(7) '(7))
  (check-sort-imp "test 5" '(4 -2 0 -1) '(-2 -1 0 4))
  (check-sort-imp "test 6" '(2 2 2 2) '(2 2 2 2)))


(defun run-tests ()
  (format t "~%=== Functional Sort Tests ===~%")
  (test-sort-func)
  (format t "~%=== Imperative Sort Tests ===~%")
  (test-sort-imp))

(run-tests)