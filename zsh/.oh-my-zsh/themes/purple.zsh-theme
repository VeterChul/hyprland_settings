# --- Настройки ---
POWERLINE_SYMBOLS=1  # 1 - использовать powerline, 0 - обычные скобки
COLOR_SIDES=0
# --- Символы разделителей ---
if (( POWERLINE_SYMBOLS )); then
  SEP_L=$'\ue0b2'   # левый скос (треугольник вправо)
  SEP_R=$'\ue0b0'   # правый скос (треугольник влево)
else
  SEP_L='>'
  SEP_R='<'
fi

# --- Функция построения левой группы сегментов ---
# Принимает список аргументов: фон_цвет цвет_текста текст
build_left() { 
  local result="" prev_bg=$COLOR_SIDES first=$1
  result+="%${COLOR_SIDES}F╭─%F{$first}$SEP_L%f%k"
  while (( $# >= 3 )); do
    local bg=$1 fg=$2 text=$3; shift 3
    if [[ $text != "" ]]; then
      if [[ -n $prev_bg ]]; then
        result+="%K{$bg}%F{$prev_bg}$SEP_R%f%k"
      fi
      result+="%K{$bg}%F{$fg}$text %f%k"
      prev_bg=$bg
    fi
  done
  if [[ -n $prev_bg ]]; then
    result+="%K{default}%F{$prev_bg}$SEP_R%f%k"
  fi
  echo -n "$result"
}

# build_left() {
#   local result="" prev_bg=""
#   while (( $# >= 3 )); do
#     local bg=$1 fg=$2 text=$3; shift 3
#     if [[ -n $prev_bg ]]; then
#       result+="%K{$bg}%F{$prev_bg}$SEP_R%f%k"
#     fi
#     result+="%K{$bg}%F{$fg} $text %f%k"
#     prev_bg=$bg
#   done
#   if [[ -n $prev_bg ]]; then
#     result+="%K{default}%F{$prev_bg}$SEP_R%f%k"
#   fi
#   echo -n "$result"
# }

# --- Функция построения правой группы сегментов ---
build_right() {
  local result="" prev_bg="" first=$1
  while (( $# >= 3 )); do
    local bg=$1 fg=$2 text=$3; shift 3
    if [[ $text != "" ]]; then
      
      if [[ -n $prev_bg ]]; then
        result="%K{$bg}%F{$prev_bg}$SEP_L%f%k$result"
      fi
      result="%K{$bg}%F{$fg} $text %f%k$result"
      prev_bg=$bg
    fi
  done
  if [[ -n $prev_bg ]]; then
    result="%K{default}%F{$prev_bg}$SEP_L%f%k$result"
  fi
  echo -n "$result%F{$first}$SEP_R%${COLOR_SIDES}F─╮"
}


git_status() {
    # Проверяем, находимся ли в git-репозитории
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        return   # ничего не выводим
    fi

    # Получаем имя текущей ветки (или короткий хэш в detached HEAD)
    local branch
    branch=$(git branch --show-current 2>/dev/null)
    if [ -z "$branch" ] || [ "$branch" = "HEAD" ]; then
        branch=$(git rev-parse --short HEAD 2>/dev/null)
    fi

    local porcelain
    porcelain=$(git status --porcelain 2>/dev/null)

    # Новые переменные: modified (изменённые не в индексе) и untracked (неотслеживаемые)
    local modified=0
    local untracked=0
    if [ -n "$porcelain" ]; then
        modified=$(echo "$porcelain" | grep -c '^ M')
        modified1=$(echo "$porcelain" | grep -c '^A ')
        untracked=$(echo "$porcelain" | grep -c '^??')
    fi
    # Проверка наличия upstream и подсчёт коммитов ahead
    local ahead=0
    if git rev-parse --abbrev-ref --symbolic-full-name @{u} >/dev/null 2>&1; then
        # Используем read для безопасного разделения чисел (даже с табуляцией)
        local behind_str ahead_str
        read behind_str ahead_str <<< "$(git rev-list --count --left-right @{u}...HEAD 2>/dev/null)"
        # Если удалось получить второе число, используем его, иначе оставляем 0
        if [[ "$ahead_str" =~ ^[0-9]+$ ]]; then
            ahead=$ahead_str
        else
            ahead=0
        fi
    fi

    # Формируем итоговую строку
    local result="$branch"
    if [[ $modified != 0 ]]; then
        result+=" ⚠$modified"
    fi
    if [[ $ahead != 0 ]]; then
        result+=" ⇡$ahead"
    fi
    if [ $untracked != 0 ]; then
        result+=" !$untracked"
    fi

    echo "$result"
}

visible_length() {
  local s=${(%)1}
  # удаляем %{...%} (конструкции нулевой ширины)
  s=${s//\%\{*\%\}/}
  # удаляем escape-последовательности через sed
  s=$(echo -n "$s" | sed 's/\x1b\[[0-9;]*[a-zA-Z]//g')
  # удаляем одиночные escape (если остались)
  s=${s//$'\e'/}
  # отладка: посмотрим, что получилось
  echo ${#s}
}

exit_status_prompt() {
  if (( _exit_code == 0 )); then
    echo -n "%F{green}✓%f"
  else
    echo -n "%F{red}✗%f"
  fi
}

# Путь к вашей папке с картинками
IMAGE_DIR="$HOME/.oh-my-zsh/themes/pic"

# Массив файлов с расширениями (nullglob включён через (N))
images=( $IMAGE_DIR/*.(webp|png|jpg|jpeg|gif|PNG|JPG|JPEG|GIF)(N) )

# Если есть хотя бы одна картинка
if (( ${#images} > 0 )); then
    # Случайный индекс (zsh: индексация с 1)
    random_index=$(( RANDOM % ${#images} + 1 ))
    random_image=$images[$random_index]
    height=$(( RANDOM % 11 + 15 ))
    # Вывод через chafa
    chafa --format symbols --symbols block --size x$height "$random_image"
fi

# --- Определяем левые сегменты (порядок: фон, цвет текста, содержимое) ---

update_top_line() {
  _exit_code=$?   # запоминаем код последней команды

  left_segments=(
    "0" "201" '%~'              # текущий путь
  )

  # --- Правые сегменты ---
  right_segments=(
    "0" "201" '%*'            # время
    "55" "121" "$(git_status)"           # пользователь@хост
  #  "55" "121" '$(exit_status_prompt)' 
    "201" "0"  '%m@%n'
  )

  
  left_top=$(build_left "${left_segments[@]}")
  right_top=$(build_right "${right_segments[@]}")

  left_len=$(visible_length "$left_top")
  right_len=$(visible_length "$right_top")

  #pad=$((COLUMNS - left_len - right_len))
  pad=$(( ${COLUMNS:-80} - left_len - right_len - 1))
  (( pad < 0 )) && pad=0   # если места мало, не вставляем отрицательное число пробелов
  #pad=0

  top_line="${left_top}${(l:$pad:::)}$right_top"
  
  PROMPT="${top_line}"$'\n'"%${COLOR_SIDES}F╰─"

  RPROMPT="%${COLOR_SIDES}F─╯"

}

# Добавляем функцию в precmd
precmd_functions+=(update_top_line)

# Первый вызов, чтобы сразу отобразить корректно
update_top_line

