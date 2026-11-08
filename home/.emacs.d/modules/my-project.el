;;; project.el --- Управление проектами и файловая панель -*- lexical-binding: t; -*-

;; Отвечает за:
;; - настройки Projectile (в use-package)
;; - функции открытия файлов в умном окне
;; - выбор проекта при старте
;; - автоматическое открытие панели после переключения проекта
;; - все функции my/*, связанные с проектами и панелью

;; ------------------------------------------------------------
;; Умное открытие файлов из dired-sidebar
;; ------------------------------------------------------------
(defun my/find-other-editing-window ()
  "Найти окно, которое не является деревом или специальным буфером."
  (let ((windows (window-list))
        (candidate nil))
    (dolist (win windows)
      (with-current-buffer (window-buffer win)
        (when (and (not (eq major-mode 'dired-sidebar-mode))
                   (not (eq major-mode 'vterm-mode))
                   (not (string-match-p "^\\*" (buffer-name))))
          (setq candidate win))))
    (or candidate (selected-window))))

(defun my/open-file-in-smart-window (file)
  "Открыть FILE в новом сплите, но не в окне дерева."
  (let ((windows (window-list))
        (target-win nil))
    (dolist (win windows)
      (with-current-buffer (window-buffer win)
        (when (not (eq major-mode 'dired-sidebar-mode))
          (setq target-win win))))
    (if target-win
        (progn
          (select-window target-win)
          (if (> (window-body-width target-win) (window-body-height target-win))
              (split-window-right)
            (split-window-below))
          (other-window 1)
          (find-file file))
      (progn
        (if (> (window-body-width) (window-body-height))
            (split-window-right)
          (split-window-below))
        (other-window 1)
        (find-file file)))))

(defun my-dired-sidebar-open ()
  "Открыть файл в умном окне или раскрыть/свернуть папку."
  (interactive)
  (let ((file (dired-get-filename nil t)))
    (if (and file (file-directory-p file))
        (dired-subtree-toggle)
      (my/open-file-in-smart-window file))))

(defun my/dired-create-file ()
  "Создать пустой файл в текущей папке dired и обновить список."
  (interactive)
  (let* ((dir (dired-current-directory))
         (filename (read-file-name "New file: " dir)))
    (when (and filename (not (file-exists-p filename)))
      (write-region "" nil filename)       ; создаём пустой файл
      (revert-buffer)                      ; обновляем панель
      (message "Создан файл: %s" filename))))

(defun my/dired-go-project-root ()
  "Перейти в корень текущего проекта."
  (interactive)
  (let ((root (projectile-project-root)))
    (if root
        (dired-sidebar-jump-to root)
      (message "Не в проекте"))))

(defun my/dired-go-home ()
  "Перейти в домашнюю папку."
  (interactive)
  (dired-sidebar-jump-to "~"))

(defun my/dired-go-root ()
  "Перейти в корень файловой системы."
  (interactive)
  (dired-sidebar-jump-to "/"))

(defun my/dired-copy-path ()
  "Скопировать полный путь текущего файла/папки в буфер обмена."
  (interactive)
  (let ((file (dired-get-filename nil t)))
    (if file
        (progn
          (kill-new file)
          (message "Скопировано: %s" file))
      (message "Нет файла под курсором"))))

(defun my/dired-search-name ()
  "Пометить файлы по регулярному выражению."
  (interactive)
  (dired-mark-files-regexp (read-regexp "Имя файла: ")))

(defun my/dired-toggle-hidden ()
  "Показать/скрыть скрытые файлы (точка-файлы)."
  (interactive)
  (dired-omit-mode (if dired-omit-mode -1 1)))

;; ============================================================
;; Буфер с подсказками (cheatsheet)
;; ============================================================

(defvar my/cheatsheet-file (expand-file-name "~/.emacs.d/cheatsheet.org" user-emacs-directory)
  "Путь к файлу с подсказками.")

(defun my/open-cheatsheet ()
  "Открыть буфер с подсказками в текущем окне."
  (interactive)
  (if (file-exists-p my/cheatsheet-file)
      (let ((buf (get-buffer-create "*Cheatsheet*")))
        (with-current-buffer buf
          ;; Буфер мог остаться от предыдущего открытия и быть read-only.
          (let ((inhibit-read-only t))
            (erase-buffer)
            (insert-file-contents my/cheatsheet-file))
          (org-mode)
          (setq buffer-read-only t)
          (set-buffer-modified-p nil)
          (local-set-key (kbd "q") #'my/close-cheatsheet))
        (switch-to-buffer buf))
    (message "Файл cheatsheet.org не найден в %s" user-emacs-directory)))

(defun my/close-cheatsheet ()
  "Закрыть окно с подсказками и убить буфер."
  (interactive)
  (let ((buf (get-buffer "*Cheatsheet*")))
    (when buf
      (let ((win (get-buffer-window buf)))
        (when win
          ;; Нельзя удалить единственное окно на фрейме: сначала
          ;; переключаем его на другой буфер.
          (if (one-window-p t)
              (switch-to-buffer (or (other-buffer buf t)
                                    (get-buffer-create "*scratch*")))
            (delete-window win))))
      (when (buffer-live-p buf)
        (kill-buffer buf)))))

;; ------------------------------------------------------------
;; Стартовый выбор проекта
;; ------------------------------------------------------------

(defun my/startup-select-project ()
  "Открыть список известных проектов и переключиться на выбранный.
Если известных проектов нет, ничего не открывать."
  (interactive)
  (let ((projects (projectile-known-projects)))
    (if projects
        (progn
          (my/open-cheatsheet)
          ;; Закрываем подсказки даже при отмене выбора (C-g).
          (unwind-protect
              (condition-case err
                  (projectile-switch-project-by-name
                   (completing-read "Select project: " projects))
                (quit nil)
                (error
                 (message "Не удалось открыть проект: %s"
                          (error-message-string err))))
            (my/close-cheatsheet)))
      (message "No known projects yet. Open some project first."))))


;; ------------------------------------------------------------
;; Автоматическое открытие панели после переключения проекта
;; ------------------------------------------------------------
(defun my/open-sidebar-after-project ()
  "Открыть dired-sidebar с корнем текущего проекта."
  (dired-sidebar-show-sidebar))

(add-hook 'projectile-after-switch-project-hook #'my/open-sidebar-after-project)

;; Запуск выбора проекта после загрузки
(add-hook 'emacs-startup-hook #'my/startup-select-project)

(provide 'my-project)
