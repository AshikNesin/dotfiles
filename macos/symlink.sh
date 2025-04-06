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


mkdir -p ~/.ssh
mkdir -p ~/.docker
ln -fs  ~/dotfiles/local/.docker/daemon.json ~/.docker/daemon.json
ln -fs  ~/dotfiles/local/.docker/config.json ~/.docker/config.json

# ln -fs  ~/dotfiles/local/ntfy/client.yml /etc/ntfy/client.yml

# https://docs.ntfy.sh/subscribe/cli/
mkdir -p  ~/Library/Application\ Support/ntfy
ln -fs  ~/dotfiles/local/ntfy/client.yml ~/Library/Application\ Support/ntfy/client.yml