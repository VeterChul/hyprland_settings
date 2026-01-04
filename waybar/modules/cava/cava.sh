bar="▁▂▃▄▅▆▇█"
dict="s/;//g;"

i=0
while [ $i -lt ${#bar} ]
do
    dict="${dict}s/$i/${bar:$i:1}/g;"
    i=$((i=i+1))
done

cfg="/home/veter/.config/waybar/modules/cava/cava.config"
cava -p $cfg | while read -r line; do
	if [ "$(echo $line | sed $dict)" = "▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁▁" ]; then
    	cat ~/.config/waybar/modules/weather/weather.txt
	else
		text_value=$(jq -r '.text' ~/.config/waybar/modules/weather/weather.txt)
		time_value=$(jq -r '.tooltip' ~/.config/waybar/modules/weather/weather.txt)
		val=$(echo $text_value $time_value)
		formatted_text=$(echo "$line" | sed $dict)

		JSON=$(echo "{\"text\":\"${formatted_text} \", \"tooltip\":\"${val}\"}" | sed 's/&/\&amp;/g')

        echo "${JSON}"
		
	fi
done
