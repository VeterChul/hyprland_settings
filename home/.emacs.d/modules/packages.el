;;; packages.el --- Установка и настройка всех пакетов -*- lexical-binding: t; -*-

;; Здесь собраны все use-package блоки.
;; Каждый пакет настраивается в своём блоке.

;; (require 'use-package) уже выполнено в init.el

;; ------------------------------------------------------------
;; YAML и Dockerfile
;; ------------------------------------------------------------
(use-package yaml-mode
  :ensure t
  :hook (yaml-mode . evil-local-mode))

(use-package dockerfile-mode
  :ensure t
  :hook (dockerfile-mode . evil-local-mode))

;; ------------------------------------------------------------
;; Терминал
;; ------------------------------------------------------------
(use-package vterm
  :ensure t)

;; ------------------------------------------------------------
;; Управление проектами
;; ------------------------------------------------------------
(use-package projectile
  :ensure t
  :config
  (projectile-mode +1)
  )

;; ------------------------------------------------------------
;; Поиск и выбор
;; ------------------------------------------------------------
(use-package consult
  :ensure t
  :config
  ;; Аргументы для fd, чтобы исключить скрытые файлы (обычно это поведение по умолчанию)
  (setq consult-fd-args '("fd" "--color=never" "--hidden" "--exclude" ".git")))


(use-package vertico
  :ensure t
  :init
  (vertico-mode 1))

(use-package marginalia
  :ensure t
  :init
  (marginalia-mode 1))

;; ------------------------------------------------------------
;; Quelpa (для установки пакетов из репозиториев)
;; ------------------------------------------------------------
(use-package quelpa
  :ensure t
  :config
  (setq quelpa-update-melpa-p t))

;; ------------------------------------------------------------
;; Перемещение буферов между окнами
;; ------------------------------------------------------------
(use-package buffer-move
  :ensure t)

;; ------------------------------------------------------------
;; Evil (основной режим редактирования)
;; ------------------------------------------------------------
(use-package evil
  :ensure t
  :init
  (setq evil-want-keybinding nil)   ; не переопределять глобальные бинды
  (setq evil-want-C-u-scroll t)     ; C-u в нормальном режиме скроллит вверх
  (setq evil-want-C-i-jump t)       ; C-i для перехода к следующей позиции
  :config
  ;; Включаем Evil в режимах редактирования
  (add-hook 'prog-mode-hook 'evil-local-mode)
  (add-hook 'text-mode-hook 'evil-local-mode)
  (add-hook 'markdown-mode-hook 'evil-local-mode)
  (add-hook 'conf-mode-hook 'evil-local-mode)
  (add-hook 'yaml-mode-hook 'evil-local-mode)
  (add-hook 'dockerfile-mode-hook 'evil-local-mode))

;; ------------------------------------------------------------
;; Dired-subtree для раскрытия папок в dired
;; ------------------------------------------------------------
(use-package dired-subtree
  :ensure t)

;; ------------------------------------------------------------
;; Иконки
;; ------------------------------------------------------------
(use-package all-the-icons
  :ensure t)

;; ------------------------------------------------------------
;; Dired-sidebar (панель файлового менеджера)
;; ------------------------------------------------------------
(use-package dired-sidebar
  :ensure t
  :after (projectile evil all-the-icons)
  :config
  (setq dired-sidebar-use-projectile t)
  (setq dired-sidebar-use-one-instance t)
  (setq dired-sidebar-refresh-on-project-switch t)
  (setq dired-sidebar-width 35)
  (setq dired-sidebar-theme 'icons)
  (setq dired-sidebar-display-alist '((side . left) (slot . 0)))
  (setq dired-sidebar-subtree-mode t)

  ;; Настройка лиц — оборачиваем в with-eval-after-load, чтобы лицо было определено
  (with-eval-after-load 'dired-sidebar
    (set-face-attribute 'dired-sidebar-directory nil :foreground "DodgerBlue" :weight 'bold)
    (set-face-attribute 'dired-sidebar-ignored nil :foreground "gray40"))

  ;; Включаем dired-subtree-mode в буфере панели
  (add-hook 'dired-sidebar-mode-hook
            (lambda ()
              (dired-subtree-mode 1)
              (setq-local dired-subtree-use-mouse nil))))
;; ------------------------------------------------------------
;; (Опционально) Company — автодополнение (пока закомментировано)
;; ------------------------------------------------------------
;; (use-package company
;;   :ensure t
;;   :config
;;   (global-company-mode 1)
;;   (setq company-idle-delay 0.2)
;;   (setq company-minimum-prefix-length 2)
;;   (setq company-tooltip-limit 15)
;;   (setq company-show-numbers t))

;; ------------------------------------------------------------
;; Автодополнение (Company)
;; ------------------------------------------------------------
(use-package company
  :ensure nil
  :demand t
  :config
  ;; Глобальное включение
  (global-company-mode 1)

  ;; Задержка перед появлением подсказок (сек)
  (setq company-idle-delay 0.1)

  ;; Минимальное количество символов для запуска
  (setq company-minimum-prefix-length 2)

  ;; Количество кандидатов в тултипе
  (setq company-tooltip-limit 15)

  ;; Показывать номера кандидатов (для быстрого выбора)
  (setq company-show-numbers t)

  (setq company-frontends
      '(company-pseudo-tooltip-unless-just-one-frontend
        company-preview-if-just-one-frontend
        company-echo-metadata-frontend))
  ;; Бэкенды: порядок важен — сначала файлы, потом dabbrev, потом ключевые слова
  (setq company-backends
        '((company-files          ; автодополнение путей
           company-dabbrev-code   ; слова из кода
           company-keywords       ; ключевые слова языка
           company-dabbrev)       ; слова из всех буферов (текст)
          ))

  ;; Для C/C++ добавим clang (если он установлен)
  (when (executable-find "clang")
    (add-to-list 'company-backends 'company-clang))

  ;; Настройка навигации в списке кандидатов
  (define-key company-active-map (kbd "C-n") 'company-select-next)
  (define-key company-active-map (kbd "C-p") 'company-select-previous)
  (define-key company-active-map (kbd "TAB") 'company-complete-common-or-cycle)
  (define-key company-active-map (kbd "<return>") 'company-complete-selection))
(provide 'packages)

;; ------------------------------------------------------------
;; Сворачивание кода (origami)
;; ------------------------------------------------------------
(use-package origami
  :ensure t
  :config
  ;; Включаем origami для всех буферов с кодом и текстом
  (add-hook 'prog-mode-hook #'origami-mode)
  (add-hook 'text-mode-hook #'origami-mode))
