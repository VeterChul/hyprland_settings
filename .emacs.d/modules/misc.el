;;; misc.el --- Разные мелкие настройки, не вошедшие в другие модули -*- lexical-binding: t; -*-

;; Отвечает за:
;; - подавление предупреждений dired-sidebar
;; - возможно, другие настройки, которые появятся позже

;; Подавление предупреждения о лице dired-sidebar-directory
(advice-add 'display-warning :around
            (lambda (orig-fn type message &rest args)
              "Подавить предупреждения, содержащие 'dired-sidebar-directory'."
              (unless (string-match-p "dired-sidebar-directory" (apply #'format message args))
                (apply orig-fn type message args))))

(provide 'misc)

;; Копирование/вставка
(global-set-key (kbd "C-S-c") 'copy-region-as-kill)
(global-set-key (kbd "C-S-v") 'yank)

;;; Перенаправление временных файлов в ~/.emacs.d/cache/
(defvar my/cache-dir (expand-file-name "~/.emacs.d/cache/"))
(make-directory my/cache-dir t)   ; создаём основную папку, если её нет

;; Подпапки
(defvar my/backup-dir (expand-file-name "backups/" my/cache-dir))
(defvar my/auto-save-dir (expand-file-name "auto-save/" my/cache-dir))
(defvar my/auto-save-list-dir (expand-file-name "auto-save-list/" my/cache-dir))
(defvar my/eln-cache-dir (expand-file-name "eln-cache/" my/cache-dir))
(defvar my/transient-dir (expand-file-name "transient/" my/cache-dir))
(defvar my/elpa-dir (expand-file-name "elpa/" my/cache-dir))

;; Создаём все подпапки
(dolist (dir (list my/backup-dir my/auto-save-dir my/auto-save-list-dir
                   my/eln-cache-dir my/transient-dir my/elpa-dir))
  (make-directory dir t))

;; 1. Бэкапы (~file)
(setq backup-directory-alist `(("." . ,my/backup-dir)))
(setq make-backup-files t)
(setq backup-by-copying t)

;; 2. Автосохранения (#file#)
(setq auto-save-file-name-transforms
      `((".*" ,my/auto-save-dir t)))

;; 3. Список автосохранений
(setq auto-save-list-file-prefix (expand-file-name "auto-save-list/" my/cache-dir))

;; 4. Блокировочные файлы (.filelock) – отключаем (не создаём)
(setq create-lockfiles nil)

;; 5. История файлов, закладки, позиции
(setq recentf-save-file (expand-file-name "recentf" my/cache-dir))
(setq bookmark-default-file (expand-file-name "bookmarks" my/cache-dir))
(setq save-place-file (expand-file-name "saveplace" my/cache-dir))

;; 6. Пакеты (это критично – должно быть до `package-initialize`)
(setq package-user-dir my/elpa-dir)

;; 7. Native compilation (eln-кэш)
(setq native-comp-eln-load-path (list my/eln-cache-dir))

;; 8. Projectile
(setq projectile-known-projects-file (expand-file-name "projectile-bookmarks.eld" my/cache-dir))

;; 9. Transient
(setq transient-directory my/transient-dir)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(all-the-icons-dired buffer-move company consult dired-sidebar
			 dockerfile-mode dracula-theme evil marginalia
			 neotree nerd-icons projectile quelpa
			 tetris-60 treemacs vertico vterm yaml-mode)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(mode-line ((t (:foreground "#FF00FF" :background "#222" :box (:line-width 2 :color "#FF00FF")))))
 '(mode-line-inactive ((t (:foreground "#4B00BB" :background "#111" :box (:line-width 1 :color "#4B00BB"))))))

(setq projectile-global-ignore-file-patterns
      '("^\\..*"          ; файлы и папки, начинающиеся с точки
        "^\\.git/"        ; .git (на всякий случай)
        "^node_modules/"  ; если нужно
        ))
