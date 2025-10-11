<p align="center"><b>МОНУ НТУУ КПІ ім. Ігоря Сікорського ФПМ СПіСКС</b></p>

<p align="center">
<b>Звіт з лабораторної роботи 2</b><br/>
"Рекурсія"<br/>
дисципліни "Вступ до функціонального програмування"
</p>
<p align="right"><strong>Студентка:</strong> <i>Гречишкіна Катерина Дмитрівна КВ-22</i><p>
<p align="right"><strong>Рік:</strong> <i>2025</i><p>

## Загальне завдання
  
Реалізуйте дві рекурсивні функції, що виконують деякі дії з вхідним(и) списком(-ами), за
можливості/необхідності використовуючи різні види рекурсії. Функції, які необхідно
реалізувати, задаються варіантом (п. 2.1.1). Вимоги до функцій:
1. Зміна списку згідно із завданням має відбуватись за рахунок конструювання нового
списку, а не зміни наявного (вхідного).
2. Не допускається використання функцій вищого порядку чи стандартних функцій
для роботи зі списками, що не наведені в четвертому розділі навчального
посібника.
3. Реалізована функція не має бути функцією вищого порядку, тобто приймати функції
в якості аргументів.
4. Не допускається використання псевдофункцій (деструктивного підходу).
5. Не допускається використання циклів.

Кожна реалізована функція має бути протестована для різних тестових наборів. Тести
мають бути оформленні у вигляді модульних тестів

## Варіант 6

1. Написати функцію `merge-lists-spinning-pairs`, яка групує відповідні елементи двох списків, почергово змінюючи їх взаємне розташування в групі:
   ```lisp
   CL-USER> (merge-lists-spinning-pairs '(1 2 3 4 5) '(a b c d))
   ((1 A) (B 2) (3 C) (D 4) (5))
   
2. Написати предикат list-set-intersect-p, який визначає чи перетинаються дві множини, задані списками атомів, чи ні:
   ```lisp
   CL-USER> (list-set-intersect-p '(1 2 3) '(4 5 6))
   NIL
   CL-USER> (list-set-intersect-p '(1 2 3) '(3 4 5))
   T
   
## Лістинг функції merge-lists-spinning-pairs
```lisp
(defun merge-lists-spinning-pairs (lst1 list2)
  (cond
    ((null lst1) 
     (if (null list2) nil (cons (list (car list2)) (merge-lists-spinning-pairs nil (cdr list2)))))
    ((null list2) 
     (cons (list (car lst1)) (merge-lists-spinning-pairs (cdr lst1) nil)))
    (t 
     (cons (list (car lst1) (car list2)) (merge-lists-spinning-pairs (cdr list2) (cdr lst1))))))
```

## Лістинг функції list-set-intersect-p
```lisp

(defun list-set-intersect-p (a b)
  (cond ((or (null a) (null b)) nil)
        ((eql (car a) (car b)) t)
        (t (or (list-set-intersect-p a (cdr b))
               (list-set-intersect-p (cdr a) b)))))

```
## Тестові набори та утиліти
```lisp
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

```

### Тестування
```lisp
Тести для merge-lists-spinning-pairs:
passed... Тест 1
passed... Тест 2
passed... Тест 3
passed... Тест 4
passed... Тест 5

Тести для list-set-intersect-p:
passed... Тест 1
passed... Тест 2
passed... Тест 3
passed... Тест 4
passed... Тест 5
```
