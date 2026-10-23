;;; latex.el --- Настройки для LaTeX: автооткрытие PDF -*- lexical-binding: t; -*-

;; Отвечает за:
;; - переменную my/auto-open-pdf-for-tex
;; - функцию my/open-pdf-for-tex
;; - хук для latex-mode

(defvar my/auto-open-pdf-for-tex t
  "If non-nil, automatically open PDF when visiting a TeX file.")

(defun my/open-pdf-for-tex ()
  "Открыть PDF рядом с TeX-файлом, если `my/auto-open-pdf-for-tex` не nil."
  (when (and my/auto-open-pdf-for-tex
             buffer-file-name
             (string-match "\\.tex\\'" buffer-file-name))
    (let* ((tex-buffer (current-buffer))
           (tex-win (get-buffer-window tex-buffer))
           (root (projectile-project-root))
           (pdf-file (when root
                       (expand-file-name
                        (concat "pdf/"
                                (file-relative-name (file-name-sans-extension buffer-file-name) root)
                                ".pdf")
                        root))))
      (unless tex-win
        (switch-to-buffer tex-buffer)
        (setq tex-win (selected-window)))
      (when (and pdf-file (file-exists-p pdf-file))
        (select-window tex-win)
        (if (> (window-body-width tex-win) (window-body-height tex-win))
            (split-window-right)
          (split-window-below))
        (other-window 1)
        (find-file pdf-file)
        (select-window tex-win)))))

(add-hook 'latex-mode-hook 'my/open-pdf-for-tex)

(provide 'latex)
