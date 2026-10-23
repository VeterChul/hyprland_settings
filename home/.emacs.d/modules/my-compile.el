;;; compile.el --- Компиляция, запуск файлов, обработчики расширений -*- lexical-binding: t; -*-

;; Отвечает за:
;; - ассоциативный список my/run-file-handlers
;; - функцию my/run-file (F5)
;; - функцию my/compile-in-new-window
;; - хук для перезагрузки буферов после компиляции

;; ------------------------------------------------------------
;; Обработчики расширений для F5
;; ------------------------------------------------------------
(defvar my/run-file-handlers
  `(("py" . ,(lambda (file root)
           (if root
               (format "~/.emacs.d/skript/python.sh %s %s"
                       (shell-quote-argument root)
                       (shell-quote-argument file))
             (format "python3 %s" (shell-quote-argument file)))))
    ("tex" . ,(lambda (file root)
                (let ((basename (file-name-base file)))
                  (if root
                      (format "~/.emacs.d/skript/latex-mirror-build.sh %s %s"
                              (shell-quote-argument root)
                              (shell-quote-argument file))
                    (format "~/.emacs.d/skript/latex-mirror-build.sh . %s"
                            (shell-quote-argument file))))))
    ("c" . ,(lambda (file root)
          (let* ((dir (or root (file-name-directory file)))
                 (rel-file (file-relative-name file dir))
                 (exec (file-name-sans-extension rel-file)))
            (format "cd %s && gcc -Wall -g %s -o %s -lm && ./%s"
                    (shell-quote-argument dir)
                    (shell-quote-argument rel-file)
                    (shell-quote-argument exec)
                    (shell-quote-argument exec)))))
    ("cpp" . ,(lambda (file root)
                (if root
                    (let* ((rel-file (file-relative-name file root))
                           (exec (file-name-sans-extension rel-file)))
                      (format "cd %s && g++ -Wall -g %s -o %s && ./%s"
                              root rel-file exec exec))
                  (let ((exec (file-name-sans-extension file)))
                    (format "g++ -Wall -g %s -o %s && ./%s"
                            file exec exec)))))
    ("sh" . ,(lambda (file root)
               (format "bash %s" file)))
    ("go" . ,(lambda (file root)
               (if root
                   (format "cd %s && go run %s" root file)
                 (format "go run %s" file))))
    ("rs" . ,(lambda (file root)
               (if root
                   (format "cd %s && cargo run" root)
                 (format "rustc %s && ./%s" file (file-name-sans-extension file)))))
    )
  "Alist mapping file extensions to functions that return a compile command.
The function receives two arguments: the full path to the file (as a string)
and the project root (or nil if not in a project).")

;; ------------------------------------------------------------
;; Запуск компиляции в новом окне
;; ------------------------------------------------------------
(defun my/compile--split-bottom (window)
  "Разделить WINDOW снизу, отдав новому окну треть высоты."
  (let* ((height (window-total-height window))
         (size (max window-min-height (floor (/ height 3)))))
    (split-window window (- size) 'below)))

(defun my/compile--split-auto (window)
  "Разделить WINDOW, сохранив ориентацию текущей раскладки.
Если окно уже разделено по вертикали (окна слева/справа),
новое окно создаётся справа, иначе — снизу."
  (let* ((tree (car (window-tree (window-frame window))))
         (direction (if (and (consp tree) (null (car tree)))
                        'right
                      'below)))
    (split-window window nil direction)))

(defun my/compile--start (command)
  "Запустить `compile' в текущем окне, не меняя раскладку."
  (let ((display-buffer-overriding-action '(display-buffer-same-window)))
    (compile command)))

(defun my/compile--in-new-window (command split-function)
  "Запустить COMMAND в новом окне, созданном SPLIT-FUNCTION."
  (let* ((orig-window (selected-window))
         (new-window (condition-case nil
                         (funcall split-function orig-window)
                       (error nil))))
    (when new-window
      (select-window new-window))
    (my/compile--start command)))

(defun my/compile-in-new-window (command)
  "Запустить compile в новом окне снизу, высотой в треть окна."
  (my/compile--in-new-window command #'my/compile--split-bottom))

(defun my/compile-in-new-window-auto (command)
  "Запустить compile в новом окне справа или снизу по текущей раскладке."
  (my/compile--in-new-window command #'my/compile--split-auto))

;; ------------------------------------------------------------
;; Основная функция запуска (F5)
;; ------------------------------------------------------------
(defun my/run-file--start (compile-function)
  "Запустить текущий файл, используя COMPILE-FUNCTION для нового окна."
  (let ((file (buffer-file-name)))
    (if (not file)
        (message "Нет файла для запуска!")
      (let* ((ext (file-name-extension file))
             (project-root (projectile-project-root))
             (handler (cdr (assoc ext my/run-file-handlers))))
        (if handler
            (let ((command (funcall handler file project-root))
                  (comp-window (get-buffer-window "*compilation*" t)))
              (if comp-window
                  (let ((orig-window (selected-window)))
                    (select-window comp-window)
                    (my/compile--start command)
                    (select-window orig-window))
                (funcall compile-function command)))
          (call-interactively 'compile))))))

(defun my/run-file ()
  "Запустить текущий файл, используя обработчик из `my/run-file-handlers`.
Окно компиляции открывается снизу и занимает треть высоты.
Если обработчик не найден, предложить стандартный `compile`."
  (interactive)
  (my/run-file--start #'my/compile-in-new-window))

(defun my/run-file-auto ()
  "Запустить текущий файл с авто-выбором окна компиляции.
Окно открывается справа, если раскладка вертикальная, иначе снизу.
Если обработчик не найден, предложить стандартный `compile`."
  (interactive)
  (my/run-file--start #'my/compile-in-new-window-auto))

;; ------------------------------------------------------------
;; Автоматическая перезагрузка буферов после компиляции
;; ------------------------------------------------------------
(defun my/revert-all-buffers ()
  "Перезагрузить все буферы, у которых файл изменился на диске."
  (interactive)
  (dolist (buf (buffer-list))
    (when (and (buffer-file-name buf)
               (not (buffer-modified-p buf))
               (file-exists-p (buffer-file-name buf))
               (not (verify-visited-file-modtime buf)))
      (with-current-buffer buf
        (revert-buffer t t nil)))))

(defun my/on-compilation-finish (buf msg)
  "Вызвать my/revert-all-buffers после успешной компиляции."
  (when (string-match "finished" msg)
    (my/revert-all-buffers)))

(add-hook 'compilation-finish-functions #'my/on-compilation-finish)

(provide 'my-compile)
