unalias gca >/dev/null 2>/dev/null #remove oh-my-zsh git plugin alias
alias gca="git_commit_all"
alias gcd="git clone --depth=1"
## Git commands

# Based on https://gist.github.com/codejets/519d3287229ed075a025
alias gaa='git add . && git commit --amend'
# alias gc="git commit -m"
alias gc="interactive-checkout"
alias gcm="git checkout master"
alias gcb="git checkout -b"
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias ga="git amend"
alias diff='git diff'
alias br='git br'
alias st='git status'
alias fetch='git fetch'
alias push='git push origin'
alias pull='git_pull_origin_branch'
alias pulls='git_pull_origin_submodules'
alias gpu="git pull upstream master"
alias pusht="git push --tags"
# Update Remote url
alias gru="git remote set-url"

# Undo a `git push`
alias undopush="git push -f origin HEAD^:master"
alias grmb="git push origin --delete"
# git root
alias gr='[ ! -z `git rev-parse --show-cdup` ] && cd `git rev-parse --show-cdup || pwd`'

alias ginit='git init && gi osx,node && gca "Init Commit"'
alias rollback="git reset --hard HEAD  && git clean -d -f -f"
alias gcd="git checkout develop"
alias brm="git branch -d"
alias gbr="git_create_new_branch"
alias pullbr="git_pull_origin_branch"
alias cloneb="git clone -b "
alias rb="rollback"
alias dff="git diff --name-only "
# alias pulls="git pull --recurse-submodules"
alias git_current_branch="git branch --show-current"
alias gclean="git branch | grep -v "master" | xargs git branch -d"
# https://twitter.com/wesbos/status/1217849767579062272
alias gresolve="git diff --name-only | uniq | xargs code" 
alias gm="git pull origin master"
