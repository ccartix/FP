(defun merge-lists-spinning-pairs (lst1 lst2)
  (cond ((null lst1)
         (if (null lst2)
             nil
             (cons (list (car lst2))
                   (merge-lists-spinning-pairs nil (cdr lst2)))))
        ((null lst2)
         (cons (list (car lst1))
               (merge-lists-spinning-pairs (cdr lst1) nil)))
        (t
         (cons (list (car lst1) (car lst2))
               (merge-lists-spinning-pairs (cdr lst2) (cdr lst1))))))

(defun list-set-intersect-p (a b)
  (cond ((or (null a) (null b)) nil)
        ((eql (car a) (car b)) t)
        (t (or (list-set-intersect-p a (cdr b))
               (list-set-intersect-p (cdr a) b)))))

(defun check-result (name func input1 input2 expected)
  (format t "~:[FAILED~;passed~]... ~a~%"
          (equal (funcall func input1 input2) expected)
          name))

(defun test-merge-lists-spinning-pairs ()
  (check-result "Тест 1" #'merge-lists-spinning-pairs '(1 2 3) '(a b c) '((1 A) (B 2) (3 C)))
  (check-result "Тест 2" #'merge-lists-spinning-pairs nil '(a b) '((A) (B)))
  (check-result "Тест 3" #'merge-lists-spinning-pairs '(1 2) nil '((1) (2)))
  (check-result "Тест 4" #'merge-lists-spinning-pairs nil nil nil)
  (check-result "Тест 5" #'merge-lists-spinning-pairs '(1 2 3 4 5) '(a b c d) '((1 A) (B 2) (3 C) (D 4) (5))))

(defun test-list-set-intersect-p ()
  (check-result "Тест 1" #'list-set-intersect-p '(1 2 3) '(4 5 6) nil)
  (check-result "Тест 2" #'list-set-intersect-p '(1 2) '(2 3) t)
  (check-result "Тест 3" #'list-set-intersect-p nil '(a b) nil)
  (check-result "Тест 4" #'list-set-intersect-p nil nil nil)
  (check-result "Тест 5" #'list-set-intersect-p '(1 2) '(3 2) t))

(defun run-all-tests ()
  (format t "~%Тести для merge-lists-spinning-pairs:~%")
  (test-merge-lists-spinning-pairs)
  (format t "~%Тести для list-set-intersect-p:~%")
  (test-list-set-intersect-p))

(run-all-tests)