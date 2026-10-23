;;; functions.el --- Все пользовательские функции (my/*), не вошедшие в другие модули -*- lexical-binding: t; -*-

;; Здесь собраны все функции, которые относятся к общей логике:
;; - открытие файлов в новых окнах
;; - сохранение и закрытие буферов
;; - закрытие вкладки или буфера
;; - прочие утилиты

;; ------------------------------------------------------------
;; Открытие файлов в новых сплитах
;; ------------------------------------------------------------
(defun my/find-file-in-new-window-vertically ()
  "Открыть файл в новом вертикальном сплите (справа)."
  (interactive)
  (split-window-right)
  (other-window 1)
  (call-interactively 'find-file))

(defun my/find-file-in-new-window-horizontally ()
  "Открыть файл в новом горизонтальном сплите (снизу)."
  (interactive)
  (split-window-below)
  (other-window 1)
  (call-interactively 'find-file))

;; ------------------------------------------------------------
;; Поиск файлов через consult с открытием в сплите
;; ------------------------------------------------------------
(defun my/consult-find-other-window-vertically ()
  "Найти файл и открыть его в вертикальном сплите (справа)."
  (interactive)
  (let ((file (consult-find)))
    (when file
      (my/find-file-in-new-window-vertically (file-relative-name file)))))

(defun my/consult-find-other-window-horizontally ()
  "Найти файл и открыть его в горизонтальном сплите (снизу)."
  (interactive)
  (let ((file (consult-find)))
    (when file
      (my/find-file-in-new-window-horizontally (file-relative-name file)))))

;; ------------------------------------------------------------
;; Сохранение и закрытие буфера/окна
;; ------------------------------------------------------------
(defun my/save-and-close-buffer ()
  "Сохранить буфер (если изменён), убить его и закрыть окно.
Если окно было единственным, закрыть фрейм."
  (interactive)
  (when (and (buffer-modified-p)
             (y-or-n-p "Save buffer? "))
    (save-buffer))
  (let ((buf (current-buffer)))
    (kill-buffer buf)
    (if (one-window-p)
        (delete-frame)
      (delete-window))))

(defun my/save-and-kill-selected-buffer ()
  "Выбрать буфер, сохранить (если изменён) и закрыть его."
  (interactive)
  (let* ((buf (consult-buffer))
         (buf (if (listp buf) (car buf) buf)))
    (when (bufferp buf)
      (with-current-buffer buf
        (when (buffer-modified-p)
          (save-buffer)))
      (kill-buffer buf))))

;; ------------------------------------------------------------
;; Закрытие вкладки или буфера (используется в keybindings)
;; ------------------------------------------------------------
(defun my/close-tab-or-kill-buffer ()
  "Закрыть текущую вкладку, если tab-bar активен, иначе убить буфер."
  (interactive)
  (if my/tab-bar-enabled
      (tab-bar-close-tab)
    (kill-buffer)))

(provide 'functions)
