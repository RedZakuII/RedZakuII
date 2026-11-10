;;; early-init.el --- runs before ~/.emacs  -*- lexical-binding: t; -*-

;; Workaround: on very new macOS releases, libgccjit passes a bogus
;; -mmacosx-version-min (e.g. 18.0) to clang, which rejects it and makes every
;; native compilation fail.  Overriding it with a valid deployment target fixes
;; that.  This must live in early-init.el because Emacs starts JIT-compiling
;; built-in libraries before ~/.emacs is read.  Safe to remove once a fixed
;; Emacs/libgccjit is installed.
(when (and (eq system-type 'darwin)
           (fboundp 'native-comp-available-p)
           (native-comp-available-p))
  (setq native-comp-driver-options '("-mmacosx-version-min=15.0")))
