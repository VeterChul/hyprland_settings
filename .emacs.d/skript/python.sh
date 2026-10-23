#!/bin/bash
# Универсальный скрипт компиляции LaTeX с зеркалированием PDF и служебных файлов
# Использование: latex-mirror-build.sh <workspace_folder> <path_to_tex_file>


LOG="/tmp/python-build.log"

WORKSPACE="$1"    # Корень проекта (открытая папка в VSCodium)
PY_FILE="$2" # Полный путь к .py файлу

if [ -z "$WORKSPACE" ] || [ -z "$PY_FILE" ]; then
  echo "Ошибка: нужно указать рабочую папку и файл .py"
  exit 1
fi


WORKSPACE="$(realpath "$WORKSPACE")"
PY_FILE="$(realpath "$PY_FILE")"

cd "$WORKSPACE"

if [ -d ".venv" ]; then
    echo "Найдена локальная папка python. Используется версия питона от туда"
    
    source .venv/bin/activate
fi

echo "Запускаеться файл: $PY_FILE"
python $PY_FILE

