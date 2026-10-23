;;; ui.el --- Настройка внешнего вида: темы, номера строк, модельна, прозрачность -*- lexical-binding: t; -*-

;; Отвечает за:
;; - загрузку темы (если не в early-init) – у вас она уже в early-init
;; - настройку номеров строк
;; - цвета модельна
;; - прозрачность (если меняется динамически)
;; - прочие визуальные параметры

;; ------------------------------------------------------------
;; Номера строк
;; ------------------------------------------------------------
(setq display-line-numbers-type 'relative)   ; относительные номера

;; Включаем номера в основных режимах
(add-hook 'prog-mode-hook 'display-line-numbers-mode)
(add-hook 'text-mode-hook 'display-line-numbers-mode)
(add-hook 'markdown-mode-hook 'display-line-numbers-mode)
(add-hook 'conf-mode-hook 'display-line-numbers-mode)
(add-hook 'yaml-mode-hook 'display-line-numbers-mode)
(add-hook 'dockerfile-mode-hook 'display-line-numbers-mode)

;; ------------------------------------------------------------
;; Цвета модельна (перенесено из custom-set-faces)
;; ------------------------------------------------------------
(custom-set-faces
 '(mode-line ((t (:foreground "#FF00FF" :background "#222" :box (:line-width 2 :color "#FF00FF")))))
 '(mode-line-inactive ((t (:foreground "#4B00BB" :background "#111" :box (:line-width 1 :color "#4B00BB"))))))

;; ------------------------------------------------------------
;; Прозрачность (у вас задана в early-init, но дублируем на случай)
;; ------------------------------------------------------------
(when (functionp 'set-frame-parameter)
  (set-frame-parameter nil 'alpha-background 85)
  (add-to-list 'default-frame-alist '(alpha-background . 85)))

;; ------------------------------------------------------------
;; Отключаем GUI-элементы (дублируем из early-init, но оставим на всякий)
;; ------------------------------------------------------------
(menu-bar-mode -1)
(tool-bar-mode -1)
(scroll-bar-mode -1)
(add-to-list 'default-frame-alist '(undecorated . t))

;; ------------------------------------------------------------
;; Подавление перерисовки (уже есть в early-init, здесь не нужно)
;; ------------------------------------------------------------

(provide 'ui-config)
