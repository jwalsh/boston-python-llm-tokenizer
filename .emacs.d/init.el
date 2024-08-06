;; init.el
;; Basic Emacs configuration
(setq inhibit-startup-message t)
(when (fboundp 'tool-bar-mode)
  (tool-bar-mode -1))
(when (fboundp 'scroll-bar-mode)
  (scroll-bar-mode -1))
(menu-bar-mode -1)
(setq-default word-wrap t)
(setq-default truncate-lines nil)
(setq sentence-end-double-space nil)
(setq-default fill-column 80)
(add-hook 'text-mode-hook 'turn-on-auto-fill)
(add-hook 'org-mode-hook 'turn-on-auto-fill)
;; Replace straight quotes with curly quotes
(setq-default electric-quote-mode t)

;; Package management
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
(package-initialize)

;; Use-package for easier package management
(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))
(require 'use-package)
;; Ensure all packages are installed
(setq use-package-always-ensure t)

;; Org mode configuration
(use-package org
  :config
  (setq org-src-fontify-natively t)
  (setq org-src-tab-acts-natively t)
  (setq org-confirm-babel-evaluate nil)
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((python . t))))
(with-eval-after-load 'org
  (org-babel-do-load-languages 'org-babel-load-languages org-babel-load-languages))

;; Language modes
(use-package python-mode)

;; ;; ein configuration
;; (use-package ein
;;   :ensure t
;;   :config
;;   (require 'ein)
;;   (require 'ein-notebook))

;; Company for auto-completion
(use-package company
  :hook (after-init . global-company-mode))

;; Flycheck for syntax checking
(use-package flycheck
  :init (global-flycheck-mode))

;; Magit for Git integration
(use-package magit
  :bind ("C-x g" . magit-status))

;; Projectile for project management
(use-package projectile
  :config
  (projectile-mode +1)
  :bind-keymap
  ("C-c p" . projectile-command-map))

;; Yasnippet for code snippets
(use-package yasnippet
  :config
  (yas-global-mode 1))

;; Theme and visual enhancements
(use-package doom-themes
  :config
  (load-theme 'doom-one t))
(use-package doom-modeline
  :init (doom-modeline-mode 1))
(show-paren-mode 1)
(global-hl-line-mode 1)

;; Improved navigation and editing
(use-package ivy
  :config
  (ivy-mode 1))
(use-package counsel
  :bind (("M-x" . counsel-M-x)
         ("C-x C-f" . counsel-find-file)))
(use-package swiper
  :bind ("C-s" . swiper))
(use-package expand-region
  :bind ("C-=" . er/expand-region))
(use-package multiple-cursors
  :bind (("C-S-c C-S-c" . mc/edit-lines)
         ("C->" . mc/mark-next-like-this)
         ("C-<" . mc/mark-previous-like-this)))

;; Programming-specific enhancements
(use-package lsp-mode
  :hook ((python-mode . lsp))
  :commands lsp)
(use-package lsp-ui
  :commands lsp-ui-mode)
(use-package treemacs
  :bind ("C-c t" . treemacs))

;; Org-mode enhancements
(use-package org-bullets
  :hook (org-mode . org-bullets-mode))

;; Version control enhancements
(use-package git-gutter
  :config
  (global-git-gutter-mode +1))
(use-package git-timemachine)

;; Org-drill configuration
(use-package org-drill
  :ensure t
  :config
  (setq org-drill-add-random-noise-to-intervals-p t)
  (setq org-drill-hint-separator "||")
  (setq org-drill-left-cloze-separator "[")
  (setq org-drill-right-cloze-separator "]")
  (setq org-drill-learn-fraction 0.25))
;; Add keybinding for org-drill
(global-set-key (kbd "C-c d") 'org-drill)

;; Performance improvements
(setq read-process-output-max (* 1024 1024)) ;; 1mb
(setq gc-cons-threshold 100000000)
(setq large-file-warning-threshold 100000000)

;; Tokenizer drill configuration
(defun tokenizer-drill ()
  "Open the tokenizer drill."
  (interactive)
  (find-file "drills/tokenizer-drill.org")
  (org-drill))
(global-set-key (kbd "C-c t") 'tokenizer-drill)
