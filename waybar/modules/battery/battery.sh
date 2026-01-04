battery="BAT0"
status=$(cat /sys/class/power_supply/$battery/status)
capacity=$(cat /sys/class/power_supply/$battery/capacity)
values=(10 30 50 70 90)
icons=(" " " " " " " " " ")
charging_icon=""
full_icon=""
icon=""

# Функция для преобразования часов в формат ЧЧ:ММ
convert_to_hms() {
    local hours=$1
    local int_hours
    local minutes
    
    # Проверяем, что hours - число
    if ! [[ $hours =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
        echo "00:00"
        return
    fi
    
    # Получаем целую часть часов
    int_hours=$(echo "$hours" | cut -d. -f1)
    
    # Если hours целое число
    if [[ "$hours" == *.* ]]; then
        # Вычисляем минуты из дробной части
        local decimal_part=$(echo "$hours" | cut -d. -f2)
        # Берем только первые две цифры десятичной части
        decimal_part="${decimal_part:0:2}"
        minutes=$(echo "scale=0; $decimal_part * 60 / 100" | bc 2>/dev/null)
        # Если bc не установлен, используем bash арифметику
        if [ -z "$minutes" ]; then
            minutes=$(( (${decimal_part} * 60) / 100 ))
        fi
    else
        minutes=0
    fi
    
    # Корректируем, если minutes >= 60
    if [ $minutes -ge 60 ]; then
        minutes=$((minutes - 60))
        int_hours=$((int_hours + 1))
    fi
    
    # Форматируем вывод
    printf "%02d:%02d" "$int_hours" "$minutes"
}


get_discharge_time() {
    local battery_path="/sys/class/power_supply/BAT0"
    local time_str=""
    
    # Проверяем, что батарея существует
    if [ ! -d "$battery_path" ]; then
        echo "Разрядится через: Н/Д"
        return 1
    fi
    
    # Проверяем статус батареи
    local status=$(cat "$battery_path/status" 2>/dev/null)
    if [ "$status" != "Discharging" ]; then
        echo "Разрядится через: Н/Д"
        return 1
    fi
    
    # Пытаемся получить данные о энергии и мощности
    if [ -f "$battery_path/energy_now" ] && [ -f "$battery_path/power_now" ]; then
        # Для батарей с энергетическими характеристиками (Wh)
        local energy_now=$(cat "$battery_path/energy_now" 2>/dev/null)
        local power_now=$(cat "$battery_path/power_now" 2>/dev/null)
        
        local hours=$(python -c "print($energy_now / $power_now)")
        if [ -n "$hours" ]; then
            time_str=$(convert_to_hms "$hours")
        fi
       
    fi
    
    # Если не удалось рассчитать время
    if [ -z "$time_str" ]; then
        echo "Разрядится через: Н/Д"
    else
        echo "Разрядится через: $time_str"
    fi
}

get_charge_time() {
    local battery_path="/sys/class/power_supply/BAT0"
    local time_str=""
    
    # Проверяем, что батарея существует
    if [ ! -d "$battery_path" ]; then
        echo "Зарядится через: Н/Д"
        return 1
    fi
    
    # Проверяем статус батареи
    local status=$(cat "$battery_path/status" 2>/dev/null)
    if [ "$status" != "Charging" ]; then
        echo "Зарядится через: Н/Д"
        return 1
    fi
    
    # Пытаемся получить данные о энергии и мощности
    if [ -f "$battery_path/energy_now" ] && [ -f "$battery_path/energy_full" ] && [ -f "$battery_path/power_now" ]; then
        local energy_now=$(cat "$battery_path/energy_now" 2>/dev/null)
        local energy_full=$(cat "$battery_path/energy_full" 2>/dev/null)
        local power_now=$(cat "$battery_path/power_now" 2>/dev/null)
        local hours=$(python -c "print(($energy_full - $energy_now) / $power_now)")
        if [ -n "$hours" ]; then
            time_str=$(convert_to_hms "$hours")
        else
            time_str="00:00"
        fi

    fi
    
    # Если не удалось рассчитать время
    if [ -z "$time_str" ]; then
        echo "Зарядится через: Н/Д"
    else
        echo "Зарядится через: $time_stra"
    fi
}


if [ "$status" = "Charging" ]; then
    icon=":${capacity}"
    tooltip=$(get_charge_time)
elif [ "$status" = "Full" ]; then
    icon=":${full_icon}"
    tooltip="Зарядка окончена"
else
    icon=":${capacity}"
    tooltip=$(get_discharge_time)
fi
JSON=$(echo "{\"text\":\"${icon}\", \"tooltip\":\"${tooltip}\"}" | sed 's/&/\&amp;/g')

echo "${JSON}"
