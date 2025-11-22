<p align="center"><b>МОНУ НТУУ КПІ ім. Ігоря Сікорського ФПМ СПіСКС</b></p>

<p align="center">
<b>Звіт з лабораторної роботи 5</b><br/>
"Робота з базою даних"<br/>
дисципліни "Вступ до функціонального програмування"
</p>

<p align="right"><strong>Студентка:</strong> <i>Гречишкіна Катерина Дмитрівна КВ-22</i><p>
<p align="right"><strong>Рік:</strong> <i>2025</i><p>

## Загальне завдання
В роботі необхідно реалізувати утиліти для роботи з базою даних, заданою за варіантом (п. 5.1.1). База даних складається з кількох таблиць. Таблиці представлені у вигляді CSV файлів. При зчитуванні записів з таблиць, кожен запис має бути представлений певним типом в залежності від варіанту: структурою, асоціативним списком або геш-таблицею.
1. Визначити структури та/або утиліти для створення записів з таблиць (в залежності від типу записів, заданого варіантом).
2. Розробити утиліту(-и) для зчитування таблиць з файлів. Значення колонок мають бути розібрані відповідно до типу даних у них. Наприклад, рядок — це просто рядок; числові колонки необхідно розібрати як цілі числа або числа з рухомою
крапкою.
3. Розробити функцію select , яка отримує на вхід шлях до файлу з таблицею, а також якийсь обʼєкт, який дасть змогу зчитати записи конкретного типу або структури. Це може бути ключ, список з якоюсь допоміжною інформацією, функція і т. і. За потреби параметрів може бути кілька. select повертає лямбда-вираз, який, в разі виклику, виконує "вибірку" записів з таблиці, шлях до якої було передано у select . При цьому лямбда-вираз в якості ключових параметрів може отримати на вхід значення полів записів таблиці, для того щоб обмежити вибірку лише заданими значеннями (виконати фільтрування). Вибірка повертається у вигляді списку записів.
4. Написати утиліту(-и) для запису вибірки (списку записів) у файл.
5. Написати функції для конвертування записів у інший тип (в залежності від варіанту):
• структури у геш-таблиці
• геш-таблиці у асоціативні списки
• асоціативні списки у геш-таблиці
6. Написати функцію(-ї) для "красивого" виводу записів таблиці (pretty-print).

## Варіант 6
Проєкти із застосуванням ШІ.
Асоціатинвий список.
   
## Лістинг реалізації завдання
```lisp
; 1. Допоміжні функції для роботи з CSV
(defun split-by-semicolon (string)
  ;Розбиває рядок по символу
  (loop for start = 0 then (1+ pos)
        for pos = (position #\; string :start start)
        collect (subseq string start pos)
        while pos))

(defun trim (s)
  (string-trim '(#\Space #\Tab #\Newline #\Return) s))

(defun parse-number-or-string (str)
  ;Якщо це ціле число — повертає число, інакше — рядок
  (let ((s (trim str)))
    (if (every #'digit-char-p s)
        (parse-integer s)
        s)))

(defun keyword-from-string (s)
  ;Перетворює рядок у ключове слово
  (intern (string-upcase (trim s)) :keyword))


; 2. Читання CSV → список alist
(defun read-csv-to-alist (filepath)
  ;Читає CSV-файл і повертає список асоціативних списків
  (with-open-file (in filepath)
    (let* ((header (read-line in))
           (keys   (mapcar #'keyword-from-string (split-by-semicolon header)))
           (result '()))
      (loop for line = (read-line in nil nil)
            while line
            when (plusp (length (trim line)))
            do (let ((values (mapcar #'parse-number-or-string 
                                    (split-by-semicolon line))))
                 (push (mapcar #'cons keys values) result)))
      (nreverse result))))


; 3. SELECT 
(defun select (filepath type-tag)
  (let ((data (read-csv-to-alist filepath)))
    (lambda (&rest filters)
      (if (null filters) 
          data
          (remove-if-not
           (lambda (record)
             (loop for (key value) on filters by #'cddr
                   always (equal (cdr (assoc key record)) value)))
           data)))))


; 4. Запис списку alist у CSV
(defun write-csv-from-alist (filepath records)
  ;Записує список alist у CSV-файл
  (when records
    (let ((keys (mapcar #'car (first records))))
      (with-open-file (out filepath :direction :output
                                    :if-exists :supersede
                                    :if-does-not-exist :create)
        ;; заголовок
        (format out "~{~(~A~)~^;~}~%" keys)
        ;; рядки
        (dolist (rec records)
          (format out "~{~A~^;~}~%" 
                  (mapcar (lambda (key) (cdr (assoc key rec))) keys)))))))


; 5. Конвертація alist ↔ hash-table
(defun alist-to-hashtable (alist)
  (let ((ht (make-hash-table)))
    (dolist (pair alist ht)
      (setf (gethash (car pair) ht) (cdr pair)))))

(defun hashtable-to-alist (ht)
  (let ((result '()))
    (maphash (lambda (key value) (push (cons key value) result)) ht)
    (nreverse result)))


; 6. Вивід 
(defun pretty-print-records (records)
  (dolist (rec records)
    (format t "~%~{ ~A: ~A~%~}" 
            (loop for (key . value) in rec
                  collect (string-downcase key)
                  collect value))))

```

### Тестові набори та утиліти 
```lisp
; Тест 1: Читання та всі записи
(defun test-read-and-print-all ()
  (format t "~%----Тест 1: Читання всіх проєктів і моделей----~%")
  
  (let ((get-projects (select "projects.csv" :project))
        (get-models   (select "models.csv"   :model)))
    
    (format t "~%-----Всі проєкти:-----~%")
    (pretty-print-records (funcall get-projects))
    
    (format t "~%-----Всі моделі ШІ:-----~%")
    (pretty-print-records (funcall get-models))))


;Тест 2: Фільтрація 
(defun test-filtering ()
  (format t "~%----Тест 2: Фільтрація----~%")
  
  (let ((get-projects (select "projects.csv" :project))
                (mod  (select "models.csv"   :model)))
    
    (format t "~%+ Проєкти компанії OpenAI:~%")
    (pretty-print-records (funcall get-projects :COMPANY "OpenAI"))
    
    (format t "~%+ Проєкти 2024 року:~%")
    (pretty-print-records 
      (funcall get-projects :YEAR 2024)) 

    (format t "~%+ Моделі 2024 року з 314000000000 параметрами:~%")
    (pretty-print-records 
      (funcall mod :RELEASEYEAR 2024 :PARAMETERS 314000000000)) 

    (format t "~%+ Модель GPT-4:~%")
    (pretty-print-records (funcall mod :NAME "GPT-4"))))


; Тест 3: Запис відфільтрованих даних у новий файл
(defun test-write-csv ()
  (format t "~%----Тест 3: Запис у файл----~%")
  
  (let* ((selector (select "projects.csv" :project))
         (openai-projects (funcall selector :COMPANY "OpenAI")))
    
    (write-csv-from-alist "openai_projects_only.csv" openai-projects)
    (format t "~%Відфільтровані проєкти OpenAI записано у файл: openai_projects_only.csv~%")))


; Тест 4: Конвертація alist → hash-table → alist
(defun test-conversion ()
  (format t "~%----Тест 4: Конвертація типів----~%")
  
  (let* ((sample-alist '((:ID . 1) (:NAME . "Grok") (:COMPANY . "xAI") (:YEAR . 2024)))
         (ht   (alist-to-hashtable sample-alist))
         (back (hashtable-to-alist ht)))
    
    (format t "~%Початковий alist:~%  ~A~%" sample-alist)
    (format t "~%Геш-таблиця:~%  ~A~%" ht)
    (format t "~%Геш-таблиця (вміст):~%")
    (maphash (lambda (key value)
               (format t "  Ключ: ~A, Значення: ~A~%" key value))
             ht)

    (format t "~%Назад у alist:~%  ~A~%" back)
    (when (equal sample-alist back)
      (format t "~%Конвертація успішна!~%"))))



(defun run-all-tests ()
  (format t "~% ПОЧАТОК ТЕСТУВАННЯ~%")
  (test-read-and-print-all)
  (test-filtering)
  (test-write-csv)
  (test-conversion)
  (format t "~%Усі тести завершено.~%"))
(run-all-tests)
```


### Тестування
```
 ПОЧАТОК ТЕСТУВАННЯ

----Тест 1: Читання всіх проєктів і моделей----

-----Всі проєкти:-----

 id: 1
 name: ChatGPT
 company: OpenAI
 year: 2022

 id: 2
 name: Gemini
 company: Google
 year: 2023

 id: 3
 name: Grok
 company: xAI
 year: 2024

 id: 4
 name: Claude
 company: Anthropic
 year: 2023

 id: 5
 name: DeepSeek-V3
 company: DeepSeek
 year: 2024

-----Всі моделі ШІ:-----

 id: 1
 name: GPT-4
 developer: OpenAI
 releaseyear: 2023
 parameters: 1760000000000

 id: 2
 name: Gemini Ultra
 developer: Google DeepMind
 releaseyear: 2023
 parameters: 1500000000000

 id: 3
 name: Grok-1
 developer: xAI
 releaseyear: 2024
 parameters: 314000000000

 id: 4
 name: Claude 3 Opus
 developer: Anthropic
 releaseyear: 2023
 parameters: 2000000000000

 id: 5
 name: DeepSeek-V3
 developer: DeepSeek
 releaseyear: 2024
 parameters: 671000000000

----Тест 2: Фільтрація----

+ Проєкти компанії OpenAI:

 id: 1
 name: ChatGPT
 company: OpenAI
 year: 2022

+ Проєкти 2024 року:

 id: 3
 name: Grok
 company: xAI
 year: 2024

 id: 5
 name: DeepSeek-V3
 company: DeepSeek
 year: 2024

+ Моделі 2024 року з 314000000000 параметрами:

 id: 3
 name: Grok-1
 developer: xAI
 releaseyear: 2024
 parameters: 314000000000

+ Модель GPT-4:

 id: 1
 name: GPT-4
 developer: OpenAI
 releaseyear: 2023
 parameters: 1760000000000

----Тест 3: Запис у файл----

Відфільтровані проєкти OpenAI записано у файл: openai_projects_only.csv

----Тест 4: Конвертація типів----

Початковий alist:
  ((ID . 1) (NAME . Grok) (COMPANY . xAI) (YEAR . 2024))

Геш-таблиця:
  #<HASH-TABLE :TEST EQL :COUNT 4 {70059379A3}>

Геш-таблиця (вміст):
  Ключ: ID, Значення: 1
  Ключ: NAME, Значення: Grok
  Ключ: COMPANY, Значення: xAI
  Ключ: YEAR, Значення: 2024

Назад у alist:
  ((ID . 1) (NAME . Grok) (COMPANY . xAI) (YEAR . 2024))

Конвертація успішна!

Усі тести завершено.
```
