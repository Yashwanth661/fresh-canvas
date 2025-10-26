(defvar elpaca-installer-version 0.8)
(defvar elpaca-directory (expand-file-name "elpaca/" user-emacs-directory))
(defvar elpaca-builds-directory (expand-file-name "builds/" elpaca-directory))
(defvar elpaca-repos-directory (expand-file-name "repos/" elpaca-directory))
(defvar elpaca-order '(elpaca :repo "https://github.com/progfolio/elpaca.git"
			:ref nil
			:files (:defaults (:exclude "extensions"))
			:build (:not elpaca--activate-package)))
(let* ((repo  (expand-file-name "elpaca/" elpaca-repos-directory))
 (build (expand-file-name "elpaca/" elpaca-builds-directory))
 (order (cdr elpaca-order))
 (default-directory repo))
  (add-to-list 'load-path (if (file-exists-p build) build repo))
  (unless (file-exists-p repo)
    (make-directory repo t)
    (when (< emacs-major-version 28) (require 'subr-x))
    (condition-case-unless-debug err
  (if-let ((buffer (pop-to-buffer-same-window "*elpaca-bootstrap*"))
	   ((zerop (call-process "git" nil buffer t "clone"
				 (plist-get order :repo) repo)))
	   ((zerop (call-process "git" nil buffer t "checkout"
				 (or (plist-get order :ref) "--"))))
	   (emacs (concat invocation-directory invocation-name))
	   ((zerop (call-process emacs nil buffer nil "-Q" "-L" "." "--batch"
				 "--eval" "(byte-recompile-directory \".\" 0 'force)")))
	   ((require 'elpaca))
	   ((elpaca-generate-autoloads "elpaca" repo)))
      (kill-buffer buffer)
    (error "%s" (with-current-buffer buffer (buffer-string))))
((error) (warn "%s" err) (delete-directory repo 'recursive))))
  (unless (require 'elpaca-autoloads nil t)
    (require 'elpaca)
    (elpaca-generate-autoloads "elpaca" repo)
    (load "./elpaca-autoloads")))
(add-hook 'after-init-hook #'elpaca-process-queues)
(elpaca `(,@elpaca-order))

;; Install use-package support
(elpaca elpaca-use-package
  ;; Enable :elpaca use-package keyword.
  (elpaca-use-package-mode)
  ;; Assume :elpaca t unless otherwise specified.
  (setq elpaca-use-package-by-default t))

;; Block until current queue processed.
(elpaca-wait)

;;When installing a package which modifies a form used at the top-level
;;(e.g. a package which adds a use-package key word),
;;use `elpaca-wait' to block until that package has been installed/configured.
;;For example:
;;(use-package general :demand t)
;;(elpaca-wait)

;;Turns off elpaca-use-package-mode current declartion
;;Note this will cause the declaration to be interpreted immediately (not deferred).
;;Useful for configuring built-in emacs features.
;;(use-package emacs :elpaca nil :config (setq ring-bell-function #'ignore))

;; Don't install anything. Defer execution of BODY
;;(elpaca nil (message "deferred"))

(use-package all-the-icons
  :ensure t
  :if (display-graphic-p))

(use-package all-the-icons-dired
  :hook (dired-mode . (lambda () (all-the-icons-dired-mode t))))

(use-package anzu
  :ensure t
  :config
  (global-anzu-mode +1)
  ;; Remap default query-replace commands to use anzu versions
  (global-set-key [remap query-replace] 'anzu-query-replace)
  (global-set-key [remap query-replace-regexp] 'anzu-query-replace-regexp)
  ;; Optional: Customize how anzu displays match information in the mode-line
  (setq anzu-mode-lighter "")
  (setq anzu-deactivate-region t)
  (setq anzu-search-threshold 1000))

(use-package evil-anzu
  :ensure t
  :after (evil anzu))

(setq backup-directory-alist '((".*" . "~/.emacs.d/Trash")))
(setq make-backup-files t)               ; Enable backups
(setq version-control t)                 ; Use version numbers for backups
(setq delete-old-versions t)             ; Automatically delete excess backups
(setq kept-new-versions 6)               ; Keep 6 newest versions
(setq kept-old-versions 2)               ; Keep 2 oldest versions
(setq backup-by-copying t)               ; Copy files instead of moving them

(use-package beacon
  :ensure t
  :config
  (beacon-mode 1))

(use-package centered-window
  :ensure t
  :bind (("C-c w c" . centered-window-mode-toggle)) ;; Bind "C-c w c" to toggle centered window mode
  :config
  (setq cwm-centered-window-width 140) ;; Adjust this value to your desired width
  (defun centered-window-mode-toggle ()
    "Toggle Centered Window Mode on and off."
    (interactive)
    (if centered-window-mode
        (centered-window-mode -1)
      (centered-window-mode +1))))

(use-package company
  :defer 2
  :custom
  (company-begin-commands '(self-insert-command))
  (company-idle-delay .1)
  (company-minimum-prefix-length 2)
  (company-show-numbers t)
  (company-tooltip-align-annotations 't)
  (global-company-mode t))

(use-package company-box
  :after company
  :diminish
  :hook (company-mode . company-box-mode))

(require 'windmove)

;;;###autoload
(defun buf-move-up ()
  "Swap the current buffer and the buffer above the split.
If there is no split, ie now window above the current one, an
error is signaled."
;;  "Switches between the current buffer, and the buffer above the
;;  split, if possible."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'up))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No window above this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-down ()
"Swap the current buffer and the buffer under the split.
If there is no split, ie now window under the current one, an
error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'down))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (or (null other-win) 
            (string-match "^ \\*Minibuf" (buffer-name (window-buffer other-win))))
        (error "No window under this one")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-left ()
"Swap the current buffer and the buffer on the left of the split.
If there is no split, ie now window on the left of the current
one, an error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'left))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No left split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

;;;###autoload
(defun buf-move-right ()
"Swap the current buffer and the buffer on the right of the split.
If there is no split, ie now window on the right of the current
one, an error is signaled."
  (interactive)
  (let* ((other-win (windmove-find-other-window 'right))
	 (buf-this-buf (window-buffer (selected-window))))
    (if (null other-win)
        (error "No right split")
      ;; swap top with this one
      (set-window-buffer (selected-window) (window-buffer other-win))
      ;; move this one to top
      (set-window-buffer other-win buf-this-buf)
      (select-window other-win))))

(setq auto-save-default nil)

(use-package diminish)

(use-package dashboard
  :ensure t 
  :init
  (setq initial-buffer-choice 'dashboard-open)
  (setq dashboard-set-heading-icons t)
  (setq dashboard-set-file-icons t)
  (setq dashboard-banner-logo-title "HAVE FUN!!!!")
  ;;(setq dashboard-startup-banner 'logo) ;; use standard emacs logo as banner
  (setq dashboard-startup-banner "~/.emacs.d/images/emacs-dash.jpg")  ;; use custom image as banner
  (setq org-agenda-files '("~/.emacs.d/org/todo.org"))
  (setq dashboard-center-content t) ;; set to 't' for centered content
  (setq dashboard-vertically-center-content t)
  (setq dashboard-items '((recents . 3 )
                          (agenda . 10 )
                          (bookmarks . 3)
                          (projects . 3)
                          (registers . 3)))
   ;; Agenda settings for dashboard
  (setq dashboard-week-agenda t)
  (setq dashboard-filter-agenda-entry 'dashboard-no-filter-agenda)
  ;:custom
  ;(dashboard-modify-heading-icons '((recents . "file-text")
  ;                                  (bookmarks . "book")
  ;                                  (agenda . "calendar")))
  :config
  (dashboard-setup-startup-hook))
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
;; ORG-AGENDA CUSTOM VIEWS (for dashboard integration)
;; ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

(setq org-agenda-custom-commands
      '(("d" "Daily Dashboard"
         ((agenda "" ((org-agenda-span 'day)
                      (org-agenda-overriding-header "\n📅 Today's Schedule\n")))
          (tags-todo "SCHEDULED>=\"<today>\"+SCHEDULED<=\"<today>\""
                     ((org-agenda-overriding-header "\n✅ Daily Tasks\n")
                      (org-agenda-skip-function '(org-agenda-skip-entry-if 'done))))
          (tags "+PRIORITY=\"A\""
                ((org-agenda-overriding-header "\n⚡ High Priority\n")
                 (org-agenda-skip-function '(org-agenda-skip-entry-if 'done))))))
       
        ("l" "Learning Progress"
         ((tags-todo "+CATEGORY=\"Learning\""
                     ((org-agenda-overriding-header "\n📚 Active Learning Tasks\n")))
          (tags "+CATEGORY=\"Learning\"+CLOSED>=\"<-7d>\""
                ((org-agenda-overriding-header "\n✨ Recently Completed (Last 7 Days)\n")
                 (org-agenda-sorting-strategy '(time-down))))))
        
        ("w" "Watch List by Language"
         ((tags "+telugu-DONE" ((org-agenda-overriding-header "\n🎭 Telugu - To Watch\n")))
          (tags "+tamil-DONE" ((org-agenda-overriding-header "\n🎭 Tamil - To Watch\n")))
          (tags "+hindi-DONE" ((org-agenda-overriding-header "\n🎭 Hindi - To Watch\n")))
          (tags "+english-DONE" ((org-agenda-overriding-header "\n🎭 English - To Watch\n")))
          (tags "+malayalam-DONE" ((org-agenda-overriding-header "\n🎭 Malayalam - To Watch\n")))))))

;; DocView configuration (built-in)
(use-package doc-view
  :ensure nil  
  :mode ("\\.djvu\\'" . doc-view-mode)
  :config
  (setq doc-view-continuous t
        doc-view-resolution 300
        doc-view-cache-directory "~/.emacs.d/doc-view-cache/"))

;; DjVu specific configuration
(use-package djvu
  :ensure t  ;; Changed from :elpaca to :ensure
  :after doc-view
  :mode ("\\.djvu\\'" . djvu-read-mode)
  :config
  (setq imagemagick-types-inhibit '(C HTML HTM INFO M TXT PDF DJVU)))

(use-package dired-open
  :config
  (setq dired-open-extensions '(("gif" . "sxiv")
                                ("jpg" . "sxiv")
                                ("png" . "sxiv")
                                ("mkv" . "mpv")
                                ("mp4" . "mpv"))))

(use-package peep-dired
  :after dired
  :hook (evil-normalize-keymaps . peep-dired-hook)
  :config
    (evil-define-key 'normal dired-mode-map (kbd "h") 'dired-up-directory)
    (evil-define-key 'normal dired-mode-map (kbd "l") 'dired-open-file) ; use dired-find-file instead if not using dired-open package
    (evil-define-key 'normal peep-dired-mode-map (kbd "j") 'peep-dired-next-file)
    (evil-define-key 'normal peep-dired-mode-map (kbd "k") 'peep-dired-prev-file)
)

;;(add-hook 'peep-dired-hook 'evil-normalize-keymaps)

(setq ediff-split-window-function 'split-window-horizontally
      ediff-window-setup-function 'ediff-setup-windows-plain)

(defun dt-ediff-hook ()
  (ediff-setup-keymap)
  (define-key ediff-mode-map "j" 'ediff-next-difference)
  (define-key ediff-mode-map "k" 'ediff-previous-difference))

(add-hook 'ediff-mode-hook 'dt-ediff-hook)

;; Ensure Elfeed is installed and configured
(use-package elfeed
  :ensure t
  :config
  ;; Set the database directory explicitly
  (setq elfeed-db-directory "~/.elfeed")

  ;; Function to display the Elfeed entry buffer in a split window at the bottom
  (defun elfeed-display-buffer (buf &optional _action)
    "Display Elfeed buffer BUF in a split window at the bottom."
    (let ((window (split-window-below))) ;; Split window at the bottom
      (set-window-buffer window buf)
      (select-window window)
      (set-window-text-height window (round (* 0.3 (frame-height)))))) ;; Set height to 30% of frame

  ;; Set the custom display function for Elfeed entries
  (setq elfeed-show-entry-switch #'elfeed-display-buffer))

;; Optional: Enhance Elfeed UI with elfeed-goodies
(use-package elfeed-goodies
  :ensure t
  :after elfeed
  :config
  (elfeed-goodies/setup))

;; Optional: Use an Org file to manage feeds with elfeed-org
(use-package elfeed-org
  :ensure t
  :after elfeed
  :config
  ;; Specify the Org file containing your feed configuration
  (setq rmh-elfeed-org-files (list "~/.emacs.d/elfeed.org"))
  ;; Initialize elfeed-org to process the Org file
  (elfeed-org))

;; Add emacs-reddigg for Reddit browsing in Org-mode
(use-package reddigg
  :ensure t
  :config
  ;; List of subreddits to show in *reddigg-main* buffer.
  ;; Add your favorite subreddits here.
  (setq reddigg-subs '("emacs" "linux" "programming" "technology"))

  ;; Disable confirmation for executing links in org-mode buffers.
  ;; Use this if you trust the links and want smoother navigation.
  (setq org-confirm-elisp-link-function nil)

  ;; Function to open Reddit's main subreddit list in *reddigg-main* buffer.
  (defun my-reddigg-view-main ()
    "Open the main Reddit subreddit list."
    (interactive)
    (reddigg-view-main)))

;; Function to integrate reddigg into your workflow with Elfeed
(defun my-open-reddit-in-reddigg ()
  "Open a Reddit post from Elfeed in reddigg."
  (interactive)
  (let ((entry-link (elfeed-entry-link elfeed-show-entry)))
    (if (and entry-link (string-match "reddit.com" entry-link))
        ;; Open Reddit comments or posts directly in reddigg-comments buffer.
        (reddigg-view-comments entry-link)
      (message "This is not a Reddit post!"))))

(use-package emms
  :ensure t
  :config
  (require 'emms-setup)
  (emms-all)
  (setq emms-player-list '(emms-player-vlc)
        emms-info-functions '(emms-info-native)))

:ensure t
;; Expands to: (elpaca evil (use-package evil :demand t))
(use-package evil
    :init      ;; tweak evil's configuration before loading it
    (setq evil-want-integration t  ;; This is optional since it's already set to t by default.
          evil-want-keybinding nil
          evil-vsplit-window-right t
          evil-split-window-below t
          evil-undo-system 'undo-redo)  ;; Adds vim-like C-r redo functionality
    (evil-mode))

(use-package evil-collection
  :after evil
  :config
  ;; Do not uncomment this unless you want to specify each and every mode
  ;; that evil-collection should works with.  The following line is here 
  ;; for documentation purposes in case you need it.  
  ;; (setq evil-collection-mode-list '(calendar dashboard dired ediff info magit ibuffer))
  (add-to-list 'evil-collection-mode-list 'help) ;; evilify help mode
  (evil-collection-init))

(use-package evil-tutor)

;; Using RETURN to follow links in Org/Evil 
;; Unmap keys in 'evil-maps if not done, (setq org-return-follows-link t) will not work
(with-eval-after-load 'evil-maps
  (define-key evil-motion-state-map (kbd "SPC") nil)
  (define-key evil-motion-state-map (kbd "RET") nil)
  (define-key evil-motion-state-map (kbd "TAB") nil))
;; Setting RETURN key in org-mode to follow links
  (setq org-return-follows-link  t)

(use-package flycheck
  :ensure t
  :defer t
  :init (global-flycheck-mode))

;; Backspace handling
;; (global-set-key (kbd "DEL") 'backward-delete-char)
;; (global-set-key (kbd "<backspace>") 'backward-delete-char)

;; ;; Use normal-erase-is-backspace-mode to handle backspace correctly
;; (normal-erase-is-backspace-mode 1)

;; Ensure C-h behaves as backspace in all contexts
(keyboard-translate ?\C-h ?\C-?)

;; Ctrl+d and Ctrl+u for scrolling
(global-set-key (kbd "C-d") 'scroll-up-command)
(global-set-key (kbd "C-u") 'scroll-down-command)

;; ;; Custom function to delete backward even if text is read-only
;; (defun my-backward-delete-char ()
;;   "Delete backward character, ignoring read-only status in minibuffer."
;;   (interactive)
;;   (let ((inhibit-read-only t))
;;     (call-interactively 'backward-delete-char)))

;; ;; Bind this function to the backspace key in the minibuffer
;; (define-key minibuffer-local-map (kbd "DEL") 'my-backward-delete-char)
;; (define-key minibuffer-local-map (kbd "<backspace>") 'my-backward-delete-char)

;; System dependencies and fonts map
(defvar system-dependencies
  '((fedora . ("git" "emacs" "ripgrep" "fd-find" "ubuntu-family-fonts" "jetbrains-mono-fonts"))
    (debian . ("git" "emacs" "ripgrep" "fd-find" "fonts-ubuntu" "fonts-jetbrains-mono")) 
    (arch   . ("git" "emacs" "ripgrep" "fd" "ttf-ubuntu-font-family" "ttf-jetbrains-mono"))
    (macos  . ("git" "emacs" "ripgrep" "fd" "font-ubuntu" "font-jetbrains-mono")))
  "System dependencies per distribution.")

;; Bootstrap function (runs once)
(defun bootstrap-system-dependencies ()
  "Bootstrap system dependencies and fonts."
  (interactive)
  (let ((bootstrap-file (expand-file-name "bootstrap-complete" user-emacs-directory)))
    (unless (file-exists-p bootstrap-file)
      (message "Running first-time system bootstrap...")
      
      ;; Install system packages based on detected distribution
      (let* ((pm (detect-package-manager))
             (distro (pcase pm
                      ("dnf" 'fedora)
                      ("apt" 'debian) 
                      ("pacman" 'arch)
                      ("brew" 'macos)))
             (packages (cdr (assoc distro system-dependencies))))
        
        (when packages
          (message "Installing packages for %s..." distro)
          (dolist (pkg packages)
            (let ((install-cmd
                   (pcase pm
                     ("dnf" `("sudo" "dnf" "install" "-y" ,pkg))
                     ("apt" `("sudo" "apt" "install" "-y" ,pkg))
                     ("pacman" `("sudo" "pacman" "-S" "--noconfirm" ,pkg))
                     ("brew" `("brew" "install" ,(if (string-prefix-p "font-" pkg) "--cask" "") ,pkg)))))
              (when install-cmd
                (message "Installing %s..." pkg)
                (apply #'call-process (car install-cmd) nil nil nil (cdr install-cmd))))))
        
        ;; Refresh font cache
        (call-process "fc-cache" nil nil nil "-fv")
        
        ;; Create completion marker
        (with-temp-file bootstrap-file
          (insert "Bootstrap completed on: " (current-time-string)))
        
        (message "System bootstrap completed!")))))

;; Run bootstrap on startup (only once)
(add-hook 'after-init-hook #'bootstrap-system-dependencies)

;; Font availability checker
(defun font-available-p (font-name)
  "Check if FONT-NAME is available on the system."
  (when (display-graphic-p)
    (find-font (font-spec :name font-name))))

;; System package manager detection
(defun detect-package-manager ()
  "Detect system package manager."
  (cond
   ((executable-find "dnf") "dnf")
   ((executable-find "apt") "apt") 
   ((executable-find "pacman") "pacman")
   ((executable-find "brew") "brew")
   (t nil)))

;; Automatic font installation
(defun install-font-package (font-name package-name)
  "Install missing font package automatically."
  (let ((pm (detect-package-manager)))
    (when pm
      (message "Installing font: %s" font-name)
      (let ((install-cmd
             (pcase pm
               ("dnf" `("sudo" "dnf" "install" "-y" ,package-name))
               ("apt" `("sudo" "apt" "install" "-y" 
                       ,(pcase package-name
                          ("ubuntu-family-fonts" "fonts-ubuntu")
                          ("liberation-fonts" "fonts-liberation") 
                          ("jetbrains-mono-fonts" "fonts-jetbrains-mono")
                          (_ package-name))))
               ("pacman" `("sudo" "pacman" "-S" "--noconfirm"
                          ,(pcase package-name
                             ("ubuntu-family-fonts" "ttf-ubuntu-font-family")
                             ("liberation-fonts" "ttf-liberation")
                             ("jetbrains-mono-fonts" "ttf-jetbrains-mono")
                             (_ package-name))))
               ("brew" `("brew" "install" "--cask"
                        ,(pcase package-name
                           ("ubuntu-family-fonts" "font-ubuntu")
                           ("liberation-fonts" "font-liberation")
                           ("jetbrains-mono-fonts" "font-jetbrains-mono")
                           (_ package-name)))))))
        (when install-cmd
          (apply #'call-process (car install-cmd) nil nil nil (cdr install-cmd))
          (call-process "fc-cache" nil nil nil "-fv"))))))

;; Safe font configuration with auto-installation
(defun safe-set-font (face font-list &rest args)
  "Safely set font with automatic installation fallback."
  (when (display-graphic-p)
    (let ((available-font (seq-find #'font-available-p font-list)))
      (if available-font
          (apply #'set-face-attribute face nil :font available-font args)
        (progn
          (message "No fonts available from: %s" font-list)
          ;; Auto-install first missing font
          (let ((font-packages '(("Ubuntu" . "ubuntu-family-fonts")
                                ("JetBrains Mono" . "jetbrains-mono-fonts")
                                ("Liberation Sans" . "liberation-fonts"))))
            (dolist (font-name font-list)
              (let ((package-name (cdr (assoc font-name font-packages))))
                (when package-name
                  (install-font-package font-name package-name)))))
          ;; Retry after installation
          (let ((retry-font (seq-find #'font-available-p font-list)))
            (when retry-font
              (apply #'set-face-attribute face nil :font retry-font args))))))))

;; Configure fonts with automatic installation fallback
(safe-set-font 'default 
               '("JetBrains Mono" "Liberation Mono" "DejaVu Sans Mono" "monospace")
               :height 110 :weight 'medium)

(safe-set-font 'variable-pitch 
               '("Ubuntu" "Liberation Sans" "DejaVu Sans" "sans-serif")
               :height 120 :weight 'medium)

(safe-set-font 'fixed-pitch 
               '("JetBrains Mono" "Liberation Mono" "DejaVu Sans Mono" "monospace")
               :height 110 :weight 'medium)

;; Makes commented text and keywords italics.
(set-face-attribute 'font-lock-comment-face nil :slant 'italic)
(set-face-attribute 'font-lock-keyword-face nil :slant 'italic)

;; This sets the default font on all graphical frames created after restarting Emacs.
(add-to-list 'default-frame-alist '(font . "JetBrains Mono-11"))

;; Line spacing
(setq-default line-spacing 0.12)

(global-set-key (kbd "C-=") 'text-scale-increase)
(global-set-key (kbd "C--") 'text-scale-decrease)
(global-set-key (kbd "<C-wheel-up>") 'text-scale-increase)
(global-set-key (kbd "<C-wheel-down>") 'text-scale-decrease)

(use-package general
  :ensure t
  :config
  (general-evil-setup)

  ;; set up 'SPC' as the global leader key
  (general-create-definer sam/leader-keys
    :states '(normal visual emacs)
    :keymaps 'override
    :prefix "SPC" ;; set leader
    :global-prefix "M-SPC") ;; access leader in insert mode

(sam/leader-keys
 ;; Bind SPC x to M-x (execute-extended-command)
  "SPC" '(execute-extended-command :wk "M-x")
  "." '(find-file :wk "Find file")
  "=" '(perspective-map :wk "Perspective") ;; Lists all the perspective keybindings
  "TAB TAB" '(comment-line :wk "Comment lines")
  ;; Comment/Uncomment bindings
  "c" '(:ignore t :wk "Comments")
  "cc" '(comment-region :wk "Comment region")
  "cu" '(uncomment-region :wk "Uncomment region")
  "cl" '(comment-line :wk "Comment line")

  ;; Centered Window Mode bindings
  "c" '(:ignore t :wk "Centered Window") ;; Reuse 'c' for Centered Window context
  "co" '(centered-window-mode :wk "Toggle Centered Window Mode") ;; Toggle on/off
  "cw" '(lambda () (interactive) (centered-window-mode -1) :wk "Close Centered Window Mode")) ;; Explicitly close

  (sam/leader-keys
    "b" '(:ignore t :wk "Bookmarks/Buffers")
    "b c" '(clone-indirect-buffer :wk "Create indirect buffer copy in a split")
    "b C" '(clone-indirect-buffer-other-window :wk "Clone indirect buffer in new window")
    "b d" '(bookmark-delete :wk "Delete bookmark")
    "b i" '(ibuffer :wk "Ibuffer")
    "b k" '(kill-this-buffer :wk "Kill this buffer")
    "b K" '(kill-some-buffers :wk "Kill multiple buffers")
    "b l" '(list-bookmarks :wk "List bookmarks")
    "b m" '(bookmark-set :wk "Set bookmark")
    "b n" '(next-buffer :wk "Next buffer")
    "b p" '(previous-buffer :wk "Previous buffer")
    "b r" '(revert-buffer :wk "Reload buffer")
    "b R" '(rename-buffer :wk "Rename buffer")
    "b s" '(basic-save-buffer :wk "Save buffer")
    "b S" '(save-some-buffers :wk "Save multiple buffers")
    "b w" '(bookmark-save :wk "Save current bookmarks to bookmark file"))

  (sam/leader-keys
    "d" '(:ignore t :wk "Dired")
    "d d" '(dired :wk "Open dired")
    "d j" '(dired-jump :wk "Dired jump to current")
    "d n" '(neotree-dir :wk "Open directory in neotree")
    "d p" '(peep-dired :wk "Peep-dired"))

 (sam/leader-keys
   "e" '(:ignore t :wk "Evaluate/Eshell")    
   "e b" '(eval-buffer :wk "Evaluate elisp in buffer")
   "e d" '(eval-defun :wk "Evaluate defun containing or after point")
   "e e" '(eval-expression :wk "Evaluate and elisp expression")
   "e f" '(ediff-files :wk "Run ediff on a pair of files")
   "e F" '(ediff-files3 :wk "Run ediff on three files")
   "e h" '(counsel-esh-history :which-key "Eshell history")
   "e l" '(eval-last-sexp :wk "Evaluate elisp expression before point")
   "e r" '(eval-region :wk "Evaluate elisp in region")
   "e s" '(eshell :which-key "Eshell"))

   (sam/leader-keys
    "f" '(:ignore t :wk "Files")    
    "f c" '((lambda () (interactive)
              (find-file "~/.emacs.d/config.org")) 
            :wk "Open emacs config.org")
    "f e" '((lambda () (interactive)
              (dired "~/.emacs.d/")) 
            :wk "Open user-emacs-directory in dired")
    "f d" '(find-grep-dired :wk "Search for string in files in DIR")
    "f g" '(counsel-grep-or-swiper :wk "Search for string current file")
    "f i" '((lambda () (interactive)
              (find-file "~/.emacs.d/init.el")) 
            :wk "Open emacs init.el")
    "f j" '(counsel-file-jump :wk "Jump to a file below current directory")
    "f l" '(counsel-locate :wk "Locate a file")
    "f r" '(counsel-recentf :wk "Find recent files")
    "f u" '(sudo-edit-find-file :wk "Sudo find file")
    "f U" '(sudo-edit :wk "Sudo edit file")
   
  ;; Add Elfeed commands under the leader key
    "f" '(:ignore t :wk "Elfeed") ;; Create a top-level group for Elfeed
    "f r" '(elfeed-update :wk "Refresh Elfeed") ;; Refresh feeds
    "f s" '(elfeed-search-live-filter :wk "Search feeds") ;; Search feeds
    "f o" '(elfeed :wk "Open Elfeed")) ;; Open the Elfeed interface
   
  (sam/leader-keys
    "g" '(:ignore t :wk "Git")    
    "g /" '(magit-displatch :wk "Magit dispatch")
    "g ." '(magit-file-displatch :wk "Magit file dispatch")
    "g b" '(magit-branch-checkout :wk "Switch branch")
    "g c" '(:ignore t :wk "Create") 
    "g c b" '(magit-branch-and-checkout :wk "Create branch and checkout")
    "g c c" '(magit-commit-create :wk "Create commit")
    "g c f" '(magit-commit-fixup :wk "Create fixup commit")
    "g C" '(magit-clone :wk "Clone repo")
    "g f" '(:ignore t :wk "Find") 
    "g f c" '(magit-show-commit :wk "Show commit")
    "g f f" '(magit-find-file :wk "Magit find file")
    "g f g" '(magit-find-git-config-file :wk "Find gitconfig file")
    "g F" '(magit-fetch :wk "Git fetch")
    "g g" '(magit-status :wk "Magit status")
    "g i" '(magit-init :wk "Initialize git repo")
    "g l" '(magit-log-buffer-file :wk "Magit buffer log")
    "g r" '(vc-revert :wk "Git revert file")
    "g s" '(magit-stage-file :wk "Git stage file")
    "g t" '(git-timemachine :wk "Git time machine")
    "g u" '(magit-stage-file :wk "Git unstage file"))

   (sam/leader-keys
    "h" '(:ignore t :wk "Help")
    "h a" '(counsel-apropos :wk "Apropos")
    "h b" '(describe-bindings :wk "Describe bindings")
    "h c" '(describe-char :wk "Describe character under cursor")
    "h d" '(:ignore t :wk "Emacs documentation")
    "h d a" '(about-emacs :wk "About Emacs")
    "h d d" '(view-emacs-debugging :wk "View Emacs debugging")
    "h d f" '(view-emacs-FAQ :wk "View Emacs FAQ")
    "h d m" '(info-emacs-manual :wk "The Emacs manual")
    "h d n" '(view-emacs-news :wk "View Emacs news")
    "h d o" '(describe-distribution :wk "How to obtain Emacs")
    "h d p" '(view-emacs-problems :wk "View Emacs problems")
    "h d t" '(view-emacs-todo :wk "View Emacs todo")
    "h d w" '(describe-no-warranty :wk "Describe no warranty")
    "h e" '(view-echo-area-messages :wk "View echo area messages")
    "h f" '(describe-function :wk "Describe function")
    "h F" '(describe-face :wk "Describe face")
    "h g" '(describe-gnu-project :wk "Describe GNU Project")
    "h i" '(info :wk "Info")
    "h I" '(describe-input-method :wk "Describe input method")
    "h k" '(describe-key :wk "Describe key")
    "h l" '(view-lossage :wk "Display recent keystrokes and the commands run")
    "h L" '(describe-language-environment :wk "Describe language environment")
    "h m" '(describe-mode :wk "Describe mode")
    "h r" '(:ignore t :wk "Reload")
    "h r r" '((lambda () (interactive)
                (load-file "~/.emacs.d/init.el")
                (ignore (elpaca-process-queues)))
              :wk "Reload emacs config")
    "h t" '(load-theme :wk "Load theme")
    "h v" '(describe-variable :wk "Describe variable")
    "h w" '(where-is :wk "Prints keybinding for command if set")
    "h x" '(describe-command :wk "Display full documentation for command"))

  (sam/leader-keys
    "t" '(:ignore t :wk "Toggle")
    "t e" '(eshell-toggle :wk "Toggle eshell")
    "t f" '(flycheck-mode :wk "Toggle flycheck")
    "t l" '(display-line-numbers-mode :wk "Toggle line numbers")
    "t n" '(neotree-toggle :wk "Toggle neotree file viewer")
    "t o" '(org-mode :wk "Toggle org mode")
    "t r" '(rainbow-mode :wk "Toggle rainbow mode")
    "t t" '(visual-line-mode :wk "Toggle truncated lines")
    "t v" '(vterm-toggle :wk "Toggle vterm"))

  ;; Multi-vterm keybindings
  (sam/leader-keys
    "t" '(:ignore t :wk "Toggle")
    "t M" '(multi-vterm :wk "New vterm")
    "t j" '(multi-vterm-next :wk "Next vterm")
    "t k" '(multi-vterm-prev :wk "Previous vterm")
    "t d" '(multi-vterm-dedicated-toggle :wk "Dedicated vterm")
    "t p" '(multi-vterm-project :wk "Project vterm"))

  (sam/leader-keys
  "m" '(:ignore t :wk "Org")
  "m a" '(org-agenda :wk "Org agenda")
  "m e" '(org-export-dispatch :wk "Org export dispatch")
  "m i" '(org-toggle-item :wk "Org toggle item")
  "m t" '(org-todo :wk "Org todo")
  "m B" '(org-babel-tangle :wk "Org babel tangle")
  "m T" '(org-todo-list :wk "Org todo list")
  "m m" '(toggle-maximize-buffer :wk "Toggle maximize buffer"))

(sam/leader-keys
  "m b" '(:ignore t :wk "Tables")
  "m b -" '(org-table-insert-hline :wk "Insert hline in table"))

(sam/leader-keys
  "m d" '(:ignore t :wk "Date/deadline")
  "m d t" '(org-time-stamp :wk "Org time stamp"))

  (sam/leader-keys
    "o" '(:ignore t :wk "Open")
    "o d" '(dashboard-open :wk "Dashboard")
    "o f" '(make-frame :wk "Open buffer in new frame")
    "o F" '(select-frame-by-name :wk "Select frame by name"))

(sam/leader-keys
  "p" '(projectile-command-map :wk "Projectile"))

  (sam/leader-keys
    "s" '(:ignore t :wk "Search")
    "s d" '(dictionary-search :wk "Search dictionary")
    "s m" '(man :wk "Man pages")
    "s t" '(tldr :wk "Lookup TLDR docs for a command")
    "s w" '(woman :wk "Similar to man but doesn't require man"))


(sam/leader-keys
  "w" '(:ignore t :wk "Windows")
  ;; Window splits
  "w c" '(evil-window-delete :wk "Close window")
  "w n" '(evil-window-new :wk "New window")
  "w s" '(evil-window-split :wk "Horizontal split window")
  "w v" '(evil-window-vsplit :wk "Vertical split window")
  ;; Window motions
  "w h" '(evil-window-left :wk "Window left")
  "w j" '(evil-window-down :wk "Window down")
  "w k" '(evil-window-up :wk "Window up")
  "w l" '(evil-window-right :wk "Window right")
  "w w" '(evil-window-next :wk "Goto next window")
  ;; Move Windows
  "w H" '(buf-move-left :wk "Buffer move left")
  "w J" '(buf-move-down :wk "Buffer move down")
  "w K" '(buf-move-up :wk "Buffer move up")
  "w L" '(buf-move-right :wk "Buffer move right")
  ;; Words
   "w d" '(downcase-word :wk "Downcase word")
   "w u" '(upcase-word :wk "Upcase word")
   "w =" '(count-words :wk "Count words/lines for buffer"))
)

;;(use-package git-timemachine
;;  :elpaca nil
;;  :load-path "~/.emacs.d/elpaca/builds/git-timemachine")
(use-package git-timemachine
  :ensure t)
(use-package transient
  :ensure t)

;;(use-package magit
;;  :elpaca nil
;;  :load-path "~/.emacs.d/elpaca/builds/magit/lisp")
(use-package magit
  :ensure t)

(use-package hl-todo
  :hook ((org-mode . hl-todo-mode)
         (prog-mode . hl-todo-mode))
  :config
  (setq hl-todo-highlight-punctuation ":"
        hl-todo-keyword-faces
        `(("TODO"       warning bold)
          ("FIXME"      error bold)
          ("HACK"       font-lock-constant-face bold)
          ("REVIEW"     font-lock-keyword-face bold)
          ("NOTE"       success bold)
          ("DEPRECATED" font-lock-doc-face bold))))

(use-package indent-bars
  :ensure t
  :hook (prog-mode . indent-bars-mode))

(use-package counsel
  :after ivy
  :config (counsel-mode))

(use-package ivy
  :bind
  ;; ivy-resume resumes the last Ivy-based completion.
  (("C-c C-r" . ivy-resume)
   ("C-x B" . ivy-switch-buffer-other-window))
  :custom
  (setq ivy-use-virtual-buffers t)
  (setq ivy-count-format "(%d/%d) ")
  (setq enable-recursive-minibuffers t)
  :config
  (ivy-mode))

(use-package all-the-icons-ivy-rich
  :ensure t
  :init (all-the-icons-ivy-rich-mode 1))

(use-package ivy-rich
  :after ivy
  :ensure t
  :init (ivy-rich-mode 1) ;; this gets us descriptions in M-x.
  :custom
  (ivy-virtual-abbreviate 'full
   ivy-rich-switch-buffer-align-virtual-buffer t
   ivy-rich-path-style 'abbrev)
  :config
  (ivy-set-display-transformer 'ivy-switch-buffer
                               'ivy-rich-switch-buffer-transformer))

(use-package lsp-mode
  :ensure t
  :init
  (setq lsp-keymap-prefix "C-c l")
  :commands (lsp lsp-deferred)
  :config
  (setq lsp-prefer-flymake nil
        lsp-enable-snippet t
        lsp-auto-guess-root t))

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode
  :config
  (setq lsp-ui-sideline-ignore-duplicate t
        lsp-ui-doc-enable t
        lsp-ui-peek-enable t))

(use-package cc-mode
  :elpaca nil
  :config
  (add-hook 'c-mode-hook #'lsp-deferred)
  (add-hook 'c++-mode-hook #'lsp-deferred))

(use-package python-mode
  :ensure t
  :hook (python-mode . lsp-deferred))

(defun compile-and-run-c ()
  (interactive)
  (let* ((file (file-name-nondirectory buffer-file-name))
         (base (file-name-sans-extension file))
         (compile-command (format "gcc -Wall %s -o %s && ./%s" file base base)))
    (save-buffer)
    (compile compile-command t)))

(defun run-python-script ()
  (interactive)
  (save-buffer)
  (let ((file (file-name-nondirectory buffer-file-name)))
    (compile (format "python3 %s" file))
    (switch-to-buffer-other-window "*compilation*")))

(defun run-shell-script ()
  (interactive)
  (save-buffer)
  (let ((file (file-name-nondirectory buffer-file-name)))
    (compile (format "bash %s" file))
    (switch-to-buffer-other-window "*compilation*")))

(defun compile-and-run-arm-assembly ()
  (interactive)
  (save-buffer)
  (let* ((file (file-name-nondirectory buffer-file-name))
         (base (file-name-sans-extension file))
         ;; Linux ARM64 assembly compilation
         (compile-command (format "as --64 -o %s.o %s && ld -o %s %s.o && ./%s"
                                  base file base base base)))
    (when (file-exists-p base)
      (delete-file base))
    (compile compile-command)
    (switch-to-buffer-other-window "*compilation*")))

(defun compile-and-run-verilog ()
  (interactive)
  (save-buffer)
  (let* ((file (file-name-nondirectory buffer-file-name))
         (base (file-name-sans-extension file))
         (module-file (if (string-match-p "_tb\.v$" file)
                          (concat (file-name-sans-extension
                                   (replace-regexp-in-string "_tb" "" file))
                                  ".v")
                        file))
         (tb-file (if (string-match-p "_tb\.v$" file)
                      file
                    (concat base "_tb.v")))
         (compile-command (format "iverilog -o %s %s %s && vvp %s -fst"
                                  base module-file tb-file base)))
    (compile compile-command)
    (switch-to-buffer-other-window "*compilation*")
    (run-with-timer
     3 nil
     (lambda ()
       (let ((fst-file (concat base ".fst"))
             (vcd-file (concat base ".vcd")))
         (when (or (file-exists-p fst-file) (file-exists-p vcd-file))
           (start-process "gtkwave" nil "gtkwave" 
                         (if (file-exists-p fst-file) fst-file vcd-file))))))))

;; F5 key bindings for different modes
(add-hook 'c-mode-hook
          (lambda () (local-set-key [f5] 'compile-and-run-c)))
(add-hook 'python-mode-hook
          (lambda () (local-set-key [f5] 'run-python-script)))
(add-hook 'sh-mode-hook
          (lambda () (local-set-key [f5] 'run-shell-script)))
(add-hook 'verilog-mode-hook
          (lambda () (local-set-key [f5] 'compile-and-run-verilog)))
(add-hook 'asm-mode-hook
          (lambda () (local-set-key [f5] 'compile-and-run-arm-assembly)))

(add-to-list 'auto-mode-alist '("\.c\'" . c-mode))
(add-to-list 'auto-mode-alist '("\.py\'" . python-mode))
(add-to-list 'auto-mode-alist '("\.sh\'" . sh-mode))
(add-to-list 'auto-mode-alist '("\.v\'" . verilog-mode))
(add-to-list 'auto-mode-alist '("\.sv\'" . verilog-mode))
(add-to-list 'auto-mode-alist '("\.asm\'" . asm-mode))

(use-package lsp-ui
  :ensure t
  :commands lsp-ui-mode)

;; Markdown Mode Configuration
(use-package markdown-mode
  :ensure t
  :mode ("README\\.md\\'" . gfm-mode)
  :init (setq markdown-command "/opt/homebrew/bin/multimarkdown"))

;; Optional: Add live preview functionality
(use-package markdown-preview-mode
  :ensure t)

;; Optional: Enable markdown-preview-mode automatically for markdown files
(add-hook 'markdown-mode-hook 'markdown-preview-mode)

(use-package winner
  :elpaca nil	;; do not install from external repo
  :config
  (winner-mode 1))

(defun toggle-maximize-buffer ()
  "Toggle between maximizing the current buffer and restoring the previous window configuration."
  (interactive)
  (if (= 1 (length (window-list)))
      (jump-to-register '_)
    (progn
      (set-register '_ (list (current-window-configuration)))
      (delete-other-windows))))

(global-set-key [escape] 'keyboard-escape-quit)

(use-package doom-modeline
  :ensure t
  :init (doom-modeline-mode 1)
  :config
  (setq doom-modeline-height 35      ;; sets modeline height
        doom-modeline-bar-width 5    ;; sets right bar width
        doom-modeline-persp-name t   ;; adds perspective name to modeline
        doom-modeline-persp-icon t)) ;; adds folder icon next to persp name

(use-package neotree
  :config
  (setq neo-smart-open t
        neo-show-hidden-files t
        neo-window-width 55
        neo-window-fixed-size nil
        inhibit-compacting-font-caches t
        projectile-switch-project-action 'neotree-projectile-action) 
        ;; truncate long file names in neotree
        (add-hook 'neo-after-create-hook
           #'(lambda (_)
               (with-current-buffer (get-buffer neo-buffer-name)
                 (setq truncate-lines t)
                 (setq word-wrap nil)
                 (make-local-variable 'auto-hscroll-mode)
                 (setq auto-hscroll-mode nil)))))

;; show hidden files

(use-package toc-org
    :commands toc-org-enable
    :init (add-hook 'org-mode-hook 'toc-org-enable))

(add-hook 'org-mode-hook 'org-indent-mode)
(use-package org-bullets)
(add-hook 'org-mode-hook (lambda () (org-bullets-mode 1)))

(electric-indent-mode -1)
(setq org-edit-src-content-indentation 0)

(require 'org-tempo)

;; (setenv "PKG_CONFIG" "/opt/homebrew/bin/pkg-config")
;; (use-package pdf-tools
;;   :ensure t
;;   :defer t
;;   :commands (pdf-loader-install)
;;   :mode "\\.pdf\\'"
;;   :bind (:map pdf-view-mode-map
;;               ("j" . pdf-view-next-line-or-next-page)
;;               ("k" . pdf-view-previous-line-or-previous-page)
;;               ("C-=" . pdf-view-enlarge)
;;               ("C--" . pdf-view-shrink))
;;   :init (pdf-loader-install)
;;   :config (add-to-list 'revert-without-query ".pdf"))

;; ;; Set midnight colors for dark mode
;; (setq pdf-view-midnight-colors '("#ffffff" . "#000000"))

;; ;; Automatically enable midnight mode for PDFs
;; (add-hook 'pdf-view-mode-hook 'pdf-view-midnight-minor-mode)


;; (add-hook 'pdf-view-mode-hook #'(lambda () (interactive) (display-line-numbers-mode -1)
;;                                                          (blink-cursor-mode -1)
;;                                                          (doom-modeline-mode -1)))
;;(setenv "PKG_CONFIG" "/opt/homebrew/bin/pkg-config")
(use-package pdf-tools
  :ensure t
  :defer t
  :mode "\\.pdf\\'"
  :bind (:map pdf-view-mode-map
              ("j" . pdf-view-next-line-or-next-page)
              ("k" . pdf-view-previous-line-or-previous-page)
              ("C-=" . pdf-view-enlarge)
              ("C--" . pdf-view-shrink)
              ("C-c t" . my/pdf-view-toggle-theme))
  :init
  (pdf-loader-install)
  :config
  (add-to-list 'revert-without-query ".pdf")

  ;; Define color schemes
  (defvar my/pdf-dark-colors '("#ffffff" . "#000000")   ; white text on black
    "PDF Tools midnight mode colors for dark theme.")
  (defvar my/pdf-light-colors '("#000000" . "#ffffff")  ; black text on white
    "PDF Tools midnight mode colors for light theme.")

  ;; Track current theme
  (defvar my/pdf-current-theme 'light
    "Current PDF theme: 'dark or 'light.")

  ;; Toggle function
  (defun my/pdf-view-toggle-theme ()
    "Toggle between light and dark themes in pdf-view-mode."
    (interactive)
    (if (eq my/pdf-current-theme 'dark)
        (progn
          (setq pdf-view-midnight-colors my/pdf-light-colors)
          (setq my/pdf-current-theme 'light))
      (setq pdf-view-midnight-colors my/pdf-dark-colors)
      (setq my/pdf-current-theme 'dark))
    (pdf-view-midnight-minor-mode 1)
    (pdf-view-redisplay))

  ;; Set initial theme
  (defun my/pdf-view-set-initial-theme ()
    (setq pdf-view-midnight-colors
          (if (eq my/pdf-current-theme 'dark)
              my/pdf-dark-colors
            my/pdf-light-colors))
    (pdf-view-midnight-minor-mode 1))

  (add-hook 'pdf-view-mode-hook #'my/pdf-view-set-initial-theme)
  (add-hook 'pdf-view-mode-hook (lambda ()
                                  (display-line-numbers-mode -1)
                                  (blink-cursor-mode -1)
                                  (doom-modeline-mode -1))))

(setq package-archives '(("melpa" . "https://melpa.org/packages/")
                        ("gnu" . "https://elpa.gnu.org/packages/")
                        ("nongnu" . "https://elpa.nongnu.org/nongnu/")))

(setq elpaca-recipe-sources '(elpaca-melpa-recipes
                             elpaca-gnu-elpa-recipes
                             elpaca-nongnu-elpa-recipes))

(add-to-list 'exec-path "/opt/homebrew/bin")
(setq-default with-editor-emacsclient-executable "/opt/homebrew/bin/emacsclient")

(use-package perspective
  :custom
  ;; NOTE! I have also set 'SCP =' to open the perspective menu.
  ;; I'm only setting the additional binding because setting it
  ;; helps suppress an annoying warning message.
  (persp-mode-prefix-key (kbd "C-c M-p"))
  :init 
  (persp-mode)
  :config
  ;; Sets a file to write to when we save states
  (setq persp-state-default-file "~/.config/emacs/sessions"))

;; This will group buffers by persp-name in ibuffer.
(add-hook 'ibuffer-hook
          (lambda ()
            (persp-ibuffer-set-filter-groups)
            (unless (eq ibuffer-sorting-mode 'alphabetic)
              (ibuffer-do-sort-by-alphabetic))))

;; Automatically save perspective states to file when Emacs exits.
(add-hook 'kill-emacs-hook #'persp-state-save)

(use-package projectile
  :config
  (projectile-mode 1))

(use-package rainbow-delimiters
  :hook ((emacs-lisp-mode . rainbow-delimiters-mode)
         (clojure-mode . rainbow-delimiters-mode)))

(use-package rainbow-mode
  :hook 
  ((org-mode prog-mode) . rainbow-mode))

(defun reload-init-file ()
  (interactive)
  (load-file user-init-file)
  (load-file user-init-file))

(delete-selection-mode 1)    ;; You can select text and delete it by typing.
(electric-indent-mode -1)    ;; Turn off the weird indenting that Emacs does by default.
(electric-pair-mode 1)       ;; Turns on automatic parens pairing
;; The following prevents <> from auto-pairing when electric-pair-mode is on.
;; Otherwise, org-tempo is broken when you try to <s TAB...
(add-hook 'org-mode-hook (lambda ()
           (setq-local electric-pair-inhibit-predicate
                   `(lambda (c)
                  (if (char-equal c ?<) t (,electric-pair-inhibit-predicate c))))))
(global-auto-revert-mode t)  ;; Automatically show changes if the file has changed
(global-display-line-numbers-mode 1) ;; Display line numbers
(global-visual-line-mode t)  ;; Enable truncated lines
(menu-bar-mode -1)           ;; Disable the menu bar 
(scroll-bar-mode -1)         ;; Disable the scroll bar
(tool-bar-mode -1)           ;; Disable the tool bar
(setq org-edit-src-content-indentation 0) ;; Set src block automatic indent to 0 instead of 2.
(setq use-file-dialog nil) ;; No file dialog
(setq use-dialog-box nil) ;; No dialog
(setq use-up-windows nil) ;; No pop-up window

(use-package smartparens
  :ensure t
  :hook (prog-mode . smartparens-mode) ;; Enable Smartparens in programming modes
  :config
  (require 'smartparens-config)        ;; Load the default Smartparens configuration
  (show-smartparens-global-mode t))    ;; Enable visual hints for matching pairs

(use-package eshell-syntax-highlighting
  :after esh-mode
  :config
  (eshell-syntax-highlighting-global-mode +1))

;; eshell-syntax-highlighting -- adds fish/zsh-like syntax highlighting.
;; eshell-rc-script -- your profile for eshell; like a bashrc for eshell.
;; eshell-aliases-file -- sets an aliases file for the eshell.
  
(setq eshell-rc-script (concat user-emacs-directory "eshell/profile")
      eshell-aliases-file (concat user-emacs-directory "eshell/aliases")
      eshell-history-size 5000
      eshell-buffer-maximum-lines 5000
      eshell-hist-ignoredups t
      eshell-scroll-to-bottom-on-input t
      eshell-destroy-buffer-when-process-dies t
      eshell-visual-commands'("bash" "fish" "htop" "ssh" "top" "zsh"))

(use-package vterm
:config
(setq shell-file-name "/usr/bin/bash"
      vterm-max-scrollback 5000))

(with-eval-after-load 'vterm-toggle
  (defcustom vterm-toggle-hide-hook nil
    "Hook run when hiding the vterm buffer."
    :type '(repeat function)
    :group 'vterm-toggle))

(use-package vterm-toggle
  :after vterm
  :config
  (setq vterm-toggle-fullscreen-p nil)
  (setq vterm-toggle-scope 'project)
  (add-to-list 'display-buffer-alist
               '((lambda (buffer-or-name _)
                     (let ((buffer (get-buffer buffer-or-name)))
                       (with-current-buffer buffer
                         (or (equal major-mode 'vterm-mode)
                             (string-prefix-p vterm-buffer-name (buffer-name buffer))))))
                  (display-buffer-reuse-window display-buffer-at-bottom)
                  ;;(display-buffer-reuse-window display-buffer-in-direction)
                  ;;display-buffer-in-direction/direction/dedicated is added in emacs27
                  ;;(direction . bottom)
                  ;;(dedicated . t) ;dedicated is supported in emacs27
                  (reusable-frames . visible)
                  (window-height . 0.3))))

(use-package multi-vterm
  :ensure t
  :elpaca (multi-vterm
           :repo "suonlight/multi-vterm"
           :files ("*.el" "README.md"))
  :config
  ;; Set dedicated window height (optional)
  (setq multi-vterm-dedicated-window-height-percent 30)
  
  ;; Evil mode integration (since you're using evil)
  (add-hook 'vterm-mode-hook 
            (lambda () 
              (setq-local evil-insert-state-cursor 'box)
              (evil-insert-state)))
  
  ;; Key remappings for vterm mode to work better with evil
  (evil-define-key 'insert vterm-mode-map (kbd "C-e") #'vterm--self-insert)
  (evil-define-key 'insert vterm-mode-map (kbd "C-f") #'vterm--self-insert)
  (evil-define-key 'insert vterm-mode-map (kbd "C-a") #'vterm--self-insert)
  (evil-define-key 'insert vterm-mode-map (kbd "C-v") #'vterm--self-insert)
  (evil-define-key 'insert vterm-mode-map (kbd "C-b") #'vterm--self-insert)
  (evil-define-key 'insert vterm-mode-map (kbd "C-w") #'vterm--self-insert)
  (evil-define-key 'insert vterm-mode-map (kbd "C-u") #'vterm--self-insert)
  (evil-define-key 'insert vterm-mode-map (kbd "C-d") #'vterm--self-insert)
  (evil-define-key 'insert vterm-mode-map (kbd "C-n") #'vterm--self-insert)
  (evil-define-key 'insert vterm-mode-map (kbd "C-m") #'vterm--self-insert))

(use-package sudo-edit
  :config
    (sam/leader-keys
      "fu" '(sudo-edit-find-file :wk "Sudo find file")
      "fU" '(sudo-edit :wk "Sudo edit file")))

(use-package tldr
 :ensure t)

;; Add the themes directory to the custom theme load path
(add-to-list 'custom-theme-load-path "~/.emacs.d/themes/")

(use-package doom-themes
  :ensure t
  :config
  ;; Enable bold and italic styles
  (setq doom-themes-enable-bold t    ; if nil, bold is universally disabled
        doom-themes-enable-italic t) ; if nil, italics is universally disabled

   ;; Automatically accept all themes as safe
  (setq custom-safe-themes t))

  ;; enable theme for neo-tree as well
  ;;(doom-themes-neotree-config)

 ;; Install timu-rouge-theme package separately to ensure availability
(use-package timu-rouge-theme
  :ensure t
  :after doom-themes
  :config
  ;; Load timu-rouge theme with no confirmation required
  (load-theme 'timu-rouge t))

;; Ensure the selected theme persists across sessions
(customize-set-variable 'custom-enabled-themes '(timu-rouge))

(add-to-list 'default-frame-alist '(alpha-background . 85)) ; For all new frames henceforth

(use-package verilog-mode
  :ensure t
  :mode ("\\.v\\'" "\\.sv\\'")
  :config
  (setq verilog-auto-newline nil)
  (setq verilog-auto-indent-on-newline t)
  (setq verilog-indent-level 3)
  (setq verilog-indent-level-module 3)
  (setq verilog-indent-level-declaration 3)
  (setq verilog-indent-level-behavioral 3)
  (setq verilog-indent-level-directive 1)
  (setq verilog-case-indent 2)
  (setq verilog-auto-endcomments t)
  (setq verilog-minimum-comment-distance 40)
  (setq verilog-indent-begin-after-if t)
  (setq verilog-auto-lineup 'declarations)
  (setq verilog-linter "my_lint_shell_command")
  (setq verilog-auto-arg-sort t)
  (setq verilog-case-fold nil))

(defun verilog-compile ()
  (interactive)
  (compile (format "iverilog -o %s %s && vvp %s"
                   (file-name-sans-extension (buffer-name))
                   (buffer-name)
                   (file-name-sans-extension (buffer-name)))))

(add-hook 'verilog-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c C-c") 'verilog-compile)))

(add-hook 'verilog-mode-hook
          (lambda ()
            (local-set-key (kbd "C-c C-a") 'verilog-auto)))

(use-package vundo
  :commands (vundo)
  :config
  ;; Enable compact display to take less on-screen space
  (setq vundo-compact-display t)

  ;; Customize faces for better contrast
  (custom-set-faces
   '(vundo-node ((t (:foreground "#808080"))))
   '(vundo-stem ((t (:foreground "#808080"))))
   '(vundo-highlight ((t (:foreground "#FFFF00")))))

  ;; Optionally, set other configurations
  ;; (setq vundo-glyph-alist vundo-unicode-symbols)
  ;; (setq vundo-roll-back-on-quit nil)
)

(use-package which-key
  :init
    (which-key-mode 1)
  :diminish
  :config
  (setq which-key-side-window-location 'bottom
	which-key-sort-order #'which-key-key-order-alpha
	which-key-sort-uppercase-first nil
	which-key-add-column-padding 1
	which-key-max-display-columns nil
	which-key-min-display-lines 6
	which-key-side-window-slot -10
	which-key-side-window-max-height 0.25
	which-key-idle-delay 0.8
	which-key-max-description-length 25
	which-key-allow-imprecise-window-fit nil
	which-key-separator " → " ))
