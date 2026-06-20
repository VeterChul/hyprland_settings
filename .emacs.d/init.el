
;; Включить поддержку системного буфера обмена
(setq select-enable-clipboard t)   ; копировать в CLIPBOARD
(setq select-enable-primary t)     ; также в PRIMARY (средняя кнопка мыши)

;; Привязка Ctrl+Shift+C для копирования выделенного текста
(global-set-key (kbd "C-S-c") 'copy-region-as-kill)

;; Привязка Ctrl+Shift+V для вставки из системного буфера
(global-set-key (kbd "C-S-v") 'yank)

;; Настройка менеджера пакетов
(require 'package)
(setq package-archives '(("gnu"   . "https://elpa.gnu.org/packages/")
                         ("nongnu" . "https://elpa.nongnu.org/nongnu/")
                         ("melpa" . "https://melpa.org/packages/")))  ; <- http вместо httpsjj

(package-initialize)


;; Установка use-package, если его ещё нет
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

;; Загрузка use-package и настройка автоматической установки пакетов
(require 'use-package)
(setq use-package-always-ensure t)
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(package-selected-packages
   '(all-the-icons all-the-icons-dired consult dired-subtree
		   dracula-theme hydra nerd-icons projectile quelpa
		   vterm)))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 )

(add-to-list 'load-path (expand-file-name "lisp" user-emacs-directory))

(require 'hydra)


;; Терминал
(use-package vterm
  :ensure t)

;; ;; Управление проектами
(use-package projectile
  :ensure t
  :config
  (projectile-mode +1))

;; ;; Поиск файлов и буферов
(use-package consult
  :ensure t)

;; Vertico — улучшенный интерфейс для выбора
(use-package vertico
  :ensure t
  :init
  (vertico-mode 1))

;; Marginalia — добавляет аннотации к кандидатам (красиво)
(use-package marginalia
  :ensure t
  :init
  (marginalia-mode 1))

(use-package quelpa
  :ensure t
  :config
  (setq quelpa-update-melpa-p t))   ; обновлять MELPA перед сборкой

(use-package buffer-move
  :ensure t)

(use-package evil
  :ensure t
  :init
  (setq evil-want-keybinding nil)   ; не переопределять глобальные бинды
  (setq evil-want-C-u-scroll t)     ; C-u в нормальном режиме скроллит вверх (как в Vim)
  (setq evil-want-C-i-jump t)       ; C-i для перехода к следующей позиции (как в Vim)
  :config
  ;; Включаем Evil только в режимах, предназначенных для редактирования кода и текста
  (add-hook 'prog-mode-hook 'evil-local-mode)
  (add-hook 'text-mode-hook 'evil-local-mode)
  )



(setq global-map (make-sparse-keymap))

;; Базовые команды, которые должны остаться:
(global-set-key (kbd "C-x C-c") 'save-buffers-kill-emacs)   ; выход
(global-set-key (kbd "C-x C-s") 'save-buffer)               ; сохранить файл
(global-set-key (kbd "C-x C-f") 'find-file)                 ; открыть файл
(global-set-key (kbd "C-x b")   'switch-to-buffer)          ; переключить буфер
(global-set-key (kbd "C-x o")   'other-window)              ; переключить окно

;; Ваши пользовательские бинды (повторяем их здесь для надёжности)
(global-set-key (kbd "C-s") 'save-buffer)
(global-set-key (kbd "C-b") 'consult-buffer)

(defun my/vterm-other-window-vertically ()
  (interactive)
  (split-window-right)
  (other-window 1)
  (vterm))

(defun my/vterm-other-window-horizontally ()
  (interactive)
  (split-window-below)
  (other-window 1)
  (vterm))

(global-set-key (kbd "C-<return>") 'my/vterm-other-window-vertically)
(global-set-key (kbd "C-S-<return>") 'my/vterm-other-window-horizontally)


;; ============================================================
;; Открытие результатов consult-find в новом окне
;; ============================================================

(defun my/consult-find-other-window-vertically ()
  "Найти файл и открыть его в вертикальном сплите (справа)."
  (interactive)
  (let ((file (consult-find)))
    (when file
      (my/find-file-in-new-window-vertically (file-relative-name file)))))

(defun my/consult-find-other-window-horizontally ()
  "Найти файл и открыть его в горизонтальном сплите (снизу)."
  (interactive)
  (let ((file (consult-find)))
    (when file
      (my/find-file-in-new-window-horizontally (file-relative-name file)))))

(global-set-key (kbd "C-o") 'my/consult-find-other-window-vertically)   ; вертикально (заменяет старый C-o)
(global-set-key (kbd "C-S-o") 'my/consult-find-other-window-horizontally) ; горизонтально

;; ============================================================
;; Открытие файла в новом окне (всегда создавая сплит)
;; ============================================================

(defun my/find-file-in-new-window-vertically ()
  "Открыть файл в новом вертикальном сплите (справа)."
  (interactive)
  (split-window-right)          ; делим текущее окно вертикально
  (other-window 1)              ; переключаемся в новое окно
  (call-interactively 'find-file)) ; открываем файл

(defun my/find-file-in-new-window-horizontally ()
  "Открыть файл в новом горизонтальном сплите (снизу)."
  (interactive)
  (split-window-below)          ; делим текущее окно горизонтально
  (other-window 1)              ; переключаемся в новое окно
  (call-interactively 'find-file)) ; открываем файл

;; Привязываем к клавишам
(global-set-key (kbd "C-d") 'my/find-file-in-new-window-vertically)   ; вертикальный сплит
(global-set-key (kbd "C-S-d") 'my/find-file-in-new-window-horizontally) ; горизонтальный сплит (Shift+D)

(defun my/save-and-close-buffer ()
  "Сохранить буфер (если изменён) и закрыть окно с этим буфером."
  (interactive)
  (when (and (buffer-modified-p)
             (y-or-n-p "Save buffer? "))
    (save-buffer))
  (quit-window t))   ; t означает: убить буфер и закрыть окно

(defun my/save-and-kill-selected-buffer ()
  "Выбрать буфер, сохранить (если изменён) и закрыть его."
  (interactive)
  (let* ((buf (consult-buffer))   ; выбираем буфер через consult
         (buf (if (listp buf) (car buf) buf))) ; consult-buffer может вернуть список
    (when (bufferp buf)
      (with-current-buffer buf
        (when (buffer-modified-p)
          (save-buffer)))
      (kill-buffer buf))))


(global-set-key (kbd "C-q") 'my/save-and-close-buffer)

;; Привязываем к C-S-w
(global-set-key (kbd "C-S-q") 'my/save-and-kill-selected-buffer)

;; Навигация по окнам
(global-set-key (kbd "C-h") 'windmove-left)
(global-set-key (kbd "C-l") 'windmove-right)
(global-set-key (kbd "C-j") 'windmove-down)
(global-set-key (kbd "C-k") 'windmove-up)

;; Глобальные привязки (работают в любом режиме)
(global-set-key (kbd "C-S-h") 'buf-move-left)
(global-set-key (kbd "C-S-l") 'buf-move-right)
(global-set-key (kbd "C-S-j") 'buf-move-down)
(global-set-key (kbd "C-S-k") 'buf-move-up)

;; Копирование/вставка
(global-set-key (kbd "C-S-c") 'copy-region-as-kill)
(global-set-key (kbd "C-S-v") 'yank)

(defvar my/vertico-insert-mode nil
  "Если t, то hjkl вводят буквы, иначе навигация.")

(defun my/vertico-toggle-insert ()
  "Переключить режим ввода в минибуфере."
  (interactive)

  (if my/vertico-insert-mode
      (insert "i")
    (setq my/vertico-insert-mode t)
  )
)  

(defun my/vertico-handle-h ()
  (interactive)
  (if my/vertico-insert-mode
      (insert "h")
    (vertico-first)))

(defun my/vertico-handle-j ()
  (interactive)
  (if my/vertico-insert-mode
      (insert "j")
    (vertico-next)))

(defun my/vertico-handle-k ()
  (interactive)
  (if my/vertico-insert-mode
      (insert "k")
    (vertico-previous)))

(defun my/vertico-handle-l ()
  (interactive)
  (if my/vertico-insert-mode
      (insert "l")
    (vertico-exit)))

;; Привязываем в vertico-map
(define-key vertico-map (kbd "h") 'my/vertico-handle-h)
(define-key vertico-map (kbd "j") 'my/vertico-handle-j)
(define-key vertico-map (kbd "k") 'my/vertico-handle-k)
(define-key vertico-map (kbd "l") 'my/vertico-handle-l)
(define-key vertico-map (kbd "i") 'my/vertico-toggle-insert)
(define-key vertico-map (kbd "ESC") (lambda () (interactive) (setq my/vertico-insert-mode nil) (message "Навигация")))

;; Настройка цветов строки состояния для окон
(custom-set-faces
 '(mode-line ((t (:foreground "#FF00FF" :background "#222" :box (:line-width 2 :color "#FF00FF")))))
 '(mode-line-inactive ((t (:foreground "#4B00BB" :background "#111" :box (:line-width 1 :color "#4B00BB"))))))
(custom-set-faces
 '(mode-line ((t (:box (:line-width 2 :color "#FF00FF")))))
 '(mode-line-inactive ((t (:box (:line-width 1 :color "#4B00BB"))))))


(defvar my/resize-step 5
  "Количество строк/колонок для изменения размера окна.")

;; Вспомогательные функции, использующие общий шаг
(defun my/enlarge-window-h ()
  (interactive) (enlarge-window-horizontally my/resize-step))
(defun my/shrink-window-h ()
  (interactive) (shrink-window-horizontally my/resize-step))
(defun my/enlarge-window-v ()
  (interactive) (enlarge-window my/resize-step))
(defun my/shrink-window-v ()
  (interactive) (shrink-window my/resize-step))

(defhydra hydra-window-resize (:color red :hint nil)
  "
^Resize Window^
---------------------------------------------
_h_: уменьшить ширину    _l_: увеличить ширину
_j_: увеличить высоту    _k_: уменьшить высоту
_SPC_: сбросить размер   _q_: выйти
"
  ("h" my/shrink-window-h)
  ("l" my/enlarge-window-h)
  ("j" my/enlarge-window-v)
  ("k" my/shrink-window-v)
  ("SPC" (lambda () (interactive) (balance-windows) (hydra-window-resize/body)))
  ("q" nil "quit" :color blue))

;; Привязываем к удобной комбинации (по умолчанию C-w r)
(global-set-key (kbd "C-S-SPC") 'hydra-window-resize/body)


(use-package dired-subtree
  :ensure t)

(use-package all-the-icons
  :ensure t)

(defun my-dired-sidebar-open ()
  "Открыть файл в другом окне или раскрыть/свернуть папку внутри буфера."
  (interactive)
  (let ((file (dired-get-filename nil t)))
    (if (and file (file-directory-p file))
        (dired-subtree-toggle)     ; раскрыть/свернуть поддерево
      (my/find-file-in-new-window-vertically))))  ; открыть файл в другом окне


(use-package dired-sidebar
  :ensure t
  :after (projectile evil all-the-icons)
  :config
  (setq dired-sidebar-use-projectile t)
  (setq dired-sidebar-use-one-instance t)
  (setq dired-sidebar-refresh-on-project-switch t)
  (setq dired-sidebar-width 35)
  (setq dired-sidebar-theme 'icons)
  ;; (setq dired-sidebar-icon-set 'nerd-icons)   ; <-- ключевая строка
  (setq dired-sidebar-display-alist '((side . left) (slot . 0)))
 
  (set-face-attribute 'dired-sidebar-directory nil :foreground "DodgerBlue" :weight 'bold)
  (set-face-attribute 'dired-sidebar-ignored nil :foreground "gray40")

  ;; Включаем режим дерева
  (setq dired-sidebar-subtree-mode t)

  ;; Принудительно активируем dired-subtree-mode в буфере панели
  (add-hook 'dired-sidebar-mode-hook
            (lambda ()
              (dired-subtree-mode 1)
              (setq-local dired-subtree-use-mouse nil))) ; опционально

  ;; Привязки
  :bind (:map dired-sidebar-mode-map
         ("j" . dired-next-line)
         ("k" . dired-previous-line)
         ("l" . my-dired-sidebar-open)            ; будет раскрывать папки, если включён subtree
         ("h" . my-dired-sidebar-open)
         ("TAB" . dired-subtree-toggle)     ; раскрыть/свернуть поддерево
         ("a" . dired-create-directory)
         ("+" . dired-create-directory)
         ("D" . dired-flag-file-deletion)
         ("x" . dired-do-flagged-delete)
         ("R" . dired-do-rename)
         ("C" . dired-do-copy)
         ("g" . dired-revert)
         ("?" . dired-summary)))

(global-set-key (kbd "C-e") 'dired-sidebar-toggle-sidebar)

(advice-add 'display-warning :around
            (lambda (orig-fn type message &rest args)
              "Подавить предупреждения, содержащие 'dired-sidebar-directory'."
              (unless (string-match-p "dired-sidebar-directory" (apply #'format message args))
                (apply orig-fn type message args))))

;; Функция для стартового выбора проекта
(defun my/startup-select-project ()
  "Открыть список известных проектов и переключиться на выбранный."
  (interactive)
  (if (projectile-known-projects)
      (projectile-switch-project-by-name (completing-read "Select project: " (projectile-known-projects)))
    (message "No known projects yet. Open some project first."))

  )

;; Вызываем эту функцию при старте (после загрузки всех пакетов)
(add-hook 'after-init-hook #'my/startup-select-project)

(defun my/open-sidebar-after-project ()
  "Открыть dired-sidebar с корнем текущего проекта."
  (dired-sidebar-show-sidebar)   ; просто показываем панель — она сама возьмёт корень из projectile
)

(add-hook 'projectile-after-switch-project-hook #'my/open-sidebar-after-project)

(define-key evil-visual-state-map (kbd "C-h") 'windmove-left)
(define-key evil-visual-state-map (kbd "C-l") 'windmove-right)
(define-key evil-visual-state-map (kbd "C-j") 'windmove-down)
(define-key evil-visual-state-map (kbd "C-k") 'windmove-up)

(with-eval-after-load 'evil
  ;; Удаляем привязку C-w из всех основных карт
  (evil-define-key 'normal 'global (kbd "C-q") nil)
  (evil-define-key 'visual 'global (kbd "C-q") nil)
  (evil-define-key 'insert 'global (kbd "C-q") nil)

  ;; Явно удаляем из прямых карт состояний
  (define-key evil-normal-state-map (kbd "C-q") nil)
  (define-key evil-visual-state-map (kbd "C-q") nil)
  (define-key evil-insert-state-map (kbd "C-q") nil)

  ;; !!! КЛЮЧЕВОЕ: удаляем из префиксной карты окон !!!
  (define-key evil-window-map (kbd "C-q") nil)   ; <-- добавляем это

  ;; Для надёжности также можно очистить все привязки в evil-window-map
  ;; но достаточно удалить сам C-w как префикс.

  ;; Отвязываем все остальные Ctrl-комбинации (у вас уже есть)
  (dolist (key '("C-a" "C-e" "C-y" "C-u" "C-d" "C-f" "C-b" "C-h"
                 "C-j" "C-k" "C-l" "C-o" "C-i" "C-r" "C-v"
                 "C-n" "C-p" "C-s" "C-t"))
    (evil-define-key 'normal 'global (kbd key) nil)
    (evil-define-key 'visual 'global (kbd key) nil)
    (evil-define-key 'insert 'global (kbd key) nil)))

(with-eval-after-load 'evil
  ;; ------------------------------------------------------------
  ;; Переназначаем все комбинации Ctrl на нужные функции
  ;; для нормального и визуального режимов
  ;; ------------------------------------------------------------
  (evil-define-key 'normal 'global
    (kbd "C-a") 'move-beginning-of-line
    (kbd "C-e") 'move-end-of-line
    (kbd "C-y") 'yank
    (kbd "C-u") 'universal-argument
    (kbd "C-d") 'my/find-file-in-new-window-vertically
    (kbd "C-f") 'forward-char
    (kbd "C-b") 'consult-buffer
    (kbd "C-h") 'windmove-left
    (kbd "C-j") 'windmove-down
    (kbd "C-l") 'windmove-right
    (kbd "C-o") 'consult-find
    (kbd "C-r") 'isearch-backward
    (kbd "C-s") 'save-buffer
    (kbd "C-t") 'vterm
    (kbd "C-v") 'scroll-down-command
    (kbd "C-n") 'next-line
    (kbd "C-p") 'previous-line
    (kbd "C-q") 'my/save-and-close-buffer
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
    (kbd "C-S-t") (lambda () (interactive) (my/enable-tab-bar-if-needed) (tab-bar-new-tab))
    (kbd "C-S-q") (lambda () (interactive) (when my/tab-bar-enabled (tab-bar-close-tab)))
    (kbd "C-0") (lambda () (interactive) (tab-bar-select-tab 10))
    (kbd "C-1") (lambda () (interactive) (tab-bar-select-tab 1))
    (kbd "C-2") (lambda () (interactive) (tab-bar-select-tab 2))
    (kbd "C-3") (lambda () (interactive) (tab-bar-select-tab 3))
    (kbd "C-4") (lambda () (interactive) (tab-bar-select-tab 4))
    (kbd "C-5") (lambda () (interactive) (tab-bar-select-tab 5))
    (kbd "C-6") (lambda () (interactive) (tab-bar-select-tab 6))
    (kbd "C-7") (lambda () (interactive) (tab-bar-select-tab 7))
    (kbd "C-8") (lambda () (interactive) (tab-bar-select-tab 8))
    (kbd "C-9") (lambda () (interactive) (tab-bar-select-tab 9))
    )

  ;; То же самое для визуального режима (выделение)
  (evil-define-key 'visual 'global
    (kbd "C-a") 'move-beginning-of-line
    (kbd "C-e") 'move-end-of-line
    (kbd "C-y") 'yank
    (kbd "C-u") 'universal-argument
    (kbd "C-d") 'my/find-file-in-new-window-vertically
    (kbd "C-f") 'forward-char
    (kbd "C-b") 'consult-buffer
    (kbd "C-h") 'windmove-left
    (kbd "C-j") 'windmove-down
    (kbd "C-l") 'windmove-right
    (kbd "C-o") 'consult-find
    (kbd "C-r") 'isearch-backward
    (kbd "C-s") 'save-buffer
    (kbd "C-t") 'vterm
    (kbd "C-v") 'scroll-down-command
    (kbd "C-n") 'next-line
    (kbd "C-p") 'previous-line
    (kbd "C-q") 'my/save-and-close-buffer
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
    (kbd "C-S-t") (lambda () (interactive) (my/enable-tab-bar-if-needed) (tab-bar-new-tab))
    (kbd "C-S-q") (lambda () (interactive) (when my/tab-bar-enabled (tab-bar-close-tab)))
    (kbd "C-0") (lambda () (interactive) (tab-bar-select-tab 10))
    (kbd "C-1") (lambda () (interactive) (tab-bar-select-tab 1))
    (kbd "C-2") (lambda () (interactive) (tab-bar-select-tab 2))
    (kbd "C-3") (lambda () (interactive) (tab-bar-select-tab 3))
    (kbd "C-4") (lambda () (interactive) (tab-bar-select-tab 4))
    (kbd "C-5") (lambda () (interactive) (tab-bar-select-tab 5))
    (kbd "C-6") (lambda () (interactive) (tab-bar-select-tab 6))
    (kbd "C-7") (lambda () (interactive) (tab-bar-select-tab 7))
    (kbd "C-8") (lambda () (interactive) (tab-bar-select-tab 8))
    (kbd "C-9") (lambda () (interactive) (tab-bar-select-tab 9))
    )

  ;; Дополнительно: чтобы самые частые команды работали и в режиме вставки
  (evil-define-key 'insert 'global
    (kbd "C-d") 'my/find-file-in-new-window-vertically
    (kbd "C-q") 'my/save-and-close-buffer
    (kbd "C-o") 'consult-find
    (kbd "C-s") 'save-buffer
    (kbd "C-b") 'consult-buffer
    (kbd "C-<return>") 'vterm
    (kbd "C-e") 'dired-sidebar-toggle-sidebar)
  )
;; ============================================================
;; Включение вкладок по требованию (при первом переключении)
;; ============================================================

(defvar my/tab-bar-enabled nil
  "Флаг, указывающий, включена ли панель вкладок.")

(defun my/enable-tab-bar-if-needed ()
  "Включить tab-bar-mode, если он ещё не включён."
  (unless my/tab-bar-enabled
    (tab-bar-mode 1)
    ;; Настройка цветов вкладок
    (custom-set-faces
    '(tab-bar-tab ((t (:foreground "#FF00FF" :weight bold))))
    '(tab-bar-tab-inactive ((t (:foreground "#4B00BB")))))
    (custom-set-faces
    '(tab-bar ((t (:background "#1a1a1a"))))   ; фон панели
    '(tab-bar-tab ((t (:foreground "#FF00FF" :weight bold :box (:line-width 2 :color "#FF00FF")))))
    '(tab-bar-tab-inactive ((t (:foreground "#4B00BB" :box (:line-width 1 :color "#4B00BB"))))))
    (setq my/tab-bar-enabled t)))

(defun my/tab-bar-select-with-activation (tab-index)
  "Активировать вкладки (если нужно) и переключиться на вкладку TAB-INDEX."
  (my/enable-tab-bar-if-needed)
  (tab-bar-select-tab tab-index))

;; Создание новой вкладки (C-S-t)
(global-set-key (kbd "C-S-t")
                (lambda ()
                  (interactive)
                  (my/enable-tab-bar-if-needed)
                  (tab-bar-new-tab)))

;; Закрытие вкладки (C-S-q) – работает только если вкладки уже включены
(global-set-key (kbd "C-S-q")
                (lambda ()
                  (interactive)
                  (when my/tab-bar-enabled
                    (tab-bar-close-tab))))

;; Переключение на вкладку по номеру (C-1 … C-9, C-0)
(dotimes (i 10)
  (let ((key (if (= i 0) 10 i)))    ; 0 -> вкладка 10
    (global-set-key (kbd (format "C-%d" i))
                    `(lambda () (interactive) (tab-bar-select-tab ,key)))))
(global-set-key (kbd "C-0") (lambda () (interactive) (tab-bar-select-tab 10)))

;; Переключение на следующую/предыдущую вкладку (C-TAB / C-S-TAB)
(global-set-key (kbd "C-<tab>") 'tab-bar-switch-to-next-tab)
(global-set-key (kbd "C-S-<iso-lefttab>") 'tab-bar-switch-to-prev-tab) ; Ctrl+Shift+Tab

;; Полностью отключаем стартовый экран
(setq inhibit-startup-screen t)
(setq initial-buffer-choice nil)
(setq inhibit-startup-message t)

;; Убиваем буфер *GNU Emacs*, если он появился
(add-hook 'window-setup-hook
          (lambda ()
            (when (get-buffer "*GNU Emacs*")
              (kill-buffer "*GNU Emacs*"))))

