#!/bin/sh
# Link the shared Emacs config into ~/.emacs.d.  Safe to re-run.
# Per-machine files (local.el, custom.el) are never touched.
set -eu
here=$(cd "$(dirname "$0")" && pwd)
dest="${EMACS_DIR:-$HOME/.emacs.d}"
mkdir -p "$dest"
for f in init.el early-init.el local.example.el; do
  target="$dest/$f"
  if [ -L "$target" ] && [ "$(readlink "$target")" = "$here/$f" ]; then
    echo "ok       $f"
  elif [ -e "$target" ] || [ -L "$target" ]; then
    echo "SKIPPED  $f (exists and is not our link; move it aside and re-run)" >&2
  else
    ln -s "$here/$f" "$target"
    echo "linked   $f"
  fi
done
[ -e "$dest/local.el" ] || echo "next: cp $dest/local.example.el $dest/local.el and edit it"
