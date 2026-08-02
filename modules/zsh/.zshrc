# https://scottspence.com/posts/speeding-up-my-zsh-shell
# To profile startup: add  `zmodload zsh/zprof`  at the top and  `zprof`  at the bottom.

DISABLE_AUTO_UPDATE="true"
DISABLE_MAGIC_FUNCTIONS="true"
DISABLE_COMPFIX="true"

export PGHOST=localhost

# Path to your oh-my-zsh installation.
export ZSH=~/.oh-my-zsh
ZSH_THEME="robbyrussell"
plugins=()

# --- Base PATH (standard locations present on both macOS and Linux) ---
export PATH="/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/usr/games:/usr/local/games:$PATH"

source $ZSH/oh-my-zsh.sh

# --- Dotfiles bin + Go workspace ---
export PATH="$HOME/dotfiles/bin:$PATH"
export GOPATH=$HOME/go
export PATH="$PATH:${GOPATH}/bin"

# RVM (if present)
export PATH="$PATH:$HOME/.rvm/bin"

# --- Sources ---
source ~/dotfiles/modules/zsh/aliases.sh
source ~/dotfiles/modules/zsh/function.sh
source ~/dotfiles/utils/z/z.sh
source ~/dotfiles/modules/git/git-functions.sh
source ~/dotfiles/modules/git/git-aliases.sh

[ -f "$HOME/dotfiles/.profile" ] && source "$HOME/dotfiles/.profile"
[ -f "$HOME/dotfiles/modules/zsh/local/.env" ] && source "$HOME/dotfiles/modules/zsh/local/.env"
[ -f "$HOME/dotfiles/local/.alias" ] && source "$HOME/dotfiles/local/.alias"

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# --- macOS-only config (Homebrew, /Library, etc.) -----------------------
# Gated so Linux shells never reference brew/ or Homebrew paths that don't
# exist there (avoids "command not found: brew" and PATH pollution).
if [[ "$OSTYPE" == darwin* ]]; then
    # Homebrew coreutils (gnubin / gnuman)
    export PATH="/usr/local/opt/coreutils/libexec/gnubin:$PATH"
    export MANPATH="/usr/local/opt/coreutils/libexec/gnuman:$MANPATH"

    # Homebrew keg-only bins (Intel Mac: /usr/local/opt/...)
    export PATH="/usr/local/mysql/bin:$PATH"
    export PATH="$PATH:/usr/local/opt/go/libexec/bin"
    export PATH="/usr/local/opt/python/libexec/bin:$PATH"
    export PATH="/usr/local/opt/icu4c/bin:$PATH"
    export PATH="/usr/local/opt/icu4c/sbin:$PATH"
    export PATH="/usr/local/opt/node@8/bin:$PATH"
    export PATH="/usr/local/opt/mysql@5.6/bin:$PATH"
    export PATH="/usr/local/opt/node@12/bin:$PATH"
    export PATH="/usr/local/opt/node@14/bin:$PATH"
    export PATH="/usr/local/opt/ncurses/bin:$PATH"
    [[ -r "/usr/local/opt/git-extras/share/git-extras/git-extras-completion.zsh" ]] && \
        source /usr/local/opt/git-extras/share/git-extras/git-extras-completion.zsh
    [[ -r "/usr/local/etc/profile.d/bash_completion.sh" ]] && \
        . "/usr/local/etc/profile.d/bash_completion.sh"

    # Homebrew keg-only bins (Apple Silicon: /opt/homebrew/opt/...)
    export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
    export PATH="/opt/homebrew/lib/ruby/gems/2.6.0/bin:$PATH"
    export PATH="/opt/homebrew/opt/ruby@2.6/bin:$PATH"
    export PATH="/opt/homebrew/opt/mongodb-community@4.4/bin:$PATH"
    export PATH="/opt/homebrew/opt/postgresql@15/bin:$PATH"
    export PATH="/opt/homebrew/opt/mysql@8.0/bin:$PATH"
    export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
    export PATH="/opt/homebrew/opt/openjdk/bin:$PATH"
    export CPPFLAGS="-I/opt/homebrew/opt/openjdk/include"

    # GOROOT via Homebrew
    if command -v brew >/dev/null 2>&1; then
        export GOROOT="$(brew --prefix golang)/libexec"
        export PATH="$PATH:${GOROOT}/bin"
    fi

    # tabtab completions (serverless)
    [[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh ]] && \
        . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/serverless.zsh
    [[ -f /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh ]] && \
        . /usr/local/lib/node_modules/serverless/node_modules/tabtab/.completions/sls.zsh

    # Android SDK
    export ANDROID_SDK_ROOT=$HOME/Library/Android/sdk

    # Java (Corretto 8)
    export JAVA_HOME=/Library/Java/JavaVirtualMachines/amazon-corretto-8.jdk/Contents/Home
    export PATH="$JAVA_HOME/bin:$PATH"

    # Antigravity (mac app)
    export PATH="$HOME/.antigravity/antigravity/bin:$PATH"

    [ -d ~/Apps ] && export HOMEBREW_CASK_OPTS="--appdir=~/Apps"
fi

# --- Cross-platform tools (each self-guards) ---------------------------

# pyenv
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv >/dev/null 2>&1; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi

# 1Password CLI
if command -v op >/dev/null 2>&1; then
    eval "$(op completion zsh)"; compdef _op op
fi

# Pure prompt — https://github.com/sindresorhus/pure
fpath+=($HOME/dotfiles/utils/pure)
autoload -U promptinit; promptinit
prompt pure

# Volta (Node.js version manager)
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
[ -f "$HOME/.fig/shell/zshrc.post.zsh" ] && source "$HOME/.fig/shell/zshrc.post.zsh"

# SDKMAN
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"
[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"

# deno
[ -s "$HOME/.deno/env" ] && . "$HOME/.deno/env"

# cargo (rust)
[ -s "$HOME/.cargo/env" ] && source "$HOME/.cargo/env"

# pnpm (install location differs by OS)
if [[ "$OSTYPE" == darwin* ]]; then
    export PNPM_HOME="$HOME/Library/pnpm"
else
    export PNPM_HOME="$HOME/.local/share/pnpm"
fi
case ":$PATH:" in
    *":$PNPM_HOME:"*) ;;
    *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# user-local bin
export PATH="$HOME/.local/bin:$PATH"
[ -s "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# misc
PATH="$HOME/.console-ninja/.bin:$PATH"
export PATH="$PATH:$HOME/.bin"
export ANT_OPTS="-Xmx6144m"

# sentry completions
fpath=("$HOME/.local/share/zsh/site-functions" $fpath)

# Safe-chain
[[ -f ~/.safe-chain/scripts/init-posix.sh ]] && source ~/.safe-chain/scripts/init-posix.sh

# --- Completion (refresh once per day, cross-platform) ------------------
# Uses a zsh glob qualifier instead of `stat` (whose flags differ between
# macOS `-f` and Linux `-c`): rebuild the dump if it's missing or >24h old.
autoload -Uz compinit
if [[ ! -e ~/.zcompdump ]] || [[ -n ~/.zcompdump(#qN.mh+24) ]]; then
    compinit
else
    compinit -C
fi

# zprof   # uncomment to profile shell startup
