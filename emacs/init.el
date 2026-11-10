;;; init.el --- personal config  -*- lexical-binding: t; -*-

;;;
;;; MELPA Configuration
;;;
(require 'package)
(add-to-list 'package-archives '("melpa" . "https://melpa.org/packages/") t)
;; Comment/uncomment this line to enable MELPA Stable if desired.  See `package-archive-priorities`
;; and `package-pinned-packages`. Most users will not need or want to do this.
;;(add-to-list 'package-archives '("melpa-stable" . "https://stable.melpa.org/packages/") t)

;;;
;;; Packages
;;;
;; This file is the shared base for every machine.  Anything specific to one
;; machine (screen size, work-only tools, OS quirks) lives in local.el, which is
;; not tracked in git and loads last; see the end of this file.
;;
;; `my/core-packages' is what this shared config uses.  A machine adds its own
;; extras to `my/extra-packages' from local.el.  On a new machine, run
;; M-x my/install-missing-packages once.
(defvar my/core-packages
  '(exec-path-from-shell magit flycheck markdown-mode olivetti org-modern org-roam
    vertico orderless marginalia consult
    kotlin-mode go-mode yaml-mode dockerfile-mode jsonnet-mode groovy-mode ini-mode)
  "Packages the shared config uses.")

(defvar my/extra-packages nil
  "Machine-specific packages; set this from local.el.")

(defun my/install-missing-packages ()
  "Install every core or machine-specific package that is not installed yet."
  (interactive)
  (let ((missing (seq-remove #'package-installed-p
                             (append my/core-packages my/extra-packages))))
    (if (null missing)
        (message "All packages are installed")
      (package-refresh-contents)
      (dolist (p missing) (package-install p))
      (message "Installed: %s" (mapconcat #'symbol-name missing ", ")))))

(defmacro my/with-package (library &rest body)
  "Run BODY only if LIBRARY (a symbol) is installed, so a missing package
never breaks startup."
  (declare (indent 1))
  `(when (locate-library ,(symbol-name library)) ,@body))

;;;
;;; Custom file (keeps Custom's auto-generated settings out of this file;
;;; it is per-machine state and is not tracked in git)
;;;
(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(load custom-file 'noerror)

;;;
;;; Key bindings
;;;
(global-set-key "\C-cl" 'org-store-link)
(global-set-key "\C-ca" 'org-agenda)
(global-set-key (kbd "C-x g") 'magit-status)

;;;
;;; Syntax checking
;;;
(add-hook 'kotlin-mode-hook 'flycheck-mode)

;;;
;;; Environment (PATH, etc. from the login shell)
;;;
(when (and (memq window-system '(mac ns x pgtk))
           (require 'exec-path-from-shell nil t))
  (exec-path-from-shell-initialize))

;;;
;;; Cosmetic settings
;;;
(tool-bar-mode -1)
(menu-bar-mode -1)
;; Font: the first of these that is installed (nothing is set if none is, so the
;; system default is used).  Size is screen-specific, so it is set in local.el.
(let ((family (seq-find (lambda (f) (find-font (font-spec :family f)))
                        '("IBM 3270" "Monaco" "DejaVu Sans Mono" "Menlo"))))
  (when family
    (set-face-attribute 'default nil :family family)))
(load-theme 'modus-vivendi-tinted t)
(add-hook 'shell-mode-hook 'ansi-color-for-comint-mode-on)
(add-hook 'comint-output-filter-functions 'ansi-color-process-output)
(setq ring-bell-function 'ignore)

;;;
;;; Sensible defaults
;;;
(setq inhibit-startup-screen t
      use-short-answers t            ; y/n instead of yes/no
      require-final-newline t
      create-lockfiles nil)          ; no .#foo files cluttering projects
(global-auto-revert-mode 1)          ; reload files changed on disk
(save-place-mode 1)                  ; reopen files at last cursor position
(recentf-mode 1)
(savehist-mode 1)                    ; remember minibuffer history
(show-paren-mode 1)
(column-number-mode 1)
(delete-selection-mode 1)            ; typing replaces the selection
(when (fboundp 'which-key-mode)      ; key hints (built in since Emacs 30)
  (which-key-mode 1))

;; Completion: vertico (vertical UI) + orderless (match words in any order)
;; + marginalia (annotations) + consult (better search/switch commands).
;; Falls back to the built-in fido if those packages are missing.
(if (require 'vertico nil t)
    (progn
      (vertico-mode 1)
      (marginalia-mode 1)
      (setq completion-styles '(orderless basic)
            completion-category-overrides '((file (styles basic partial-completion))))
      (global-set-key (kbd "C-x b") #'consult-buffer)   ; buffers, recent files, bookmarks
      (global-set-key (kbd "M-y")   #'consult-yank-pop) ; browse the kill ring
      (global-set-key (kbd "M-s l") #'consult-line)     ; search lines in this buffer
      (global-set-key (kbd "M-s g") #'consult-grep)     ; grep the project
      (global-set-key (kbd "M-g i") #'consult-imenu))   ; jump to a function/heading
  (fido-vertical-mode 1))

;;;
;;; Org mode
;;;
;; Layout:  ~/org/inbox.org   quick capture, triage later (C-c c)
;;          ~/org/tasks.org   organized tasks (shown in the agenda)
;;          ~/org/ideas.org   thoughts and ideas
;;          ~/org/drafts/     one file per letter/proposal (C-c d)
(setq org-directory "~/org/"
      org-default-notes-file "~/org/inbox.org"
      org-agenda-files '("~/org/inbox.org" "~/org/tasks.org"))

(global-set-key (kbd "C-c c") 'org-capture)

;; Task workflow
(setq org-todo-keywords
      '((sequence "TODO(t)" "NEXT(n)" "WAITING(w@)" "|" "DONE(d!)" "CANCELLED(c@)"))
      org-log-done 'time
      org-log-into-drawer t)

;; Refile with C-c C-w: pick a destination in any of these files
(setq org-refile-targets '((org-agenda-files :maxlevel . 2)
                           ("~/org/ideas.org" :maxlevel . 2))
      org-refile-use-outline-path 'file
      org-outline-path-complete-in-steps nil)

;; Capture templates (C-c c)
(setq org-capture-templates
      '(("t" "Task" entry (file "~/org/inbox.org")
         "* TODO %?\n  %U\n  %i" :empty-lines 1)
        ("i" "Idea" entry (file "~/org/ideas.org")
         "* %?\n  %U\n  %i" :empty-lines 1)
        ("n" "Note" entry (file "~/org/inbox.org")
         "* %?\n  %U\n  %a" :empty-lines 1)
        ;; Follow-ups from Outlook / Slack (typed by hand, nothing is read from them)
        ("e" "Email follow-up" entry (file "~/org/inbox.org")
         "* TODO Reply: %^{Subject} :email:\n  %U\n  From: %^{From}\n  %?"
         :empty-lines 1)
        ("s" "Slack follow-up" entry (file "~/org/inbox.org")
         "* TODO Follow up: %^{Topic} :slack:\n  %U\n  Where: %^{Channel or person}\n  %?"
         :empty-lines 1)
        ;; Whatever is on the clipboard, quoted (the hotkey script uses this one).
        ;; %c = newest kill-ring entry, which Emacs keeps in sync with the system
        ;; clipboard (%x reads the X11 clipboard and returns nothing on macOS).
        ("c" "Clipboard" entry (file "~/org/inbox.org")
         "* TODO %?\n  %U\n  #+begin_quote\n  %c\n  #+end_quote"
         :empty-lines 1)))

;; Quick capture from anywhere: `emacsclient --eval (my/org-capture-frame "c")'
;; asks this running Emacs to open a small capture frame, which closes when done.
;; (On the work Mac, ~/.local/bin/org-capture-clipboard wraps that for a hotkey.)
;; The GUI Emacs owns the default server, so plain `emacsclient' reaches it.
(require 'server)
(when (and (display-graphic-p) (not (server-running-p)))
  (server-start))

(defvar my/org-capture-frame nil
  "Frame opened for a quick capture; closed again when the capture ends.")

(defun my/--close-capture-frame ()
  "Close the quick-capture frame, if there is one and it isn't the last frame."
  (when (and (frame-live-p my/org-capture-frame) (cdr (frame-list)))
    (delete-frame my/org-capture-frame))
  (setq my/org-capture-frame nil))

(defun my/org-capture-frame (&optional keys)
  "Open a small dedicated frame and start an org capture there.
KEYS selects the capture template; nil shows the template menu."
  (interactive)
  ;; Read the system clipboard now, from the frame that is already up: that puts
  ;; it in the kill ring, so the template's %c finds it even inside the new
  ;; frame (where reading it directly returned nil).  If both the clipboard and
  ;; the kill ring are empty, %c would error, so make sure there is an entry.
  (ignore-errors (current-kill 0 t))
  (unless kill-ring (kill-new ""))
  (let ((frame (make-frame '((name . "org-capture") (width . 90) (height . 22)))))
    (setq my/org-capture-frame frame)
    (select-frame-set-input-focus frame)
    (condition-case err
        (progn (org-capture nil keys)
               (delete-other-windows))
      (quit (my/--close-capture-frame))
      (error (my/--close-capture-frame)   ; never leave a stray frame behind
             (signal (car err) (cdr err))))))

(add-hook 'org-capture-after-finalize-hook #'my/--close-capture-frame)

;; Agenda: a weekly view plus everything marked NEXT
(setq org-agenda-custom-commands
      '(("n" "Agenda and NEXT actions"
         ((agenda "")
          (todo "NEXT")))))

;; New draft (letter/proposal): prompts for a title, makes ~/org/drafts/<slug>.org
(defun my/org-new-draft (title)
  "Create and open a new draft file in `org-directory'/drafts for TITLE."
  (interactive "sDraft title: ")
  (let* ((slug (replace-regexp-in-string
                "^-+\\|-+$" ""
                (replace-regexp-in-string "[^a-z0-9]+" "-" (downcase title))))
         (file (expand-file-name (concat slug ".org")
                                 (expand-file-name "drafts" org-directory))))
    (when (string-empty-p slug) (user-error "Title needs at least one letter or number"))
    (make-directory (file-name-directory file) t)
    (find-file file)
    (when (zerop (buffer-size))
      (insert (format "#+title: %s\n#+date: %s\n\n" title (format-time-string "%Y-%m-%d"))))))
(global-set-key (kbd "C-c d") 'my/org-new-draft)

;; Comfortable reading and writing
(setq org-startup-indented t
      org-hide-emphasis-markers t
      org-return-follows-link t
      org-pretty-entities t
      org-ellipsis " ▾")

;; Focused writing: centered column (olivetti), hard-wrap at 80 columns,
;; spell-check as you type
(my/with-package olivetti
  (setq olivetti-body-width 82)
  (add-hook 'org-mode-hook #'olivetti-mode))
(add-hook 'org-mode-hook #'auto-fill-mode)
(add-hook 'org-mode-hook (lambda () (setq fill-column 80)))
(setq ispell-program-name (or (executable-find "aspell") "ispell"))
(when (executable-find "aspell")
  (add-hook 'org-mode-hook #'flyspell-mode))

;; Prettier headings, tags, tables and checkboxes
(when (require 'org-modern nil t)
  (setq org-auto-align-tags nil
        org-tags-column 0
        org-catch-invisible-edits 'show-and-error
        org-special-ctrl-a/e t
        org-insert-heading-respect-content t)
  (add-hook 'org-mode-hook #'org-modern-mode)
  (add-hook 'org-agenda-finalize-hook #'org-modern-agenda))

;; Code blocks: run shell/python/elisp, and "<s TAB" style shortcuts
(with-eval-after-load 'org
  (org-babel-do-load-languages
   'org-babel-load-languages
   '((emacs-lisp . t) (shell . t) (python . t)))
  (require 'org-tempo))

;; Linked notes (org-roam): notes live in ~/org/roam/
(setq org-roam-directory (file-truename (expand-file-name "roam" org-directory)))
(global-set-key (kbd "C-c n f") #'org-roam-node-find)
(global-set-key (kbd "C-c n i") #'org-roam-node-insert)
(global-set-key (kbd "C-c n l") #'org-roam-buffer-toggle)
(global-set-key (kbd "C-c n c") #'org-roam-capture)
(with-eval-after-load 'org-roam
  (org-roam-db-autosync-mode 1))

;; Start on the welcome page / cheatsheet
(let ((welcome (expand-file-name "welcome.org" org-directory)))
  (when (file-exists-p welcome)
    (setq initial-buffer-choice welcome)))

;;;
;;; Markdown
;;;
;; Soft-wrapped (not hard-wrapped) so GitHub-style comments render correctly.
;; C-c C-c l = live preview (uses pandoc), C-c C-c p = preview in browser.
(setq markdown-command "pandoc -f gfm -t html5"
      markdown-fontify-code-blocks-natively t
      markdown-header-scaling t)
(add-hook 'markdown-mode-hook #'visual-line-mode)
(my/with-package olivetti
  (add-hook 'markdown-mode-hook #'olivetti-mode))
(when (executable-find "aspell")
  (add-hook 'markdown-mode-hook #'flyspell-mode))

;;;
;;; Python
;;;
;; eglot (built in) starts automatically, but only if a Python language server
;; is installed.  Nothing is installed or downloaded by this config.
(defun my/python-eglot-maybe ()
  "Start eglot in a Python buffer if a known language server is on PATH."
  (when (seq-some #'executable-find
                  '("pyright-langserver" "basedpyright-langserver" "pylsp"
                    "jedi-language-server" "ruff"))
    (eglot-ensure)))
(add-hook 'python-mode-hook #'my/python-eglot-maybe)
(setq eglot-autoshutdown t)             ; stop the server with its last buffer

;;;
;;; Pretty-print JSON and XML
;;;
;; C-c p formats the region (or the whole buffer) as JSON or XML, guessing from
;; the first character.  M-x my/pretty-json, my/minify-json and my/pretty-xml
;; do one specific thing.  XML needs xmllint (macOS has it; Linux: libxml2-utils).
(require 'json)

(defun my/--region-or-buffer ()
  "Return (BEG END) for the active region, or for the whole buffer."
  (if (use-region-p)
      (list (region-beginning) (region-end))
    (list (point-min) (point-max))))

;;; JSON ---------------------------------------------------------------

(defun my/--reformat-json (beg end minimize)
  "Replace the JSON between BEG and END with a reformatted copy.
The text is first checked with Emacs' strict native parser, and the
copy is formatted off to the side, so invalid JSON signals an error and
leaves the buffer untouched (json.el alone is lenient and can half-edit)."
  (let ((text (buffer-substring-no-properties beg end)))
    (json-parse-string text)            ; strict; signals on invalid JSON
    (let ((result (with-temp-buffer
                    (insert text)
                    (json-pretty-print-buffer minimize)
                    (buffer-string))))
      ;; Keep the selection's trailing-newline state as it was.
      (cond ((and (string-suffix-p "\n" text) (not (string-suffix-p "\n" result)))
             (setq result (concat result "\n")))
            ((and (not (string-suffix-p "\n" text)) (string-suffix-p "\n" result))
             (setq result (string-trim-right result "\n"))))
      (goto-char beg)
      (delete-region beg end)
      (insert result))))

(defun my/pretty-json (beg end)
  "Pretty-print the JSON in the region, or the whole buffer.
Key order and duplicate keys are kept; numbers are normalized
\(1.50 -> 1.5).  Invalid JSON is an error and changes nothing."
  (interactive (my/--region-or-buffer))
  (my/--reformat-json beg end nil))

(defun my/minify-json (beg end)
  "Collapse the JSON in the region, or the whole buffer, onto one line."
  (interactive (my/--region-or-buffer))
  (my/--reformat-json beg end t))

;;; XML ----------------------------------------------------------------

(defun my/--xmllint (text)
  "Return TEXT formatted by `xmllint --format', or signal the xmllint error."
  (unless (executable-find "xmllint")
    (user-error "xmllint not found (macOS includes it; on Linux install libxml2-utils)"))
  (let ((errfile (make-temp-file "xmllint-err")))
    (unwind-protect
        (with-temp-buffer
          (insert text)
          (let ((status (call-process-region (point-min) (point-max) "xmllint"
                                             t (list t errfile) nil
                                             "--format" "-")))
            (if (zerop status)
                (buffer-string)
              (error "xmllint: %s"
                     (string-trim
                      (with-temp-buffer
                        (insert-file-contents errfile)
                        (buffer-string)))))))
      (delete-file errfile))))

(defun my/--strip-xml-decl (string)
  "Remove a leading <?xml ...?> declaration line from STRING."
  (replace-regexp-in-string "\\`<\\?xml[^>]*\\?>\n" "" string))

(defun my/--unwrap-xml (formatted)
  "Undo the temporary <my-wrapper> root that was added around a fragment."
  (with-temp-buffer
    (insert (my/--strip-xml-decl formatted))
    (goto-char (point-min))
    (delete-line)                       ; <my-wrapper>
    (goto-char (point-max))
    (forward-line -1)
    (delete-line)                       ; </my-wrapper>
    (indent-rigidly (point-min) (point-max) -2)
    (buffer-string)))

(defun my/pretty-xml (beg end)
  "Pretty-print the XML in the region, or the whole buffer.
Uses `xmllint'.  A snippet with several root elements is handled by
formatting it inside a temporary wrapper element."
  (interactive (my/--region-or-buffer))
  (let* ((text (buffer-substring-no-properties beg end))
         (had-decl (string-match-p "\\`[ \t\n]*<\\?xml" text))
         (result
          (condition-case first-err
              (my/--xmllint text)
            (error
             (condition-case nil
                 (my/--unwrap-xml
                  (my/--xmllint (concat "<my-wrapper>" text "</my-wrapper>")))
               (error (signal (car first-err) (cdr first-err))))))))
    ;; xmllint adds a declaration to snippets that had none; drop it again.
    (unless had-decl
      (setq result (my/--strip-xml-decl result)))
    ;; Keep the selection's trailing-newline state as it was.
    (unless (string-suffix-p "\n" text)
      (setq result (string-trim-right result "\n")))
    (goto-char beg)
    (delete-region beg end)
    (insert result)))

;;; Either ---------------------------------------------------------------

(defun my/pretty-print (beg end)
  "Pretty-print JSON or XML in the region, or the whole buffer.
The format is guessed from the first non-blank character."
  (interactive (my/--region-or-buffer))
  (let ((first (save-excursion
                 (goto-char beg)
                 (skip-chars-forward " \t\n\r" end)
                 (char-after))))
    (cond ((memq first '(?{ ?\[)) (my/pretty-json beg end))
          ((eq first ?<) (my/pretty-xml beg end))
          (t (user-error "Doesn't look like JSON or XML")))))

(global-set-key (kbd "C-c p") #'my/pretty-print)

;;;
;;; macOS quirks
;;;
;; Emacs started from Finder/the Dock begins in "/"; start in the home directory.
(when (eq system-type 'darwin)
  (setq default-directory "~/")
  (setq command-line-default-directory "~/"))

;;;
;;; Tabs settings
;;;
(setq-default indent-tabs-mode nil)
(setq c-basic-offset 4)
(setq tab-width 4)

;;;
;;; Java indentation (editing only; no IDE tooling)
;;;
(add-hook 'java-mode-hook
          (lambda ()
            (setq c-default-style "stroustrup"
                  c-basic-offset 4
                  tab-width 4
                  indent-tabs-mode nil)))

;;;
;;; Backup Files
;;;
(setq
 backup-by-copying t
 backup-directory-alist
 '(("." . "~/.saves/"))
 delete-old-versions t
 kept-new-versions 6
 kept-old-versions 2
 version-control t)

;;;
;;; Machine-specific settings (keep this last)
;;;
;; ~/.emacs.d/local.el is NOT tracked in git.  Put anything that belongs to one
;; machine only there: screen size, work-only tools, OS quirks.  It loads last, so
;; it can override anything above.  See local.example.el for a template.  An
;; error in it is reported as a warning and never stops Emacs from starting.
(defvar my/local-file (expand-file-name "local.el" user-emacs-directory)
  "Per-machine settings file, loaded at the very end of init.el.")

(condition-case err
    (load my/local-file 'noerror 'nomessage)
  (error (display-warning 'local
                          (format "Error while loading %s: %s"
                                  my/local-file (error-message-string err))
                          :error)))
