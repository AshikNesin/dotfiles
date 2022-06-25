#!/usr/bin/env bash


# https://github.com/sindresorhus/quick-look-plugins#catalina-notes
xattr -r ~/Library/QuickLook

xattr -d -r com.apple.quarantine ~/Library/QuickLook

# brew services start mysql

# brew services start mongodb-community

# For VSCode VIM
defaults write com.microsoft.VSCode ApplePressAndHoldEnabled -bool false
