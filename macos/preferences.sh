#!/usr/bin/env bash

# https://www.robinwieruch.de/mac-setup-web-development/

# take screenshots as jpg (usually smaller size) and not png
defaults write com.apple.screencapture type jpg

# Save screenshots to the desktop
defaults write com.apple.screencapture location -string "$HOME/Documents/Pictures/Screenshots/MacOS"

# do not open previous previewed files (e.g. PDFs) when opening a new one
defaults write com.apple.Preview ApplePersistenceIgnoreState YES

# show Library folder
chflags nohidden ~/Library

# show hidden files
defaults write com.apple.finder AppleShowAllFiles YES

# show path bar
defaults write com.apple.finder ShowPathbar -bool true


# show status bar
defaults write com.apple.finder ShowStatusBar -bool true

# ================================================================
# Hide Desktop Icons Completely
defaults write com.apple.finder CreateDesktop -bool false

# Dock
defaults write com.apple.dock persistent-apps -array

killall Finder;
killall Dock;
