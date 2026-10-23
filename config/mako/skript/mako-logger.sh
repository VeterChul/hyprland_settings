#!/bin/bash
# Скрипт для логирования уведомлений mako в файл

# Файл лога. Можешь изменить путь на любой другой.
LOG_FILE="$HOME/.local/share/mako/notifications.log"

# Получаем ID уведомления, которое передаёт mako
NOTIFICATION_ID="$1"

# С помощью makoctl получаем информацию об уведомлении в формате JSON
# и добавляем её в лог-файл.
# Опция --json у makoctl history даёт отличный структурированный вывод.
if command -v makoctl &> /dev/null && [ -n "$NOTIFICATION_ID" ]; then
    # Используем makoctl history, чтобы получить детали конкретного уведомления по ID.
    # Это вытянет только что добавленное уведомление.
    makoctl history --json | jq -c --arg id "$NOTIFICATION_ID" \
      '.data[].[] | select(.id.data | tostring == $id)' >> "$LOG_FILE"
fi
