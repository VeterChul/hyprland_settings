;;; my-opencode.el --- OpenCode в терминале vterm -*- lexical-binding: t; -*-

;; Отвечает за:
;; - запуск OpenCode в отдельном vterm-буфере для каждого проекта
;; - повторное использование уже запущенной сессии
;; - перезапуск сессии по префиксному аргументу
;; - привязки вынесены в keybindings.el

(defvar my/opencode-command "opencode"
  "Команда запуска OpenCode в vterm.")

(defun my/opencode--project-root ()
  "Вернуть корень текущего проекта или `default-directory'."
  (or (projectile-project-root)
      default-directory))

(defun my/opencode--buffer-name (root)
  "Сформировать имя буфера OpenCode для корня ROOT."
  (let* ((dir (directory-file-name (expand-file-name root)))
         (name (file-name-nondirectory dir)))
    (format "*opencode: %s*" (if (equal name "") "root" name))))

(defun my/opencode--kill-buffer (buffer)
  "Завершить процесс и убить BUFFER без лишних вопросов."
  (when (buffer-live-p buffer)
    (let ((process (get-buffer-process buffer)))
      (when (process-live-p process)
        (delete-process process)))
    (kill-buffer buffer)))

(defun my/opencode--get-buffer (root &optional restart)
  "Вернуть vterm-буфер OpenCode для ROOT.
При необходимости создать буфер и запустить `my/opencode-command'.
Если RESTART не nil, существующая сессия перезапускается."
  (let* ((name (my/opencode--buffer-name root))
         (buffer (get-buffer name)))
    (when (and restart buffer)
      (my/opencode--kill-buffer buffer)
      (setq buffer nil))
    (unless (and buffer
                 (with-current-buffer buffer
                   (and (derived-mode-p 'vterm-mode)
                        (process-live-p (get-buffer-process buffer)))))
      (when buffer
        (my/opencode--kill-buffer buffer))
      (let ((default-directory root))
        (save-window-excursion
          (setq buffer (vterm name))
          (with-current-buffer buffer
            (vterm-send-string (concat my/opencode-command "\n"))))))
    buffer))

(defun my/opencode (&optional restart)
  "Открыть OpenCode для текущего проекта в vterm.
Если сессия уже запущена, переключиться на неё.
С префиксным аргументом RESTART перезапустить сессию.
Новое окно создаётся справа или снизу в зависимости от размеров фрейма."
  (interactive "P")
  (let* ((root (my/opencode--project-root))
         (buffer (my/opencode--get-buffer root restart))
         (window (get-buffer-window buffer)))
    (if window
        (select-window window)
      (if (> (window-body-width) (window-body-height))
          (split-window-right)
        (split-window-below))
      (other-window 1)
      (switch-to-buffer buffer))))

(provide 'my-opencode)
