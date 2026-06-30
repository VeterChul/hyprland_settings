;;; ~/.emacs.d/themes/my-kitty-theme.el
(deftheme my-kitty "A custom theme based on my Kitty terminal colors.")

(custom-theme-set-faces
 'my-kitty

 ;; Базовая настройка фона и основного текста
 '(default ((t (:background "#000000" :foreground "#ff00ff"))))
 '(cursor ((t (:background "#00ffaa"))))
 '(region ((t (:background "#aa00aa"))))

 ;; Базовые элементы интерфейса
 '(mode-line ((t (:background "#333333" :foreground "#ff00ff"))))
 '(mode-line-inactive ((t (:background "#222222" :foreground "#888888"))))

 ;; Цвета синтаксиса (Font Lock)
 '(font-lock-builtin-face ((t (:foreground "#00ffaa"))))
 '(font-lock-comment-face ((t (:foreground "#999999"))))
 '(font-lock-constant-face ((t (:foreground "#f1fa8c"))))
 '(font-lock-function-name-face ((t (:foreground "#bd93f9"))))
 '(font-lock-keyword-face ((t (:foreground "#ff79c6"))))
 '(font-lock-string-face ((t (:foreground "#8be9fd"))))
 '(font-lock-type-face ((t (:foreground "#00ffaa"))))
 '(font-lock-variable-name-face ((t (:foreground "#f8f8f2"))))
 ;; Вкладки
'(tab-bar ((t (:background "#1a1a1a" :foreground "#ff00ff"))))
'(tab-bar-tab ((t (:foreground "#FF00FF" :weight bold :box (:line-width 2 :color "#FF00FF")))))
'(tab-bar-tab-inactive ((t (:foreground "#4B00BB" :box (:line-width 1 :color "#4B00BB")))))

;; Разделители окон
'(vertical-border ((t (:foreground "#333333"))))

;; Поля
'(fringe ((t (:background "#000000" :foreground "#666666"))))

;; Минибуфер
'(minibuffer-prompt ((t (:foreground "#bd93f9" :weight bold))))

;; Поиск и выделение
'(isearch ((t (:background "#ff00ff" :foreground "#000000"))))
'(isearch-fail ((t (:background "#ff79c6" :foreground "#000000"))))
'(highlight ((t (:background "#444444"))))
'(match ((t (:background "#f1fa8c" :foreground "#000000"))))

;; Кроме того, добавьте определение для `dired-sidebar-face`, если оно у вас используется
'(dired-sidebar-face ((t (:foreground "#ff00ff"))))
)

;; Очень важный момент: делаем тему доступной для Emacs
(provide-theme 'my-kitty)
