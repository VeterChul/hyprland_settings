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
)

;; Очень важный момент: делаем тему доступной для Emacs
(provide-theme 'my-kitty)
