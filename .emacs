(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(column-number-mode t)
 '(display-battery-mode t)
 '(inhibit-startup-screen t)
 '(package-selected-packages
   (quote
    (treemacs treemacs-icons-dired treemacs-magit treemacs-projectile yasnippet projectile projectile-extras projectile-git-autofetch terraform-mode use-package elpy json-mode sml-mode popup popup-complete with-editor yaml-mode yaml-tomato markdown-mode ht ace-window spu magit edit-server)))
 '(python-shell-interpreter "python3")
 '(show-paren-mode t)
 '(tool-bar-mode nil))
(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(default ((t (:family "Ubuntu Mono" :foundry "DAMA" :slant normal :weight normal :height 120 :width normal)))))

;; smaller font by default, for lower-res screens
;; (set-face-attribute 'default nil :height 90)

;; Melpa
(require 'package)
(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/")  t)
(add-to-list 'package-archives '("marmalade" . "https://marmalade-repo.org/packages/") t)
;;(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; If there are no archived package contents, refresh them
(when (not package-archive-contents)
  (package-refresh-contents))

;; Daily upgrade melpa packages in background
(spu-package-upgrade-daily)

;; Open recent file
(require 'recentf)
(setq recentf-auto-cleanup 'never) ;; disable if using tramp
(recentf-mode 1)
(setq recentf-max-menu-items 15)
(global-set-key "\C-x\ \C-r" 'recentf-open-files)
(setq recentf-keep '(file-remote-p file-readable-p))

;; So you can drop .el files into your ~/.emacs.d/lisp directory.
(add-to-list 'load-path "~/.emacs.d/lisp/")

;; For the edit in emacs Chrome extension
(require 'edit-server)
(edit-server-start)

;; Show column numbers.
(setq-default column-number-mode t)

;; Easiest on my eyes
(load-theme 'deeper-blue t)

;; always enable line numbering
(global-linum-mode t)

;; Remove Trailing Whitespace on Save
(add-hook 'before-save-hook 'delete-trailing-whitespace)

;; Lovely 2-space tabs...
(setq-default indent-tabs-mode nil)
(setq-default tab-width 2)

;; make autosave more frequent
(setq auto-save-default 21)

;; Return key automatically indent cursor on new line
(add-hook 'yaml-mode-hook
        (lambda ()
          (define-key yaml-mode-map "\C-m" 'newline-and-indent)))

;; better keys for splitting windows
(global-set-key "\C-x\ |" 'split-window-horizontally)
(global-set-key "\C-x\ -" 'split-window-vertically)

;; default window size
(when window-system (set-frame-size (selected-frame) 200 68))

;; copy file path to kill-ring
(defun xah-copy-file-path (&optional @dir-path-only-p)
  "Copy the current buffer's file path or dired path to `kill-ring'.
Result is full path.
If `universal-argument' is called first, copy only the dir path.
URL `http://ergoemacs.org/emacs/emacs_copy_file_path.html'
Version 2017-01-27"
  (interactive "P")
  (let (($fpath
         (if (equal major-mode 'dired-mode)
             (expand-file-name default-directory)
           (if (buffer-file-name)
               (buffer-file-name)
             (user-error "Current buffer is not associated with a file.")))))
    (kill-new
     (if @dir-path-only-p
         (progn
           (message "Directory path copied: 「%s」" (file-name-directory $fpath))
           (file-name-directory $fpath))
       (progn
         (message "File path copied: 「%s」" $fpath)
         $fpath )))))

;; uniquify lines
  (defun uniquify-all-lines-region (start end)
    "Find duplicate lines in region START to END keeping first occurrence."
    (interactive "*r")
    (save-excursion
      (let ((end (copy-marker end)))
        (while
            (progn
              (goto-char start)
              (re-search-forward "^\\(.*\\)\n\\(\\(.*\n\\)*\\)\\1\n" end t))
          (replace-match "\\1\n\\2")))))

  (defun uniquify-all-lines-buffer ()
    "Delete duplicate lines in buffer and keep first occurrence."
    (interactive "*")
    (uniquify-all-lines-region (point-min) (point-max)))

;; ;; neotree file browser
;; (add-to-list 'load-path "~/.emacs.d/neotree")
;; (require 'neotree)
;; (global-set-key [f8] 'neotree-toggle)
;; (setq-default neo-show-hidden-files t)

;; ace-window for character-based window switching
(global-set-key (kbd "C-x o") 'ace-window)

;; Projectile Settings
(projectile-global-mode)
(projectile-mode +1)
(define-key projectile-mode-map (kbd "s-p") 'projectile-command-map)
(define-key projectile-mode-map (kbd "C-c p") 'projectile-command-map)

;; Magit Git Porcelain
(global-set-key (kbd "C-x g") 'magit-status)
(defun my/magit-display-buffer (buffer)
  (display-buffer
   buffer (if (derived-mode-p 'magit-mode)
              '(display-buffer-same-window)
            '(nil (inhibit-same-window . t)))))

(setq magit-display-buffer-function #'my/magit-display-buffer)

;; elpy for python projects
(use-package elpy
  :ensure t
  :defer t
  :init
  (advice-add 'python-mode :before 'elpy-enable))

;; Enable Flycheck
(when (require 'flycheck nil t)
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  (add-hook 'elpy-mode-hook 'flycheck-mode))

;; Enable autopep8
(require 'py-autopep8)
(add-hook 'elpy-mode-hook 'py-autopep8-enable-on-save)

;;Use flycheck instead of flymake
(when (load "flycheck" t t)
  (setq elpy-modules (delq 'elpy-module-flymake elpy-modules))
  (add-hook 'elpy-mode-hook 'flycheck-mode))
;;Enable emacs 26 flymake indicators in an otherwise light modeline
(setq elpy-remove-modeline-lighter t)

(advice-add 'elpy-modules-remove-modeline-lighter
            :around (lambda (fun &rest args)
                      (unless (eq (car args) 'flymake-mode)
                        (apply fun args))))

;; built-in mode for balancing bracets and quotes
(electric-pair-mode 1)

;; Default directory
(setq default-directory "~/")

;; Treemacs
(require 'treemacs)
(setq treemacs-width 45)
(global-set-key (kbd "M-0") 'treemacs-select-window)

;;(setq ediff-window-setup-function 'ediff-setup-window-plain)
