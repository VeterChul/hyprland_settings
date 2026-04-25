#!/bin/bash
set -e  # прерывать при ошибке

# Цветной вывод
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${GREEN}=== Установка кастомного greeter (CRT Greeter) ===${NC}"

# 1. Установка пакетов
echo "Установка greetd, cage, seatd, python-prompt-toolkit..."
sudo pacman -S --noconfirm greetd cage seatd python-prompt-toolkit

# 2. Создание пользователя greeter (если не существует)
if ! id -u greeter >/dev/null 2>&1; then
    echo "Создание пользователя greeter..."
    sudo useradd -r -M -G video,seat greeter
else
    echo "Пользователь greeter уже существует, добавляем в группы video,seat..."
    sudo usermod -a -G video,seat greeter
fi

# 3. Создание изолированной HOME для greeter
echo "Создание /var/lib/crt-greeter..."
sudo mkdir -p /var/lib/crt-greeter/.config
sudo chown -R greeter:greeter /var/lib/crt-greeter
sudo chmod 750 /var/lib/crt-greeter

# 4. Создание симлинков (предполагается, что репозиторий клонирован в ~/VeterDM)
REPO_DIR="$HOME/.myconfig/VeterDM"   # измените, если путь другой
if [ ! -d "$REPO_DIR" ]; then
    echo -e "${RED}Ошибка: репозиторий не найден в $REPO_DIR${NC}"
    exit 1
fi

echo "Создание симлинков из $REPO_DIR в системные каталоги..."
./create-link.sh

# 5. Права на скрипты
sudo chmod +x /usr/local/bin/crt-greeter.py
sudo chmod +x /usr/local/bin/start-greeter.sh
sudo chmod +x /usr/local/bin/cool-retro-term-castom

# --- Дополнительные настройки для аутентификации и доступа ---
echo "Настройка прав для аутентификации..."
sudo chmod u+s /usr/bin/unix_chkpwd 2>/dev/null || true
if getent group shadow >/dev/null; then
    sudo usermod -a -G shadow greeter
fi

# Настройка ACL для доступа greeter к репозиторию (если используется симлинки из ~)
if [ -d "$HOME/.myconfig/VeterDM" ]; then
    echo "Настройка ACL для доступа greeter к домашнему репозиторию..."
    sudo setfacl -m u:greeter:x /home
    sudo setfacl -m u:greeter:x $HOME
    sudo setfacl -m u:greeter:x $HOME/.myconfig
    sudo setfacl -m u:greeter:x $HOME/.myconfig/VeterDM
    sudo setfacl -m u:greeter:rx $HOME/.myconfig/VeterDM/bin
    sudo setfacl -m u:greeter:rx $HOME/.myconfig/VeterDM/share
    sudo setfacl -m u:greeter:r $HOME/.myconfig/VeterDM/bin/*
    sudo setfacl -R -m u:greeter:r $HOME/.myconfig/VeterDM/share/*
fi

echo "Настройка прав на /var/lib/crt-greeter..."
sudo chown -R greeter:greeter /var/lib/crt-greeter
sudo chmod 750 /var/lib/crt-greeter

# 6. Настройка PAM для greetd (если файла нет – создаём)
if [ ! -f /etc/pam.d/greetd ]; then
    echo "Создание /etc/pam.d/greetd..."
    sudo tee /etc/pam.d/greetd > /dev/null <<EOF
#%PAM-1.0
auth        requisite   pam_nologin.so
auth        required    pam_unix.so    try_first_pass nullok
auth        optional    pam_permit.so
account     required    pam_unix.so
password    required    pam_deny.so
session     required    pam_unix.so
session     optional    pam_systemd.so
EOF
fi

# # 7. Отключение старого DM и включение greetd
# echo "Переключение на greetd..."
# sudo systemctl stop sddm 2>/dev/null || true
# sudo systemctl disable sddm 2>/dev/null || true
# sudo rm -f /etc/systemd/system/display-manager.service
# sudo systemctl enable --now greetd.service

echo -e "${GREEN}Установка завершена! Перезагрузитесь или переключитесь на TTY1 (Ctrl+Alt+F1), чтобы увидеть экран входа.${NC}"