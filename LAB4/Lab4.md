<p align="center"><b>МОНУ НТУУ КПІ ім. Ігоря Сікорського ФПМ СПіСКС</b></p>

<p align="center">
<b>Звіт з лабораторної роботи 4</b><br/>
"Функції вищого порядку та замикання"<br/>
дисципліни "Вступ до функціонального програмування"
</p>

<p align="right"><strong>Студентка:</strong> <i>Гречишкіна Катерина Дмитрівна КВ-22</i><p>
<p align="right"><strong>Рік:</strong> <i>2025</i><p>

## Загальне завдання
Завдання складається з двох частин:
1. Переписати функціональну реалізацію алгоритму сортування з лабораторної
роботи 3 з такими змінами:
    - використати функції вищого порядку для роботи з послідовностями (де/якщо це доречно, в разі, якщо функції вищого порядку не були використані при реалізації л.р. №3);
    - додати до інтерфейсу функції (та використання в реалізації) два ключових параметра: key та test , що працюють аналогічно до того, як працюють параметри з такими назвами в функціях, що працюють з послідовностями (р.12). При цьому key має виконатись мінімальну кількість разів.
3. Реалізувати функцію, що створює замикання, яке працює згідно із завданням за
варіантом (див. п 4.1.2). Використання псевдофункцій не забороняється, але, за
можливості, має бути зменшене до необхідного мінімуму.

## Варіант першої частини 6 (1)
Алгоритм сортування вибором за незменшенням.
   
## Лістинг реалізації першої частини завдання
```lisp
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
```

### Тестові набори та утиліти першої частини
```lisp
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
```

### Тестування першої частини
```
=== Functional Sort Tests ===
passed... test 1
passed... test 2
passed... test 3
passed... test 4
passed... test 6
passed... test 7

```

## Варіант другої частини 6
Написати функцію ```rpropagation-reducer``` , яка має один ключовий параметр — функцію
```comparator``` . ```rpropagation-reducer``` має повернути функцію, яка при застосуванні в
якості першого аргумента ```reduce``` робить наступне: при обході списку з кінця, якщо
елемент списку-аргумента ```reduce``` не "кращий" за попередній (той, що "справа") згідно з
```comparator``` , тоді він заміняється на значення попереднього, тобто "кращого", елемента.
Якщо ж він "кращий" за попередній елемент згідно ```comparator``` , тоді заміна не
відбувається. Функція ```comparator``` за замовчуванням має значення ```#'<``` . Обмеження,
які накладаються на використання функції-результату ```rpropagation-reducer``` при
передачі у ```reduce``` визначаються розробником (тобто, наприклад, необхідно чітко
визначити, якими мають бути значення ключових параметрів функції ```reduce``` ```from-end```
та ```initial-value``` ).
```lisp
CL-USER> (reduce (rpropagation-reducer)
         '(3 2 1 2 3)
         :from-end ...
         :initial-value ...)
(1 1 1 2 3)
CL-USER> (reduce (rpropagation-reducer)
         '(3 1 4 2)
         :from-end ...
         :initial-value ...)
(1 1 2 2)
CL-USER> (reduce (rpropagation-reducer :comparator #'>)
         '(1 2 3)
         :from-end ...
         :initial-value ...)
(3 3 3)
```

## Лістинг реалізації другої частини завдання
```lisp
(defun rpropagation-reducer (&key (comparator #'<))
  (lambda (current acc)
    (let* ((rightmost (car acc))
           (best (if (and rightmost
                          (not (funcall comparator current rightmost)))
                     rightmost    
                     current)))   
      (cons best acc))))
```

### Тестові набори та утиліти другої частини
```lisp
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
```

### Тестування
```
===  Tests rpropagation-reducer ===
passed... test 1
passed... test 2
passed... test 3
```
