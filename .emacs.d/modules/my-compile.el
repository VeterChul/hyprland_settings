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
(defun my/compile-in-new-window (command)
  "Запустить compile в новом окне, не затрагивая другие окна."
  (let* ((orig-window (selected-window))
         (orig-buffer (current-buffer))
         (new-window (split-window orig-window nil 'below))
         (other-windows (remove new-window (window-list))))
    (let ((orig-buffers (mapcar (lambda (w) (cons w (window-buffer w))) other-windows)))
      (select-window new-window)
      (compile command)
      (dolist (item orig-buffers)
        (let ((win (car item))
              (buf (cdr item)))
          (when (buffer-live-p buf)
            (set-window-buffer win buf))))
      (let ((comp-buf (get-buffer "*compilation*")))
        (when comp-buf
          (set-window-buffer new-window comp-buf))))))

;; ------------------------------------------------------------
;; Основная функция запуска (F5)
;; ------------------------------------------------------------
(defun my/run-file ()
  "Запустить текущий файл, используя обработчик из `my/run-file-handlers`.
Если обработчик не найден, предложить стандартный `compile`."
  (interactive)
  (let ((file (buffer-file-name)))
    (if (not file)
        (message "Нет файла для запуска!")
      (let* ((ext (file-name-extension file))
             (project-root (projectile-project-root))
             (handler (cdr (assoc ext my/run-file-handlers))))
        (if handler
            (let ((command (funcall handler file project-root)))
              (if (get-buffer-window "*compilation*" t)
                  (progn
                    (select-window (get-buffer-window "*compilation*" t))
                    (compile command)
                    (select-window (previous-window)))
                (my/compile-in-new-window command)))
          (call-interactively 'compile))))))

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
