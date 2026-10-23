;;; core.el --- Базовые настройки, не зависящие от пакетов -*- lexical-binding: t; -*-

;; Отвечает за:
;; - системный буфер обмена
;; - отключение стартового экрана
;; - начальный буфер
;; - прочие глобальные переменные

;; Буфер обмена
(setq select-enable-clipboard t)   ; копировать в CLIPBOARD
(setq select-enable-primary t)     ; также в PRIMARY (средняя кнопка мыши)

;; Отключаем стартовый экран и сообщения
(setq inhibit-startup-screen t)
(setq initial-buffer-choice nil)
(setq inhibit-startup-message t)

;; Подавляем лишние сообщения во время загрузки (дублируем из early-init, но на всякий случай)
(setq-default inhibit-message t)
(add-hook 'window-setup-hook
          (lambda ()
            (setq-default inhibit-message nil)))

;; Убиваем буфер *GNU Emacs* после загрузки
(add-hook 'window-setup-hook
          (lambda ()
            (when (get-buffer "*GNU Emacs*")
              (kill-buffer "*GNU Emacs*"))))

(provide 'core)
