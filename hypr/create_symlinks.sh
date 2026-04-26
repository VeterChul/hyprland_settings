#~/bin/bash

for d in ~/.myconfig/hypr/*/; do
    b=$(basename "$d")
    rm -rf "$HOME/.config/$b"
done

find ~/.myconfig/hypr/ -maxdepth 1 -mindepth 1 -type d -exec ln -s -t ~/.config/ {} +