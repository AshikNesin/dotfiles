PATH=~/.console-ninja/.bin:$PATH
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
. "$HOME/.cargo/env"

[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
eval "$(atuin init bash)"

[ -s "$HOME/.deno/env" ] && . "/$HOME/.deno/env"
