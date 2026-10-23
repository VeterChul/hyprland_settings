;;; keybindings.el --- Единый файл для всех привязок клавиш -*- lexical-binding: t; -*-

;; Здесь собраны:
;; - глобальные привязки (global-set-key)
;; - привязки для Evil (normal, visual, insert) через evil-define-key
;; - привязки для минибуфера (vertico-map)
;; - привязки для dired-sidebar (dired-sidebar-mode-map)
;; - привязки для других пакетов (если необходимо)

;; Все привязки загружаются после загрузки соответствующих пакетов.

;; ============================================================
;; 1. Глобальные привязки (не зависят от Evil)
;; ============================================================

;; Стандартные
(global-set-key (kbd "C-x C-c") 'save-buffers-kill-emacs)
(global-set-key (kbd "C-x C-s") 'save-buffer)
(global-set-key (kbd "C-x C-f") 'find-file)
(global-set-key (kbd "C-x b")   'switch-to-buffer)
(global-set-key (kbd "C-x o")   'other-window)

;; Мои пользовательские
(global-set-key (kbd "C-s") 'save-buffer)                ; переопределение isearch
(global-set-key (kbd "C-b") 'consult-buffer)             ; вместо switch-to-buffer
(global-set-key (kbd "C-o") 'my/consult-find-other-window-vertically)
(global-set-key (kbd "C-S-o") 'my/consult-find-other-window-horizontally)
(global-set-key (kbd "C-d") 'my/find-file-in-new-window-vertically)
(global-set-key (kbd "C-S-d") 'my/find-file-in-new-window-horizontally)
(global-set-key (kbd "C-q") 'my/save-and-close-buffer)
(global-set-key (kbd "C-S-q") 'my/close-tab-or-kill-buffer) ; закрыть вкладку или буфер
(global-set-key (kbd "C-e") 'dired-sidebar-toggle-sidebar)

;; Навигация по окнам (windmove)
(global-set-key (kbd "C-h") 'windmove-left)
(global-set-key (kbd "C-l") 'windmove-right)
(global-set-key (kbd "C-j") 'windmove-down)
(global-set-key (kbd "C-k") 'windmove-up)

;; Перемещение буферов между окнами (buffer-move)
(global-set-key (kbd "C-S-h") 'buf-move-left)
(global-set-key (kbd "C-S-l") 'buf-move-right)
(global-set-key (kbd "C-S-j") 'buf-move-down)
(global-set-key (kbd "C-S-k") 'buf-move-up)

;; Копирование/вставка
(global-set-key (kbd "C-S-c") 'copy-region-as-kill)
(global-set-key (kbd "C-S-v") 'yank)

;; Проекты
(global-set-key (kbd "C-S-n") 'projectile-switch-project)
(global-set-key (kbd "C-S-p") 'projectile-add-known-project)

;; Гидры
(global-set-key (kbd "C-c s") 'my/settings-hydra/body)
(global-set-key (kbd "C-S-SPC") 'hydra-window-resize/body)

;; Терминал
(global-set-key (kbd "C-<return>") 'my/vterm-other-window-right)
(global-set-key (kbd "C-S-<return>") 'my/vterm-other-window-below)

;; OpenCode (C-u C-c o — перезапустить сессию)
(global-set-key (kbd "C-c o") 'my/opencode)

;; Вкладки (tab-bar) — активируются по требованию
(global-set-key (kbd "C-S-t")
                (lambda ()
                  (interactive)
                  (my/enable-tab-bar-if-needed)
                  (tab-bar-new-tab)
                  (my/startup-select-project)))
(global-set-key (kbd "C-<tab>") 'tab-bar-switch-to-next-tab)
(global-set-key (kbd "C-S-<iso-lefttab>") 'tab-bar-switch-to-prev-tab)

;; Переключение на вкладку по номеру (C-1 … C-9, C-0)
(dotimes (i 10)
  (let ((key (format "C-%d" i))
        (num (if (= i 0) 10 i)))
    (global-set-key (kbd key)
                    `(lambda () (interactive) (tab-bar-select-tab ,num)))))

;; Запуск файла (F5 — окно снизу на треть, S-F5 — авто-выбор окна)
(global-set-key (kbd "<f5>") 'my/run-file)
(global-set-key (kbd "S-<f5>") 'my/run-file-auto)

;; Игры
(global-set-key (kbd "C-c t") 'my/tetris)
(global-set-key (kbd "C-c p") 'my/pong)

;; ============================================================
;; 2. Привязки для Evil (normal, visual, insert)
;; ============================================================

(with-eval-after-load 'evil
  ;; ---- Normal mode ----
  (evil-define-key 'normal 'global
    (kbd "C-a") 'move-beginning-of-line
    (kbd "C-e") 'move-end-of-line
    (kbd "C-y") 'yank
    (kbd "C-u") 'universal-argument
    (kbd "C-f") 'forward-char
    (kbd "C-n") 'next-line
    (kbd "C-p") 'previous-line
    (kbd "C-d") 'my/find-file-in-new-window-vertically
    (kbd "C-o") 'consult-find
    (kbd "C-s") 'save-buffer
    (kbd "C-b") 'consult-buffer
    (kbd "C-q") 'my/save-and-close-buffer
    (kbd "C-S-q") 'my/close-tab-or-kill-buffer
    (kbd "C-S-d") 'my/find-file-in-new-window-horizontally
    (kbd "C-S-h") 'buf-move-left
    (kbd "C-S-l") 'buf-move-right
    (kbd "C-S-j") 'buf-move-down
    (kbd "C-S-k") 'buf-move-up
    (kbd "C-S-c") 'copy-region-as-kill
    (kbd "C-S-v") 'yank
    (kbd "C-S-SPC") 'hydra-window-resize/body
    (kbd "C-e") 'dired-sidebar-toggle-sidebar
    (kbd "C-<return>") 'my/vterm-other-window-right
    (kbd "C-S-t") (lambda () (interactive)
                    (my/enable-tab-bar-if-needed)
                    (tab-bar-new-tab)
                    (my/startup-select-project))
    (kbd "za") 'origami-recursively-toggle-node   ; Переключить текущую складку (как в Vim)
    (kbd "zc") 'origami-close-node                ; Закрыть текущую складку
    (kbd "zo") 'origami-open-node                 ; Открыть текущую складку
    (kbd "zM") 'origami-close-all-nodes           ; Закрыть все складки
    (kbd "zR") 'origami-open-all-nodes            ; Открыть все складки
    (kbd "zj") 'origami-forward-fold              ; Перейти к следующей складке
    (kbd "zk") 'origami-previous-fold             ; Перейти к предыдущей складке
    )

  ;; Добавляем привязки для вкладок по номерам через цикл (для normal)
  (dolist (i (number-sequence 0 9))
    (let ((key (format "C-%d" i))
          (num (if (= i 0) 10 i)))
      (evil-define-key 'normal 'global (kbd key)
        (lambda () (interactive) (tab-bar-select-tab num)))))

  ;; ---- Visual mode ----
  (evil-define-key 'visual 'global
    (kbd "C-a") 'move-beginning-of-line
    (kbd "C-e") 'move-end-of-line
    (kbd "C-y") 'yank
    (kbd "C-u") 'universal-argument
    (kbd "C-f") 'forward-char
    (kbd "C-n") 'next-line
    (kbd "C-p") 'previous-line
    (kbd "C-d") 'my/find-file-in-new-window-vertically
    (kbd "C-o") 'consult-find
    (kbd "C-s") 'save-buffer
    (kbd "C-b") 'consult-buffer
    (kbd "C-q") 'my/save-and-close-buffer
    (kbd "C-S-q") 'my/close-tab-or-kill-buffer
    (kbd "C-S-d") 'my/find-file-in-new-window-horizontally
    (kbd "C-S-h") 'buf-move-left
    (kbd "C-S-l") 'buf-move-right
    (kbd "C-S-j") 'buf-move-down
    (kbd "C-S-k") 'buf-move-up
    (kbd "C-S-c") 'copy-region-as-kill
    (kbd "C-S-v") 'yank
    (kbd "C-S-SPC") 'hydra-window-resize/body
    (kbd "C-e") 'dired-sidebar-toggle-sidebar
    (kbd "C-<return>") 'vterm
    (kbd "C-S-t") (lambda () (interactive)
                    (my/enable-tab-bar-if-needed)
                    (tab-bar-new-tab)
                    (my/startup-select-project)))

  ;; Добавляем привязки для вкладок в visual
  (dolist (i (number-sequence 0 9))
    (let ((key (format "C-%d" i))
          (num (if (= i 0) 10 i)))
      (evil-define-key 'visual 'global (kbd key)
        (lambda () (interactive) (tab-bar-select-tab num)))))

  ;; ---- Insert mode ----
  (evil-define-key 'insert 'global
    (kbd "C-d") 'my/find-file-in-new-window-vertically
    (kbd "C-q") 'my/save-and-close-buffer
    (kbd "C-o") 'consult-find
    (kbd "C-s") 'save-buffer
    (kbd "C-b") 'consult-buffer
    (kbd "C-<return>") 'vterm
    (kbd "C-e") 'dired-sidebar-toggle-sidebar))


;; ============================================================
;; 4. Привязки для Dired-sidebar
;; ============================================================

(with-eval-after-load 'dired-sidebar
  ;; Навигация
  (define-key dired-sidebar-mode-map (kbd "j") 'dired-next-line)
  (define-key dired-sidebar-mode-map (kbd "k") 'dired-previous-line)
  (define-key dired-sidebar-mode-map (kbd "TAB") 'dired-subtree-toggle)
  (define-key dired-sidebar-mode-map (kbd "l") 'my-dired-sidebar-open)
  (define-key dired-sidebar-mode-map (kbd "h") 'my-dired-sidebar-open)

  ;; Операции с файлами
  (define-key dired-sidebar-mode-map (kbd "a") 'dired-create-directory)       ; создать папку
  (define-key dired-sidebar-mode-map (kbd "+") 'dired-create-directory)
  (define-key dired-sidebar-mode-map (kbd "N") 'my/dired-create-file)         ; создать файл
  (define-key dired-sidebar-mode-map (kbd "D") 'dired-flag-file-deletion)     ; пометить на удаление
  (define-key dired-sidebar-mode-map (kbd "x") 'dired-do-flagged-delete)      ; удалить
  (define-key dired-sidebar-mode-map (kbd "R") 'dired-do-rename)              ; переименовать
  (define-key dired-sidebar-mode-map (kbd "C") 'dired-do-copy)                ; копировать

  ;; Переходы
  (define-key dired-sidebar-mode-map (kbd "~") 'my/dired-go-home)             ; домашняя папка
  (define-key dired-sidebar-mode-map (kbd "^") 'my/dired-go-project-root)     ; корень проекта (если есть)
  (define-key dired-sidebar-mode-map (kbd "/") 'my/dired-go-root)             ; корень ФС

  ;; Утилиты
  (define-key dired-sidebar-mode-map (kbd "y") 'my/dired-copy-path)           ; скопировать путь
  (define-key dired-sidebar-mode-map (kbd "s") 'my/dired-search-name)         ; поиск по имени
  (define-key dired-sidebar-mode-map (kbd ".") 'my/dired-toggle-hidden)       ; показать скрытые

  ;; Обновление
  (define-key dired-sidebar-mode-map (kbd "g") 'dired-revert)
  (define-key dired-sidebar-mode-map (kbd "?") 'dired-summary))


;; ============================================================
;; 3. Привязки для минибуфера (Vertico)
;; ============================================================

(with-eval-after-load 'vertico
  (define-key vertico-map (kbd "h") 'my/vertico-handle-h)
  (define-key vertico-map (kbd "j") 'my/vertico-handle-j)
  (define-key vertico-map (kbd "k") 'my/vertico-handle-k)
  (define-key vertico-map (kbd "l") 'my/vertico-handle-l)
  (define-key vertico-map (kbd "i") 'my/vertico-toggle-insert)
  (define-key vertico-map (kbd "ESC") (lambda () (interactive)
                                        (setq my/vertico-insert-mode nil)
                                        (message "Навигация")))
  ;; Русские буквы (если нужны)
  (define-key vertico-map (kbd "р") 'my/vertico-handle-h)
  (define-key vertico-map (kbd "о") 'my/vertico-handle-j)
  (define-key vertico-map (kbd "л") 'my/vertico-handle-k)
  (define-key vertico-map (kbd "д") 'my/vertico-handle-l))

;; ============================================================
;; Привязки для vterm (терминал)
;; ============================================================

(with-eval-after-load 'vterm
  ;; Копирование/вставка (безопасны)
  (define-key vterm-mode-map (kbd "C-S-c") 'copy-region-as-kill)
  (define-key vterm-mode-map (kbd "C-S-v") 'yank)

  ;; Вход в режим копирования (где Emacs перехватывает все клавиши)
  (define-key vterm-mode-map (kbd "ESC") 'vterm-copy-mode)
  (define-key vterm-mode-map (kbd "C-c C-c") 'vterm-copy-mode)

  (define-key vterm-mode-map (kbd "C-h") 'windmove-left)
  (define-key vterm-mode-map (kbd "C-l") 'windmove-right)
  (define-key vterm-mode-map (kbd "C-j") 'windmove-down)
  (define-key vterm-mode-map (kbd "C-k") 'windmove-up)
  )

(provide 'keybindings)
