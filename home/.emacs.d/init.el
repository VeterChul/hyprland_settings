;;; init.el --- Главный файл конфигурации -*- lexical-binding: t; -*-
;;; ~/.emacs.d/init.el
;; Главный загрузочный файл. Подключает пакеты и загружает модули из папки modules/.

;; Настройка package и use-package
(require 'package)
(setq package-archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                         ("melpa" . "https://melpa.org/packages/")))
(package-initialize)

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(require 'use-package)
(setq use-package-always-ensure t)

;; Путь к пользовательским модулям
(add-to-list 'load-path (expand-file-name "modules" user-emacs-directory))
;; Путь к пользовательским lisp-файлам (если есть)
(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))
;;
;; Добавляем путь к вручную установленному company
(add-to-list 'load-path (expand-file-name "site-lisp/company" user-emacs-directory))

;; Загружаем компанию
(require 'company)

(global-company-mode 1)   ; включаем глобально
;; Загрузка модулей в правильном порядке
(require 'core)          ; базовые настройки
(require 'packages)      ; установка и настройка всех пакетов через use-package
(require 'functions)     ; все пользовательские функции
(require 'evil-config)          ; настройки Evil (без привязок)
(require 'completion)    ; Vertico, Consult, Marginalia
(require 'ui-config)            ; внешний вид
(require 'my-project)       ; было project
(require 'my-vterm)         ; было vterm
(require 'my-opencode)      ; OpenCode в терминале
(require 'my-compile)       ; было compile
(require 'latex)         ; LaTeX-специфика
(require 'tabs)          ; вкладки tab-bar
(require 'games)         ; игры
(require 'my-hydra)         ; было hydra
(require 'keybindings)   ; ВСЕ привязки клавиш (загружаем последним)
(require 'misc)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(all-the-icons-dired buffer-move company consult dired-sidebar
			 dockerfile-mode dracula-theme evil marginalia
			 neotree nerd-icons origami projectile quelpa
			 tetris-60 treemacs vertico vterm yaml-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(mode-line ((t (:foreground "#FF00FF" :background "#222" :box (:line-width 2 :color "#FF00FF")))))
 '(mode-line-inactive ((t (:foreground "#4B00BB" :background "#111" :box (:line-width 1 :color "#4B00BB"))))))
