# A better git clone
# clones a repository, cds into it, and opens it in my editor.
#
# Based on https://github.com/stephenplusplus/dots/blob/master/.bash_profile#L68 by @stephenplusplus
#
# Note: subl is already setup as a shortcut to Sublime. Replace with your own editor if different
#
# - arg 1 - url|username|repo remote endpoint, username on github, or name of
#           repository.
# - arg 2 - (optional) name of repo
#
# usage:
#   $ clone things
#     .. git clone git@github.com:addyosmani/things.git things
#     .. cd things
#     .. subl .
#
#   $ clone yeoman generator
#     .. git clone git@github.com:yeoman/generator.git generator
#     .. cd generator
#     .. subl .
#
#   $ clone git@github.com:addyosmani/dotfiles.git
#     .. git clone git@github.com:addyosmani/dotfiles.git dotfiles
#     .. cd dots
#     .. subl .

function clone {
  # customize username to your own
  local username="ashiknesin"

  local url=$1;
  local repo=$2;

  if [[ ${url:0:4} == 'http' || ${url:0:3} == 'git' ]]
  then
    # just clone this thing.
    repo=$(echo $url | awk -F/ '{print $NF}' | sed -e 's/.git$//');
  elif [[ -z $repo ]]
  then
    # my own stuff.
    repo=$url;
    url="git@github.com:$username/$repo";
  else
    # not my own, but I know whose it is.
    url="git@github.com:$url/$repo.git";
  fi

  git clone $url $repo && cd $repo;
}


function git_commit_all() {
 git add .
 git commit -a -m "$1"

}

function g() {
        if [ $# -eq 0 ]; then
                git status
        else

                git "$@"
        fi
}

gi() {
  curl -s "https://www.toptal.com/developers/gitignore/api/$*" > .gitignore
}


function git_create_new_branch() {
 git checkout -b "$1" develop
}

function git_pull_origin_branch() {
  if [[ -z "$1" ]]; then
    current_branch=`git branch --show-current`
  else
      current_branch="$1"
  fi
  echo "\n⏳ Pulling latest changes from $current_branch (origin)\n"
  
  git pull origin "$current_branch"

}

function git_pull_origin_submodules() {
  # git fetch <remote> <rbranch>:<lbranch> 
  # git pull origin "$1" --recurse-submodules
    git_pull_origin_branch  --recurse-submodules
}

#.# Better Git Logs.
### Using EMOJI-LOG (https://github.com/ahmadawais/Emoji-Log).

# Git Commit, Add all, and Push — in one step.
# function gcap() {
# 	git add . && git commit -m "$*" && git push
# }

# NEW.
function gnew() {
	git_commit_all "📦 NEW: $@"
}

# IMPROVE.
function gimp() {
	git_commit_all "👌 IMPROVE: $@"
}

# FIX.
function gfix() {
	git_commit_all "🐛 FIX: $@"
}

# RELEASE.
function grlz() {
	git_commit_all "🚀 RELEASE: $@"
}

# DOC.
function gdoc() {
	git_commit_all "📖 DOC: $@"
}

# TEST.
function gtst() {
	git_commit_all "✅ TEST: $@"
}

# Delete git branch in local & remote (https://github.com/gokulkrishh/dotfiles/blob/master/oh-my-zsh/aliases)
function gdb {
  # Branch name present?
  if [[ -z "$1" ]]; then
    echo "\n🤔 Oops… you forgot to provide the branch name"
    echo "👉 E.g. gdb branch_name\n"
  else
    echo "\n⏳ Deleting…\n"
    git branch -D "$1" # Local delete.
    # git push origin --delete "$1" # Remote delete.
    echo "\n✅ Git branch $1 was deleted from local\n"
  fi
}