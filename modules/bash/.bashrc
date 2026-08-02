
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"
# Rust/Cargo environment
[ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

[[ -f ~/.bash-preexec.sh ]] && source ~/.bash-preexec.sh
command -v atuin >/dev/null 2>&1 && eval "$(atuin init bash)"

[ -f "$HOME/.deno/env" ] && . "$HOME/.deno/env"

[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

PATH="$HOME/.console-ninja/.bin:$PATH"
[ -f "$HOME/.safe-chain/scripts/init-posix.sh" ] && source "$HOME/.safe-chain/scripts/init-posix.sh" # Safe-chain bash initialization script
# exebox shell completion
[ -f /home/exedev/.local/share/exebox/completion.bash ] && source /home/exedev/.local/share/exebox/completion.bash
export PNPM_HOME="$HOME/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
export PATH="$HOME/.local/share/pnpm/bin:$PATH"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
