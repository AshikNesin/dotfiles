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
brew install arc
brew install hyperkey

brew install cleanshot
brew install warp
brew install imageoptim
brew install --cask tailscale
brew install tableplus
brew install iina
brew install tabula

brew install the-unarchiver
brew install numi
brew install simplenote
brew install postman
brew install sublime-merge
brew install diffmerge
# brew install qlcolorcode
brew install qlmarkdown
brew install telegram
brew install android-studio
brew install logitech-options
brew install appcleaner
brew install logseq
brew install antinote
brew install hazeover
brew install lulu
brew install --cask ollama
# Remove outdated versions from the cellar.
brew cleanup
brew install --cask docker
brew install --cask antigravity
brew install --cask steipete/tap/codexbar
brew install tw93/tap/mole
