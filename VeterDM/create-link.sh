#!/bin/bash

#sudo rm -rf 

sudo rm -rf /var/lib/crt-greeter
sudo ln -s ~/.myconfig/VeterDM/share/crt-greeter /var/lib/
sudo chown -R greeter:greeter /var/lib/crt-greeter

sudo rm -rf /usr/local/bin/cool-retro-term-castom
sudo ln -s ~/.myconfig/VeterDM/bin/cool-retro-term-castom /usr/local/bin/ 
sudo chown -R root:root /usr/local/bin/cool-retro-term-castom

