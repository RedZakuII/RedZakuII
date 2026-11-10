;;; local.example.el --- template for ~/.emacs.d/local.el  -*- lexical-binding: t; -*-

;; Copy this file to ~/.emacs.d/local.el on each machine and edit it.  local.el
;; is NOT tracked in git; init.el loads it last, so anything here overrides the
;; shared config.  Everything below is optional.

;;; Screen -------------------------------------------------------------
;; Font size is tuned per screen.  (The family is chosen in init.el.)

(set-face-attribute 'default nil :height 120)

;; To force a specific font family on this machine:
;; (set-face-attribute 'default nil :family "JetBrains Mono")

;;; Extra packages ------------------------------------------------------
;; Packages only this machine wants.  Install with M-x my/install-missing-packages.

;; (setq my/extra-packages '(eat ghostel))

;;; Claude Code (work machine only) ---------------------------------------
;; Skip this whole section on machines that don't use Claude Code.
;;
;; One-time install (claude-code-ide is not on a package archive); pinned to a
;; reviewed commit:
;;   M-: (package-vc-install "https://github.com/manzaltu/claude-code-ide.el"
;;                           "50a3d55262805d7207889ed429ff30da96fbf68b"
;;                           nil 'claude-code-ide)
;;
;; ghostel needs a native module in ~/.emacs.d/ghostel/ named
;; ghostel-module.dylib (.so on Linux) plus a ghostel-module.version file
;; containing the version.  Download the release asset yourself and verify both
;; its SHA-256 against the release page and its build attestation:
;;   gh attestation verify <file> --repo dakra/ghostel
;;
;; (when (locate-library "claude-code-ide")
;;   (global-set-key (kbd "C-c C-'") #'claude-code-ide-menu)
;;   (setq ghostel-module-directory (expand-file-name "ghostel" user-emacs-directory)
;;         ghostel-module-auto-install nil)
;;   (setq claude-code-ide-terminal-backend 'ghostel
;;         claude-code-ide-enable-execute-code nil))

;;; Other things that typically belong here ---------------------------------
;; - OS quirks, e.g. (when (eq system-type 'gnu/linux) ...)
;; - Work-only tools and keybindings
;; - Paths that differ between machines

;;; local.example.el ends here
