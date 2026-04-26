#!/usr/bin/env bash

# Проверяем наличие makoctl и jq
if ! command -v makoctl &> /dev/null || ! command -v jq &> /dev/null; then
    echo '{"text":"","tooltip":"makoctl/jq not found"}'
    exit 1
fi

# Получаем список уведомлений
NOTIFICATIONS=$(makoctl list)
echo $NOTIFICATIONS

п# Считаем количество
COUNT=$(echo "$NOTIFICATIONS" | jq '.data | length' 2>/dev/null || echo "0")

# Если есть уведомления
if [[ "$COUNT" -gt 0 ]]; then
    # Собираем детальную информацию для tooltip
    TOOLTIP="<b>Уведомления ($COUNT):</b>\n"
    
    # Берем последние 5 уведомлений
    echo "$NOTIFICATIONS" | jq -r '.data[-5:] | reverse | .[] | 
        "<b>\(if .app_name and .app_name != "" then .app_name else "Application" end)</b>\n" +
        "\(if .summary then .summary else "" end)\n" +
        "\(if .body then .body | gsub("\n"; " ") | substr(0, 50) + "..." else "" end)\n" +
        "<span size=\"small\"><i>\(.time | strftime("%H:%M"))</i></span>\n"' 2>/dev/null | while read -r line; do
        TOOLTIP+="${line}\n"
    done
    
    # Убираем последний перенос строки
    TOOLTIP=${TOOLTIP%\\n}
    
    # Определяем иконку в зависимости от количества
    ICON=""
    if [[ "$COUNT" -gt 5 ]]; then
        ICON=" $COUNT"
    elif [[ "$COUNT" -gt 9 ]]; then
        ICON=" 9+"
    else
        ICON=" $COUNT"
    fi
    
    # Выводим JSON для Waybar
    cat <<EOF
{
    "text": "$ICON",
    "tooltip": "$TOOLTIP",
    "class": "notification"
}
EOF
else
    # Нет уведомлений
    cat <<EOF
{
    "text": "",
    "tooltip": "Нет уведомлений",
    "class": "no-notification"
}
EOF
fi