# Fig pre block. Keep at the top of this file.
. "$HOME/.fig/shell/zshrc.pre.zsh"
export HOMEBREW_CASK_OPTS="--appdir=/Applications"
export PGHOST=localhost

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh

ZSH_THEME="robbyrussell"



# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=()

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
# git

source ~/dotfiles/git/git-functions.sh
source ~/dotfiles/git/git-aliases.sh

source ~/dotfiles/shell/function.sh

# utils

source ~/dotfiles/utils/z/z.sh

# others
if [ -f "$HOME/dotfiles/.profile" ]
then
source ~/.profile
fi


if [ -f "$HOME/dotfiles/local/.env" ]
then
    source ~/dotfiles/local/.env
fi

if [ -f "$HOME/dotfiles/local/.alias" ]
then
    source ~/dotfiles/local/.alias
fi

# eval $(thefuck --alias)

# tabtab source for serverless package
# uninstall by removing these lines or running `tabtab uninstall serverless`
[[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh ]] && . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh
# tabtab source for sls package
# uninstall by removing these lines or running `tabtab uninstall sls`
[[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh ]] && . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh

export PATH="/usr/local/opt/python/libexec/bin:$PATH"
export PATH="/usr/local/opt/icu4c/bin:$PATH"
export PATH="/usr/local/opt/icu4c/sbin:$PATH"
export PATH="/usr/local/opt/node@8/bin:$PATH"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# export JAVA_HOME=$(/usr/libexec/java_home)
# export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_25.jdk/Contents/Home
# export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_144.jdk/Contents/Home
# export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_271.jdk/Contents/Home
export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home


# export PATH=$PATH:/usr/local/mysql/bin
export PATH="/usr/local/opt/mysql@5.6/bin:$PATH"

export PATH="/usr/local/opt/node@12/bin:$PATH"

[[ -r "/usr/local/opt/git-extras/share/git-extras/git-extras-completion.zsh" ]] && source /usr/local/opt/git-extras/share/git-extras/git-extras-completion.zsh
export PATH="/usr/local/opt/ncurses/bin:$PATH"

[[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && . "/usr/local/etc/profile.d/bash_completion.sh"

export PATH="/usr/local/opt/node@14/bin:$PATH"
export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk

export GOPATH=$HOME/go
export GOROOT="$(brew --prefix golang)/libexec"
export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"export PATH="/opt/homebrew/opt/node@14/bin:$PATH"

# Python 3
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi

eval "$(op completion zsh)"; compdef _op op

# https://github.com/sindresorhus/pure
fpath+=($HOME/dotfiles/utils/pure)
autoload -U promptinit; promptinit
prompt pure

# Fig post block. Keep at the bottom of this file.
. "$HOME/.fig/shell/zshrc.post.zsh"
