;;; vterm.el --- Функции для работы с vterm -*- lexical-binding: t; -*-

;; Отвечает за:
;; - функции открытия vterm в вертикальном/горизонтальном сплите
;; - привязки вынесены в keybindings.el

(defun my/vterm-other-window-right ()
  "Открыть новый терминал в вертикальном сплите (справа)."
  (interactive)
  (split-window-right)
  (other-window 1)
  (let ((buf (generate-new-buffer-name "*vterm*")))
    (vterm buf)))

(defun my/vterm-other-window-below ()
  "Открыть новый терминал в горизонтальном сплите (снизу)."
  (interactive)
  (split-window-below)
  (other-window 1)
  (let ((buf (generate-new-buffer-name "*vterm*")))
    (vterm buf)))

(provide 'my-vterm)
