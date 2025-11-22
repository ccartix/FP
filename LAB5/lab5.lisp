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
    (format t "~%")
    (dolist (pair rec)
      (format t " ~(~A~): ~A~%" (car pair) (cdr pair)))))


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