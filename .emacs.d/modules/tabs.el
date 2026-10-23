;;; tabs.el --- Управление вкладками (tab-bar-mode) -*- lexical-binding: t; -*-

;; Отвечает за:
;; - включение tab-bar по требованию
;; - флаг my/tab-bar-enabled
;; - функции для создания/закрытия вкладок
;; - привязки вынесены в keybindings.el

(defvar my/tab-bar-enabled nil
  "Флаг, указывающий, включена ли панель вкладок.")

(defun my/enable-tab-bar-if-needed ()
  "Включить tab-bar-mode, если он ещё не включён."
  (unless my/tab-bar-enabled
    (tab-bar-mode 1)
    ;; Настройка цветов вкладок
    (custom-set-faces
     '(tab-bar ((t (:background "#1a1a1a"))))
     '(tab-bar-tab ((t (:foreground "#FF00FF" :weight bold :box (:line-width 2 :color "#FF00FF")))))
     '(tab-bar-tab-inactive ((t (:foreground "#4B00BB" :box (:line-width 1 :color "#4B00BB"))))))
    (setq my/tab-bar-enabled t)))

(provide 'tabs)
