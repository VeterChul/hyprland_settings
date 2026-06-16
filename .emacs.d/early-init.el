;;; ~/.emacs.d/early-init.el
;; Загружается перед init.el, до появления окна GUI.

;; 1. Указываем путь к папке с кастомными темами
;; (чтобы Emacs смог найти my-kitty-theme)
(add-to-list 'custom-theme-load-path
             (expand-file-name "themes" user-emacs-directory))

;; 2. Немедленно загружаем тёмную тему, чтобы сразу убрать белый фон
(load-theme 'my-kitty t)

;; 3. Дополнительно: убираем нежелательную перерисовку и мерцание
(setq frame-inhibit-implied-resize t) ; отключаем автоматический ресайз фрейма на старте[reference:4]
(setq-default inhibit-redisplay t)    ; запрещаем перерисовку до полной готовности
(setq-default inhibit-message t)      ; подавляем лишние сообщения

;; 4. Включаем отображение обратно после полной загрузки Emacs
(add-hook 'window-setup-hook
          (lambda ()
            (setq-default inhibit-redisplay nil
                          inhibit-message nil)
            (redisplay)))
