#~/bin/bash

rm ~/.zshrc
rm -rf ~/.oh-my-zsh/custom

mkdir ~/.myconfig
mkdir ~/.myconfig/zsh

cp -r zsh/. ~/.myconfig/zsh/

ln -s ~/.myconfig/zsh/.zshrc ~/.zshrc
ln -s ~/.myconfig/zsh/.oh-my-zsh/themes/purple.zsh-theme ~/.oh-my-zsh/themes/purple.zsh-theme 
ln -s ~/.myconfig/zsh/.oh-my-zsh/custom ~/.oh-my-zsh/custom 