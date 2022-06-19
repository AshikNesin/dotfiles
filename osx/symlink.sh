#!/bin/bash


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
ln -sf ~/dotfiles/git/.gitignore_global ~/.gitignore

ln -sf ~/dotfiles/local/.aws ~/.aws

cp -r ~/dotfiles/local/fonts/.  ~/Library/Fonts

ln -sf ~/dotfiles/local/.ssh ~/.ssh
