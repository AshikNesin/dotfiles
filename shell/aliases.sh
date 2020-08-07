# Set default editors
export EDITOR="vim"
export VISUAL="subl"

# Navigation
	alias ..="cd .."
	alias ...="cd ../.."
	alias ~="cd ~"

# Shortcuts
	alias db="cd ~/Dropbox"
	alias dl="cd ~/Downloads"
	alias dt="cd ~/Desktop"
	alias co="cd ~/Code"
	alias dot="cd ~/dotfiles"


# Unix
	alias cls="clear"
	alias ll="ls -al"
	#alias ls="ls -a"
	alias ln="ln -v"
	alias rmd="rm -rf"
	alias e="$EDITOR"
	alias v="$VISUAL"



# Homebrew

    if command -v 'brew' &> /dev/null; then
        alias brewd='brew doctor'
        alias brewi='brew install'
        alias brewr='brew uninstall'
        alias brews='brew search'
		alias bci="brew cask install"
        alias brewu='brew update \
                      && brew upgrade --all \
                      && brew cleanup \
                      && brew cask cleanup'

    fi

# npm
    if command -v 'npm' &> /dev/null; then
		alias npmi="npm install"
		alias npmg="npm install -g"
		alias npmid="npm install --save-dev"
		alias npmu="npm update"
		alias npmr="npm uninstall"
		alias npmrg="npm uninstall -g"
		alias nom="rm -rf node_modules && npm cache clear && npm i"
	fi
	alias nn="npm-name"
	alias ns="npm start"
	alias y="yarn add"

# Rails

    if command -v 'rails' &> /dev/null; then
		alias b="bundle"
		alias rsb="rails s -b 0.0.0.0"
		alias rgm="rails generate model"
		alias rgc="rails generate controller"
		alias rgs="rails generate scaffold"
		alias rdm="rails destroy model"
		alias rdc="rails destroy controller"
		alias rds="rails destroy scaffold"
		alias rkdm="rake db:migrate"
	fi

# Server Guick Starts

	alias bs="browser-sync start --server --files '**/*.html,**/*.css,**/*.js'"
	alias live="live-server"
	alias pys="python -m SimpleHTTPServer 8000"
	alias phps="php -S localhost:8000"

# Network

	alias ip='dig +short myip.opendns.com @resolver1.opendns.com'
	alias lip='ipconfig getifaddr en0'



# Custom
	alias py='python'
	alias f='open -a Finder'
	alias .e="subl ~/dotfiles"
	alias dld="aria2c -x 10"
	alias gdl="gdrive download"
	alias sshkey="cat ~/.ssh/id_rsa.pub | pbcopy && echo 'Public key copied to clipboard.'"
	alias reload=". ~/.zshrc"
	alias rm='trash'

# Services
	alias stms='brew services start mysql'
	alias spms='brew services stop mysql'
	alias stmd='brew services start mongodb'
	alias spmd='brew services stop mongodb'

# Pretty print the path

	alias path='echo $PATH | tr -s ":" "\n"'


# Utility

	alias yt="youtube-dl"
	# alias ya="get-audio"
	alias clean-github="remove-github-forks $GITHUB_CLEAN_FORK"
# ----------------------------------------------------------------------
# | System                                                            |
# ----------------------------------------------------------------------


alias mute="osascript -e 'set volume output muted true' > /dev/null"
alias unmute="osascript -e 'set volume output muted false' > /dev/null"


# Recursively delete `.DS_Store` files
alias cleanup="find . -name '*.DS_Store' -type f -ls -delete"


# Empty the Trash on all mounted volumes and the main HDD
# Also, clear Apple’s System Logs to improve shell startup speed
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes; sudo rm -rfv ~/.Trash; sudo rm -rfv /private/var/log/asl/*.asl"

# Hide/show all desktop icons
alias dt-hide="defaults write com.apple.finder CreateDesktop -bool false && killall Finder"
alias dt-show="defaults write com.apple.finder CreateDesktop -bool true && killall Finder"


# Hide/Show hidden files in Finder
alias hide-hidden-files='defaults write com.apple.finder AppleShowAllFiles -bool false && killall Finder'
alias show-hidden-files='defaults write com.apple.finder AppleShowAllFiles -bool true && killall Finder'


# Lock
alias lock='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'

# Sleep Now

alias sleepnow='pmset displaysleepnow'

alias update='sudo softwareupdate --install --all \
                   && brew update \
                   && brew upgrade --all \
                   && brew cleanup \
                   && npm install -g npm \
                   && npm update -g'
alias ssh="sshrc"
alias rn="react-native"
