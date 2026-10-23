;;; completion.el --- Настройка систем завершения и поиска -*- lexical-binding: t; -*-

;; Отвечает за:
;; - настройки Vertico, Consult, Marginalia (всё уже в use-package)
;; - функции для обработки hjkl в минибуфере (my/vertico-*)
;; - привязки вынесены в keybindings.el

;; ------------------------------------------------------------
;; Функции для Vertico (hjkl навигация + режим вставки)
;; ------------------------------------------------------------
(defvar my/vertico-insert-mode nil
  "Если t, то hjkl вводят буквы, иначе навигация.")

(defun my/vertico-toggle-insert ()
  "Переключить режим ввода в минибуфере."
  (interactive)
  (if my/vertico-insert-mode
      (insert "i")
    (setq my/vertico-insert-mode t)))

(defun my/vertico-handle-h ()
  (interactive)
  (if my/vertico-insert-mode
      (insert "h")
    (vertico-first)))

(defun my/vertico-handle-j ()
  (interactive)
  (if my/vertico-insert-mode
      (insert "j")
    (vertico-next)))

(defun my/vertico-handle-k ()
  (interactive)
  (if my/vertico-insert-mode
      (insert "k")
    (vertico-previous)))

(defun my/vertico-handle-l ()
  (interactive)
  (if my/vertico-insert-mode
      (insert "l")
    (vertico-exit)))

;; Примечание: привязки к vertico-map вынесены в keybindings.el

(provide 'completion)
