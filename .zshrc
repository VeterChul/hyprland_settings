# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

source /usr/share/cachyos-zsh-config/cachyos-config.zsh
# После строки с source zsh-history-substring-search добавить:
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down

# Для vim режима (если используете)
bindkey -M vicmd 'k' history-substring-search-up
bindkey -M vicmd 'j' history-substring-search-down
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
ZSH_THEME=""
# Отключить автоматические темы Oh-My-Zsh
DISABLE_AUTO_TITLE="true"
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Ручная настройка prompt
PROMPT='%F{201}%n@%m %F{201}%~ %F{201}%#%f '
RPROMPT=''

# Цвета для команд
eval "$(dircolors -b)"
ny() {
  clear
  echo "❄️ Happy Linux New Year! ❄️"
  date
  cal
}


