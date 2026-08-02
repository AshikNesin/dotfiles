# pre-commit is installed via uv in shared/setup.sh (`uv tool install`),
# so it's consistent across macOS and Ubuntu — no brew formula needed here.
# Node.js and npm are installed per-user by shared/setup.sh via Volta.
# Keeping them out of Homebrew avoids system-wide npm global installs.
brew install uv
# https://docs.astral.sh/uv/guides/install-python/#viewing-python-installations
uv python install --default

brew install git-extras pure trash wget fzf zsh git bat jq diff-so-fancy awscli htop hyperfine qpdf aria2
brew install mas
brew install ffmpeg
brew install caddy
brew install difftastic
brew install gh
brew install mcfly
brew install ripgrep
brew install ntfy
brew install go
brew install gnupg
brew install dopplerhq/cli/doppler
brew install droid
brew install claude-code
