for d in hypr/*/; do
    b=$(basename "$d")
    rm -rf "$HOME/.config/$b"
done

find hypr/ -maxdepth 1 -mindepth 1 -type d -exec ln -s -t ~/.config/ {} +