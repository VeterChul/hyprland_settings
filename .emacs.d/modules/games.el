;;; games.el --- Тетрис и Пинг-понг -*- lexical-binding: t; -*-

;; Отвечает за:
;; - функции my/tetris и my/pong с выбором открытия
;; - привязки вынесены в keybindings.el

(defun my/open-game-in-popup (game-function)
  "Открыть игру GAME-FUNCTION в новом плавающем фрейме поверх остальных окон."
  (let ((frame (make-frame '((width . 80)
                             (height . 40)
                             (top . 100)
                             (left . 200)
                             (undecorated . t)
                             (name . "Emacs Game")))))
    (select-frame-set-input-focus frame)
    (funcall game-function)))

(defun my/open-game-in-split (game-function)
  "Открыть игру GAME-FUNCTION в новом окне (сплите)."
  (if (> (window-body-width) (window-body-height))
      (split-window-right)
    (split-window-below))
  (other-window 1)
  (funcall game-function))

(defun my/tetris (&optional arg)
  "Открыть Тетрис. С префиксом C-u открыть в сплите, иначе в плавающем фрейме."
  (interactive "P")
  (if arg
      (my/open-game-in-popup 'tetris)
    (my/open-game-in-split 'tetris)))

(defun my/pong (&optional arg)
  "Открыть Пинг-понг. С префиксом C-u открыть в сплите, иначе в плавающем фрейме."
  (interactive "P")
  (if arg
      (my/open-game-in-popup 'pong)
    (my/open-game-in-split 'pong)))

(provide 'games)
