source ~/dotfiles/.secrets
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export PGHOST=localhost

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

ZSH_THEME="robbyrussell"


# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git-flow)

# User configuration

export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:/usr/local/opt/coreutils/libexec/gnubin:$PATH"
export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"
source $ZSH/oh-my-zsh.sh

export PATH="$PATH:$HOME/.rvm/bin" # Add RVM to PATH for scripting
# [[ -s $HOME/.nvm/nvm.sh ]] && . $HOME/.nvm/nvm.sh  # This loads NVM

export PATH="/usr/local/mysql/bin:$PATH"

export PATH=$PATH:/usr/local/opt/go/libexec/bin
export PATH=$HOME/dotfiles/bin:$PATH
export GOPATH=~/go



# shell
source ~/dotfiles/shell/aliases.sh
source ~/dotfiles/shell/functions.sh
# git

source ~/dotfiles/git/functions.sh
source ~/dotfiles/git/aliases.sh

# utils

source ~/dotfiles/utils/z/z.sh

# others
source ~/.profile

### Pure
autoload -U promptinit; promptinit
prompt pure

if [ -f "~/dotfiles/local/.env" ]
then
    source ~/dotfiles/local/.env
fi
