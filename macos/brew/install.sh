#!/bin/bash

$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)

# Make sure we’re using the latest Homebrew
brew update

# usefull stuff

usefull_pkg=(
	bash
	zsh
	coreutils
	wget
	unrar
	ffmpeg
	trash
	cmus
	mycli
	ruby
	go
	asciinema
	mysql
	mongodb
	bat
	prettyping
	noti

)

usefull_cask=(
	iterm2
	the-unarchiver
	diffmerge
	caffeine
	spectacle
	imageoptim
	teamviewer
	awareness
	cloudapp
	discord
	toggldesktop
	unetbootin
)

brew install ${usefull_pkg[@]}

brew cask install ${usefull_cask[@]}

# dev stuffs

brew install git imagemagick heroku-toolbelt node mysql dnsmasq

# if test ! "$(which rbenv)"; then
#   echo "  Installing rbenv for you."
#   brew install rbenv > /tmp/rbenv-install.log
# fi

# if test ! "$(which ruby-build)"; then
#   echo "  Installing ruby-build for you."
#   brew install ruby-build > /tmp/ruby-build-install.log
# fi

brew cask install sublime-text3 sequel-pro virtualbox gitx


# chat, books, notes, documents, mail, etc
brew cask install evernote skype slack limechat\
	 kindle dropbox flux rescuetime miro-video-converter tunnerbear

# browser
brew cask install torbrowser google-chrome-canary firefox


# watch and download stuff
brew install youtube-dl aria2
brew cask install vlc utorrent

# quick look plugins - https://github.com/sindresorhus/quick-look-plugins
brew cask install qlcolorcode qlstephen qlmarkdown quicklook-json qlprettypatch quicklook-csv betterzipql qlimagesize webpquicklook suspicious-package quicklookase qlvideo

# Utils
brew cask install appcleaner
# Install fonts.
brew tap caskroom/fonts
brew cask install font-hack font-source-code-pro

# Config
brew services start mysql
brew services start mongodb
# clean things up
brew cleanup
brew cask cleanup
