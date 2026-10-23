#!/bin/bash
# Универсальный скрипт компиляции LaTeX с зеркалированием PDF и служебных файлов
# Использование: latex-mirror-build.sh <workspace_folder> <path_to_tex_file>


LOG="/tmp/latex-build.log"

WORKSPACE="$1"    # Корень проекта (открытая папка в VSCodium)
TEX_FILE="$2.tex" # Полный путь к .tex файлу

if [ -z "$WORKSPACE" ] || [ -z "$TEX_FILE" ]; then
  echo "Ошибка: нужно указать рабочую папку и файл .tex"
  exit 1
fi


WORKSPACE="$(realpath "$WORKSPACE")"
TEX_FILE="$(realpath "$TEX_FILE")"

cd "$WORKSPACE"

REL_PATH="${TEX_FILE#$WORKSPACE/}"
BASE_NAME="$(basename "$REL_PATH" .tex)"
REL_DIR="$(dirname "$REL_PATH")"
LONG_DIR="$(dirname "$TEX_FILE")"

if [ "$REL_DIR" = "." ]; then
  REL_DIR=""
fi

PDF_DIR="$WORKSPACE/pdf/$REL_DIR"
CACHE_DIR="$WORKSPACE/.lcashe/$REL_DIR"
LOG_DIR="$WORKSPACE/.texlog/$REL_DIR"

mkdir -p "$PDF_DIR" "$CACHE_DIR" "$LOG_DIR" 

echo "Данные для сборки:"

echo "Сейчас в: $(pwd)"
echo "Корень проекта: $WORKSPACE"
echo "Пути к"
echo "    PDF: $PDF_DIR"
echo "    LOG: $LOG_DIR"
echo "    CACHE: $CACHE_DIR"
echo "    Папке с файлом относительно корня проекта: $REL_DIR"
echo "    Папка с файлосм относительно корня системы: $LONG_DIR"
echo "    Латех файл: $REL_PATH"
echo "    Файл: $BASE_NAME"

echo "Приступаю к созданию зеркала папки с файлом"

for file in "$LONG_DIR"/*; do
    if [[ ! ( $file == *"~"  || $file == *"#" ) ]]; then
	ln -s "$file" "$CACHE_DIR"
	echo "Ссылка создана для $file"
    else
	echo "    $file: ссылка не создана"
    fi
done

cd "$CACHE_DIR"

latexmk -pdf -xelatex -interaction=nonstopmode -synctex=2 "$BASE_NAME"

cp "$(basename "$BASE_NAME" .tex).pdf" "$PDF_DIR"
cp "$(basename "$BASE_NAME" .tex).log" "$LOG_DIR"

cd "$WORKSPACE"

rm -rf .lcashe
