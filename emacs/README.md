# Emacs config

A shared base for every machine, plus a per-machine file for anything that
differs. This directory lives in the `RedZakuII` repo; `install.sh` symlinks the
shared files into `~/.emacs.d/`, so editing either path edits the same file.

**This repo is public (it is the GitHub profile repo).** Only put things here
that are safe to publish: no tokens, hostnames, work details or personal data.
Anything machine- or employer-specific belongs in the untracked `local.el`.

| File | Tracked? | Purpose |
|---|---|---|
| `init.el` | yes (symlinked) | The shared config. Works on macOS and Linux, with or without any given package installed. |
| `early-init.el` | yes (symlinked) | Runs before `init.el`. Contains a macOS-only native-compilation workaround (guarded, so it does nothing elsewhere). |
| `local.example.el` | yes (symlinked) | Template for `local.el`. |
| `local.el` | **no** | This machine's settings: screen size, work-only tools, OS quirks. Loaded last, so it overrides anything in `init.el`. |
| `custom.el` | **no** | Emacs' Custom state (saved themes, installed-package list). Per-machine, so not shared. |

## Setting up a new machine

1. Install Emacs 31, clone `RedZakuII` to `~/projects/`, and run
   `~/projects/RedZakuII/emacs/install.sh` (creates the symlinks; never touches
   `local.el` or `custom.el`).
2. `cp ~/.emacs.d/local.example.el ~/.emacs.d/local.el`, then edit it (at least
   the font size). Leave the Claude Code section commented out unless that
   machine uses Claude Code.
3. Start Emacs, then run `M-x my/install-missing-packages`. It installs
   everything in `my/core-packages` (see `init.el`) plus anything the machine
   lists in `my/extra-packages`.
4. Optional tools the config uses when present: `aspell` (spell-check),
   `pandoc` (Markdown preview), `xmllint` (XML formatting; Linux package
   `libxml2-utils`). Missing ones are simply skipped.

If `local.el` has an error, Emacs reports a warning and still starts.

## What lives where

- **Shared (`init.el`)**: org setup and capture templates, the welcome page,
  completion (vertico/consult), Markdown, Python (eglot if a language server is
  installed), JSON/XML pretty-printing on `C-c p`, theme and font choice.
- **This work Mac (`local.el`)**: font size, the Claude Code integration
  (claude-code-ide + ghostel, with the pinned commit and the module
  verification steps), and the extra packages those need.

## Work Mac extras outside this directory

- `~/org/`: notes, its own git repo.
- `~/.local/bin/org-capture-clipboard`: quick-capture hotkey script (macOS:
  uses `osascript`).
- `~/.local/bin/emacs`: opens files in the running GUI Emacs, or starts
  Emacs.app. Stands in for the old Homebrew `emacs` command.

Emacs.app is the only Emacs on that machine; it runs the default server
(started from `init.el`), which both scripts use.
