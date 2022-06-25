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


cp -r ~/dotfiles/local/fonts/.  ~/Library/Fonts

# it's doing infinite loop
# ln -sf ~/dotfiles/local/.aws ~/.aws
# ln -sf ~/dotfiles/local/.ssh ~/.ssh

sh -c '~/dotfiles/local/.ssh/fix-permission.sh'
