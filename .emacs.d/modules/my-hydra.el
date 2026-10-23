;;; hydra.el --- Гидры для быстрых настроек и изменения окон -*- lexical-binding: t; -*-

;; Отвечает за:
;; - гидру my/settings-hydra (номера, тема, шрифт, PDF)
;; - гидру hydra-window-resize (размеры окон)
;; - привязки для вызова гидр вынесены в keybindings.el

;; ------------------------------------------------------------
;; Функция переключения темы my-kitty
;; ------------------------------------------------------------
(defun my/load-kitty-theme ()
  "Отключить все темы и загрузить my-kitty."
  (interactive)
  (mapc #'disable-theme custom-enabled-themes)
  (load-theme 'my-kitty t)
  (message "Тема my-kitty загружена"))

;; ------------------------------------------------------------
;; Hydra настроек
;; ------------------------------------------------------------
(defhydra my/settings-hydra (:color red :hint nil)
  "
^Настройки^
------------------------------------------------------
[_n_] Номера строк (toggle)      [_t_] Тема (следующая)
[_r_] Относительные/абсолютные   [_T_] Тема my-kitty
[_f_] Размер шрифта +            [_s_] Размер шрифта -
[_h_] Справка                    [_q_] Выйти
[_p_] Авто-PDF для TeX (toggle)
"
  ("n" (progn
         (global-display-line-numbers-mode 'toggle)
         (message "Номера строк: %s" (if global-display-line-numbers-mode "вкл" "выкл"))))
  ("r" (progn
         (setq-local display-line-numbers-type (if (eq display-line-numbers-type 'relative) 'absolute 'relative))
         (display-line-numbers-mode -1)
         (display-line-numbers-mode 1)
         (message "Режим номеров в текущем буфере: %s" (if (eq display-line-numbers-type 'relative) "относительные" "абсолютные"))))
  ("t" (progn
         (load-theme (car (cdr (member (car custom-enabled-themes) (custom-available-themes)))) t)
         (message "Тема изменена")))
  ("T" (my/load-kitty-theme))
  ("f" (text-scale-increase 1))
  ("s" (text-scale-decrease 1))
  ("h" (describe-function 'display-line-numbers-mode))
  ("p" (progn
         (setq my/auto-open-pdf-for-tex (not my/auto-open-pdf-for-tex))
         (message "Авто-открытие PDF для TeX: %s" (if my/auto-open-pdf-for-tex "включено" "выключено"))))
  ("q" nil "выйти" :color blue))

;; ------------------------------------------------------------
;; Hydra изменения размеров окон
;; ------------------------------------------------------------
(defvar my/resize-step 5
  "Количество строк/колонок для изменения размера окна.")

(defun my/enlarge-window-h ()
  (interactive) (enlarge-window-horizontally my/resize-step))
(defun my/shrink-window-h ()
  (interactive) (shrink-window-horizontally my/resize-step))
(defun my/enlarge-window-v ()
  (interactive) (enlarge-window my/resize-step))
(defun my/shrink-window-v ()
  (interactive) (shrink-window my/resize-step))

(defhydra hydra-window-resize (:color red :hint nil)
  "
^Resize Window^
---------------------------------------------
_h_: уменьшить ширину    _l_: увеличить ширину
_j_: увеличить высоту    _k_: уменьшить высоту
_SPC_: сбросить размер   _q_: выйти
"
  ("h" my/shrink-window-h)
  ("l" my/enlarge-window-h)
  ("j" my/enlarge-window-v)
  ("k" my/shrink-window-v)
  ("SPC" (lambda () (interactive) (balance-windows) (hydra-window-resize/body)))
  ("q" nil "quit" :color blue))

(provide 'my-hydra)
