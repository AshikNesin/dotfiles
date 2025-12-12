# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)

# Installs Casks
brew tap homebrew/cask


brew install 1password
brew install 1password-cli
brew install cursor
brew install discord
brew install google-chrome #Chrome
brew install homebrew/cask-versions/firefox-nightly # Firefox Nightly
brew install homebrew/cask-versions/google-chrome-canary # Chrome Canary
# brew install keycastr
# brew install lunar - display brightness
brew install raycast
brew install obsidian
brew install visual-studio-code


# Remove outdated versions from the cellar.
brew cleanup
