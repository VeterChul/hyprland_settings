#~/bin/bash

rm ~/.zshrc
rm -rf ~/.oh-my-zsh/custom

ln -s zsh/.zshrc ~/.zshrc
ln -s .oh-my-zsh/themes/purple.zsh-theme ~/.oh-my-zsh/themes/purple.zsh-theme 
ln -s .oh-my-zsh/custom ~/.oh-my-zsh/custom 