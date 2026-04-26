#!/bin/bash

sudo ln -s /opt/VeterDM ~/.myconfig/

sudo unlink /etc/greetd/config.toml
sudo ln -s /opt/VeterDM/share/greetd/config.toml /etc/greetd/ 
#sudo chown -R greeter:greeter /usr/local/bin/cool-retro-term-castom


sudo unlink /var/lib/crt-greeter
sudo ln -s /opt/VeterDM/share/crt-greeter /var/lib/
sudo chown -R greeter:greeter /var/lib/crt-greeter

sudo unlink /usr/local/bin/cool-retro-term-castom
sudo ln -s /opt/VeterDM/bin/cool-retro-term-castom /usr/local/bin/ 
sudo chown -R greeter:greeter /usr/local/bin/cool-retro-term-castom

sudo unlink /usr/local/bin/start-greeter.sh
sudo ln -s /opt/VeterDM/bin/start-greeter.sh /usr/local/bin/ 
sudo chown -R greeter:greeter /usr/local/bin/start-greeter.sh
sudo chmod 755 /usr/local/bin/start-greeter.sh


sudo unlink /usr/local/bin/crt-greeter.py
sudo ln -s /opt/VeterDM/bin/crt-greeter.py /usr/local/bin/ 
sudo chown -R greeter:greeter /usr/local/bin/crt-greeter.py

sudo unlink /usr/local/bin/crt-wrapper.sh
sudo ln -s /opt/VeterDM/bin/crt-wrapper.sh /usr/local/bin/ 
sudo chown -R greeter:greeter /usr/local/bin/crt-wrapper.sh

