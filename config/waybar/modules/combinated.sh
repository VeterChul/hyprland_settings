TITLE=$(hyprctl activewindow -j | jq -r '.title')
CLASS=$(hyprctl activewindow -j | jq -r '.initialTitle')
if [[ "$TITLE" != "null" ]]; then
	if [[ "$CLASS" == "kitty"  ]]; then
		echo "$CLASS $TITLE"
	else
		echo "$TITLE"
	fi
else
	echo  
fi
