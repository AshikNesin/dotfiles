# Set default editors
export EDITOR="vim"
export VISUAL="subl"

exists()
{
  command -v "$1" >/dev/null 2>&1
}

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
#	alias ls="exa -a"



# Homebrew

    if command -v 'brew' &> /dev/null; then
        alias brewd='brew doctor'
        alias brewi='install-app --brew'
        alias bi='brew install '

        alias brewr='brew uninstall'
        alias brews='brew search'
		alias cask="install-app --cask "
        alias brewu='brew update \
                      && brew upgrade --all \
                      && brew cleanup \
                      && brew cask cleanup'

    fi

# npm
    # if command -v 'npm' &> /dev/null; then
    # alias npm="pnpm"
		alias npmi="npm install"
		alias npmd="npm run dev"
		alias npmg="install-app --npm"
		alias npmid="npm install --save-dev"
		alias npmu="npm update"
		alias npmr="npm uninstall"
		alias npmrg="npm uninstall -g"
		alias nom="rm -rf node_modules && npm cache clear && npm i"
		alias npminit='npm init -y; npm pkg set type="module";'
	# fi
	alias nn="npm-name"
	alias ns="npm start"
	alias y="yarn add"

# if [[ $HOME == *"/Users/ashiknesin"* ]]; then
#   alias npm="pnpm"
# 	alias npx="npm_execpath=$(which pnpm) npx"
# fi

# Server Guick Starts

	alias bs="browser-sync start --server --files '**/*.html,**/*.css,**/*.js'"

# Network

	alias ip='dig +short myip.opendns.com @resolver1.opendns.com'
	alias lip='ipconfig getifaddr en0'



# Custom
	alias py='python'
	alias f='open -a Finder'
	alias .e="zed ~/dotfiles"
	alias dld="aria2c -x 10"
	# alias sshkey="cat ~/.ssh/id_rsa.pub | pbcopy && echo 'Public key copied to clipboard.'"
	alias reload=". ~/.zshrc"

# todo, enable trash only if it's available

if exists trash; then
  alias rm='trash'
# else
  # echo 'Your system does not have Bash'
fi

# Pretty print the path

	alias path='echo $PATH | tr -s ":" "\n"'


# Utility

	alias yt="yt-dlp"
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


# Lock
# alias lock='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'

# Sleep Now

# alias sleepnow='pmset displaysleepnow'

alias update='sudo softwareupdate --install --all \
                   && brew update \
                   && brew upgrade --all \
                   && brew cleanup \
                   && npm install -g npm \
                   && npm update -g'
# alias rn="react-native"
alias :q="exit"
alias dcu="docker-compose up"
# alias cat="bat"
alias nd="npm run dev"
if command -v 'htop' &> /dev/null; then
		alias top="htop"
	fi
alias node12='export PATH="$PATH:/usr/local/opt/node@12/bin"; node -v'

if command -v 'lla' &> /dev/null; then
		alias ls="lla"
fi
alias lsa='ls -A'
