#!/usr/bin/env bash
# Установщик конфигов из ~/.myconfig.
# Только симлинки: home -> ~, config -> ~/.config, local -> ~/.local/share.
# set -e намеренно не стоит: ошибка одного пункта не должна прерывать остальные.

set -u

# Корень репозитория = каталог, где лежит этот скрипт.
REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Бэкап старых конфигов. Каталог создаётся только если реально понадобится.
BACKUP_DIR="$HOME/.myconfig-backup/$(date +%Y%m%d-%H%M%S)"
BACKUP_USED=0
FAILED=0

# Без этих трёх каталогов скрипту нечего делать.
for d in home config local; do
  [ -d "$REPO/$d" ] || { echo "Нет каталога $REPO/$d — запусти из корня репозитория."; exit 1; }
done

# Спрашивает да/нет. Пустой ввод = да.
confirm() {
  local a
  read -r -p "$1 [Y/n] " a
  [ -z "$a" ] && return 0
  [ "$a" = y ] || [ "$a" = Y ] || [ "$a" = д ] || [ "$a" = Д ]
}

# Переносит существующий путь в бэкап, сохраняя структуру:
# ~/.config/hypr -> ~/.myconfig-backup/20261023-201500/.config/hypr
backup() {
  local dst="$1"
  local save="$BACKUP_DIR/${dst#"$HOME"/}"
  mkdir -p "$(dirname "$save")" || return 1
  mv "$dst" "$save" || return 1
  BACKUP_USED=1
  echo "  бэкап: $dst -> $save"
}

# link <путь внутри репо> <куда в системе>
link() {
  local src="$REPO/$1" dst="$2"

  if [ ! -e "$src" ]; then
    echo "  пропуск: нет источника $src"
    FAILED=1
    return 1
  fi

  if [ -L "$dst" ]; then
    # Ссылка уже указывает туда же — ничего не делаем.
    if [ "$(readlink -f "$dst")" = "$(readlink -f "$src")" ]; then
      echo "  уже на месте: $dst"
      return 0
    fi
    # Ссылка на другое место — заменяем, бэкапить нечего.
    rm -f "$dst"
  elif [ -e "$dst" ]; then
    # Реальные настройки приложения — сохраняем перед подменой.
    if ! backup "$dst"; then
      echo "  ошибка: не удалось сохранить $dst"
      FAILED=1
      return 1
    fi
  fi

  # Родитель может отсутствовать (например, ~/.oh-my-zsh/themes).
  mkdir -p "$(dirname "$dst")" || { FAILED=1; return 1; }
  ln -s "$src" "$dst" || { FAILED=1; return 1; }
  echo "  ссылка: $dst -> $src"
}

# ---------- home: сложные случаи, линкуем по частям ----------

# zsh: свои файлы и темы. Сам ~/.oh-my-zsh — отдельный репозиторий, его не трогаем.
install_zsh() {
  link home/zsh/.zshrc                             "$HOME/.zshrc"
  link home/zsh/.p10k.zsh                          "$HOME/.p10k.zsh"
  link home/zsh/.oh-my-zsh/themes/purple.zsh-theme "$HOME/.oh-my-zsh/themes/purple.zsh-theme"
  link home/zsh/.oh-my-zsh/themes/pic              "$HOME/.oh-my-zsh/themes/pic"
}

# emacs: ~/.emacs.d целиком линковать нельзя, иначе cache/, eln-cache/, tramp/
# начнут писаться в репозиторий. elpa не линкуем — пакеты ставит package.el.
install_emacs() {
  local f
  for f in init.el early-init.el cheatsheet.org modules site-lisp skript themes; do
    link "home/.emacs.d/$f" "$HOME/.emacs.d/$f"
  done
}

# ---------- config / local: одна ссылка на каталог ----------

# Находит пункт в config/ или local/ и линкует целиком.
install_dir_item() {
  local name="$1"
  if [ -d "$REPO/config/$name" ]; then
    link "config/$name" "$HOME/.config/$name"
  elif [ -d "$REPO/local/$name" ]; then
    link "local/$name" "$HOME/.local/share/$name"
  else
    echo "  пропуск: нет config/$name или local/$name"
    FAILED=1
  fi
}

# Audacious живёт в двух местах сразу: конфиг в config, скины в local.
# В списке пунктов он один раз — второй симлинк создаётся здесь же.
install_audacious() {
  link config/audacious "$HOME/.config/audacious"
  link local/audacious  "$HOME/.local/share/audacious"
}

# ---------- список пунктов ----------
# Порядок = порядок вопросов. Audacious один, хотя ссылок две.
ITEMS=(
  zsh emacs
  hypr hyprlock kitty waybar mako rofi flameshot nvim mango swaylock eDEX-UI noctalia
  audacious
  cool-retro-term
)

# Диспетчер: сложные пункты имеют свои функции, остальные — общий обработчик.
run_item() {
  case "$1" in
    zsh)       install_zsh ;;
    emacs)     install_emacs ;;
    audacious) install_audacious ;;
    *)         install_dir_item "$1" ;;
  esac
}

# ---------- основной цикл ----------

ALL=0
confirm "Установить все конфиги?" && ALL=1

if [ "$ALL" = 1 ]; then
  echo "Режим: всё подряд."
else
  echo "Режим: по одному пункту."
fi

for item in "${ITEMS[@]}"; do
  if [ "$ALL" = 0 ]; then
    confirm "Установить $item?" || { echo "  пропущено: $item"; continue; }
  fi
  echo "== $item"
  run_item "$item"
done

# ---------- итог ----------

if [ "$BACKUP_USED" = 1 ]; then
  echo "Старые настройки сохранены в: $BACKUP_DIR"
else
  echo "Бэкап не понадобился."
fi

if [ "$FAILED" = 1 ]; then
  echo "Были ошибки — см. сообщения выше."
  exit 1
fi

exit 0
