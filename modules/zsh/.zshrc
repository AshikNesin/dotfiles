# Fig pre block. Keep at the top of this file.

if [ -f "$HOME/.fig/shell/zshrc.pre.zsh" ]
then
fi

#export HOMEBREW_CASK_OPTS="--appdir=/Applications"
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
source ~/dotfiles/modules/zsh/aliases.sh
# git

source ~/dotfiles/modules/git/git-functions.sh
source ~/dotfiles/modules/git/git-aliases.sh

source ~/dotfiles/modules/zsh/function.sh

# utils

source ~/dotfiles/utils/z/z.sh

# others
if [ -f "$HOME/dotfiles/.profile" ]
then
source ~/.profile
fi


if [ -f "$HOME/dotfiles/modules/zsh/local/.env" ]
then
    source ~/dotfiles/modules/zsh/local/.env
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
# export JAVA_HOME=/Library/Java/JavaVirtualMachines/amazon-corretto-8.jdk/Contents/Home
export JAVA_HOME=/Library/Java/JavaVirtualMachines/amazon-corretto-17.jdk/Contents/Home

# export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_144.jdk/Contents/Home
# export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_271.jdk/Contents/Home
# export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk1.8.0_202.jdk/Contents/Home


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
export PATH="$PATH:${GOPATH}/bin:${GOROOT}/bin"

# Python 3
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --path)"
  eval "$(pyenv init -)"
fi


if command -v op 1>/dev/null 2>&1; then
eval "$(op completion zsh)"; compdef _op op
fi
# https://github.com/sindresorhus/pure
fpath+=($HOME/dotfiles/utils/pure)
autoload -U promptinit; promptinit
prompt pure

export N_PREFIX=$HOME/.n
export PATH=$N_PREFIX/bin:$PATH

# Fig post block. Keep at the bottom of this file.

if [ -f "$HOME/.fig/shell/zshrc.post.zsh" ]
then
fi

# #THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export PATH="$PATH:/Users/ashiknesin/.bin"

export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="/opt/homebrew/lib/ruby/gems/2.6.0/bin:$PATH"

export PATH="/opt/homebrew/opt/ruby@2.6/bin:$PATH"
export PATH="/opt/homebrew/opt/mongodb-community@4.4/bin:$PATH"
export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
# source "$HOME/.sdkman/bin/sdkman-init.sh"
# bun completions
[ -s "/Users/ashiknesin/.bun/_bun" ] && source "/Users/ashiknesin/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"


# eval "$(atuin init zsh)"

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

[ -s "$HOME/.bun/_bun" ] && source "/$HOME/.bun/_bun"

[ -s "$HOME/.deno/env" ] && . "/$HOME/.deno/env"

export PATH="/opt/homebrew/opt/mysql@8.0/bin:$PATH"

export ANT_OPTS="-Xmx6144m"

[ -s "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
# export JAVA_HOME=${SDKMAN_CANDIDATES_DIR}/java/${CURRENT}

[ -s "$HOME/.cargo/env" ] && source "/$HOME/.cargo/env"
export PATH="/opt/homebrew/opt/libpq/bin:$PATH"


[ -d ~/Apps ] && export HOMEBREW_CASK_OPTS="--appdir=~/Apps"
export PATH="$HOME/.local/bin:$PATH"

PATH=~/.console-ninja/.bin:$PATH
