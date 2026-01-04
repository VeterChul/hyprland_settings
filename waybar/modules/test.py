from os import system


cfg="/home/veter/.config/waybar/modules/cava/cava.config"

print(system(f"cava -p {cfg}"))