#!/bin/bash

export HOME="/var/lib/crt-greeter"
export XDG_CONFIG_HOME="$HOME/.config"

export WLR_BACKEND=drm
export WLR_RENDERER=gles2

mkdir -p "$XDG_CONFIG_HOME"
# (Опционально) Копируем шаблон конфигурации, если он существует
#if [ -f "/usr/local/share/crt-greeter/cool-retro-term.conf" ]; then
#    mkdir -p "$XDG_CONFIG_HOME/cool-retro-term"
#    cp "/usr/local/share/crt-greeter/cool-retro-term.conf" "$XDG_CONFIG_HOME/cool-retro-term/"
#fi

export SHELL=/usr/local/bin/crt-wrapper.sh

# Замените строку с exec cage на эту:
exec cage -s -d -- /usr/local/bin/cool-retro-term-castom --fullscreen #-e /usr/local/bin/crt-greeter.py