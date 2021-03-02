#!/bin/bash

    
# ssh-keygen -t rsa -b 4096 -C "mail@ashiknesin.com"
touch ~/.hushlogin # https://ashokgelal.com/2017/01/04/til-iterm-hush-last-login/

chmod -R +x ~/dotfiles/bin


# Symlink

# Set up symlinks
if [ -f "$HOME/.bashrc" ]
then
  mv ~/.bashrc ~/.bashrc.old
fi
ln -s ~/dotfiles/.bashrc ~/.bashrc

if [ -f "$HOME/.zshrc" ]
then
  mv ~/.zshrc ~/.zshrc.old
fi

ln -s ~/dotfiles/.zshrc ~/.zshrc


ln -sf ~/dotfiles/git/.gitconfig ~/.gitconfig
ln -sf ~/dotfiles/git/.gitignore ~/.gitignore

ln -sf ~/dotfiles/local/.aws ~/.aws

cp -r ~/dotfiles/local/fonts/.  ~/Library/Fonts

ln -sf ~/dotfiles/local/.gauth ~/.gauth
ln -sf ~/dotfiles/local/.git-credentials ~/.git-credentials