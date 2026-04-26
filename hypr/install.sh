#~/bin/bash

sudo chmod 750 -R hypr/

sudo pacman -S --needed $(cat hypr/pac_inst.txt)

yay -S --needed $(cat hypr/aur_inst.txt)

./hypr/create_symlinks.sh