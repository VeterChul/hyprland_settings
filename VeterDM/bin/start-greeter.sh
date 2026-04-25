#!/bin/bash

export HOME="/var/lib/crt-greeter"
export XDG_CONFIG_HOME="$HOME/.config"

# Указываем рендерер OpenGL вместо Vulkan
export WLR_RENDERER=gles2

mkdir -p "$XDG_CONFIG_HOME"

# (Опционально) Копируем шаблон конфигурации, если он существует
#if [ -f "/usr/local/share/crt-greeter/cool-retro-term.conf" ]; then
#    mkdir -p "$XDG_CONFIG_HOME/cool-retro-term"
#    cp "/usr/local/share/crt-greeter/cool-retro-term.conf" "$XDG_CONFIG_HOME/cool-retro-term/"
#fi

exec cage -s -d -- /usr/local/bin/cool-retro-term-castom --fullscreen