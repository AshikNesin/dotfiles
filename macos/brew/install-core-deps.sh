# Make sure we’re using the latest Homebrew.
brew update

# Upgrade any already-installed formulae.
brew upgrade

# Save Homebrew’s installed location.
BREW_PREFIX=$(brew --prefix)


brew install 1password
brew install 1password-cli
# brew install cursor
brew install discord
brew install google-chrome #Chrome
brew install firefox-nightly # Firefox Nightly
# brew install google-chrome-canary # Chrome Canary
# brew install keycastr
# brew install lunar - display brightness
brew install raycast
brew install obsidian
brew install visual-studio-code


# Remove outdated versions from the cellar.
brew cleanup
