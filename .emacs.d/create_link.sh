#~/bin/bash

for d in ~/.myconfig/.emacs.d/*/; do
  b=$(basename "$d")
  rm -rf "$HOME/.emacs.d/$b"
done

find ~/.myconfig/.emacs.d/ -maxdepth 1 -mindepth 1 -type d -exec ln -s -t ~/.emacs.d/ {} +

ln -s ~/.myconfig/.emacs.d/init.el ~/.emacs.d
ln -s ~/.myconfig/.emacs.d/early-init.el ~/.emacs.d
ln -s ~/.myconfig/.emacs.d/cheatsheet.org ~/.emacs.d
ln -s ~/.myconfig/.emacs.d/skript ~/.emacs.d
