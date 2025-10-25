<p align="center"><b>МОНУ НТУУ КПІ ім. Ігоря Сікорського ФПМ СПіСКС</b></p>

<p align="center">
<b>Звіт з лабораторної роботи 3</b><br/>
"Функціональний і імперативний підходи до роботи зі списками" <br / >
дисципліни "Вступ до функціонального програмування"
</p>
<p align="right"><strong>Студентка:</strong> <i>Гречишкіна Катерина Дмитрівна КВ-22</i><p>
<p align="right"><strong>Рік:</strong> <i>2025</i><p>

## Загальне завдання
Реалізуйте алгоритм сортування чисел у списку двома способами: функціонально і імперативно.
1. Функціональний варіант реалізації має базуватись на використанні рекурсії і конструюванні нових списків щоразу, коли необхідно виконати зміну вхідного списку. Не допускається використання: псевдо-функцій, деструктивних операцій, циклів . Також реалізована функція не має бути функціоналом (тобто приймати на вхід функції в якості аргументів).
2. Імперативний варіант реалізації має базуватись на використанні циклів і деструктивних функцій (псевдофункцій). Не допускається використання функцій вищого порядку або функцій для роботи зі списками/послідовностями, що використовуються як функції вищого порядку. Тим не менш, оригінальний список цей варіант реалізації також не має змінювати, тому перед виконанням деструктивних змін варто застосувати функцію сору-list (в разі необхідності).
Також реалізована функція не має бути функціоналом (тобто приймати на вхід функції в якості аргументів).
Кожна реалізована функція має бути протестована для різних тестових наборів. Тести мають бути оформленні у вигляді модульних тестів.

## Варіант 6 (1)

Алгоритм сортування вибором за незменшенням.
   
## Лістинг функції з використанням функціонального підходу
```lisp
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
```

## Тестові набори та утиліти
```lisp
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
```

### Тестування
```
=== Functional Sort Tests ===
passed... test 1
passed... test 2
passed... test 3
passed... test 4
passed... test 5
passed... test 6

```
## Лістинг функції з використанням імперативного підходу
```lisp
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
```

## Тестові набори та утиліти
```lisp
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
```

### Тестування
```
=== Imperative Sort Tests ===
passed... test 1
passed... test 2
passed... test 3
passed... test 4
passed... test 5
passed... test 6
```
