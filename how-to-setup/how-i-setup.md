brew tap homebrew/cask-drivers
brew install logitech-options

# name collusion if we don't use --cask flag

brew install --cask flux 

# raycast's window management is not good enough atm.
brew install --cask rectangle


brew install --cask docker

brew install --cask dropbox

### 1Password
- Login to the account
- General:
	- Uncheck Keep 1Password in the menu bar
	- Set Show Quick Access shortcut to `Cmd + Options + \`
- Developer:
	- Select "Biometric unlock for 1Password CLI" (This takes care of signing in in CLI)
	- Select "Use the SSH agent"



## Install DMG manually

```bash
ask_for_sudo
install-dmg "file://$HOME/dotfiles/local/app-installers/Paste.dmg"
install-dmg https://download.cron.com/mac/dmg/arm64
```
## SDK

curl -s "https://get.sdkman.io" | bash

source "$HOME/.sdkman/bin/sdkman-init.sh"

sdk install java 8.0.352-amzn

sdk install java 11.0.17-amzn

## Manual Configuration

### Battery
- Enable: Dock & Menu Bar -> Battery -> Show Percentage

### Spotlight
#### System Preferences -> Spotlight
- Search Results: Disable everything
- Privacy: Select root directory or /Volumes

#### System Preferences -> Dock & Menu Bar -> Spotlight
- Uncheck "Show in Menu Bar"

### Hyperkey
- Startup


### CleanShot X
- Activate license (refer 1Password for key)
- General:
	- Enable "Start at login"
	- Disable "Play sounds"
	- Change export location to `~/Documents/Screenshots/CleanShot`
- Wallpaper:
	- Select "Plan color"
	- Window screenshot as "Transparent"
- Shortcuts:
	- Open Capture History: Caps lock + H
	- Restore Last Capture: Caps lock + L
	- Capture Area: Caps lock + C
	- Record Screen / Stop Recording: Caps lock + V
	- Scrolling Capture: Caps lock + Down key
	- Capture Text With Line Breaks: Caps lock + T
- Cloud: Login to the cloud

### Bartender 4
- Give Permissions:
	- Accessibility
	- Screen Recording
- General:
	- Check "Startup: Launch Bartender at login"
	- Uncheck "Use Bartender Bar to show hidden items"
- Hot keys:
	- Quick Search menu bar items: Caps lock + M



### Raycast
- General:
	- Enable "Launch Raycast at Login"
	- Raycast Hotkey: Cmd + Space
	- Disable "Show Raycast in menu bar"
- Account:
	- Signin via Github and link it with the app
- Extensions:
	-  Window Management
		- Maximize: Cmd + Options + F

### Brave
- Make it as default browser
- Enable rewards :)
- Enable Sync brave://settings/braveSync (get the code from 1Password) and set it to "Sync everything"


### iTerm2
- General -> Preferences:
	- Enable "Load preferences from a custom folder or URL"
	- Configure it to `~/dotfiles/config/iterm2` and select "Don't copy" for local preferences
	- Save changes: When Quitting

### AppCleaner
	- Enable **Smart Delete**

### Dato
	- Enable "Launch Data at startup?"
	- Select "Date & Time"
	- System Preferences › Language & Region -> Advanced -> First day of week to "Monday"

### Bandwidth+
- Enable Automatically start at login
- And select "Speed (bytes/second)" option

### Pandan
- Enable Launch at login for apps

### SnippetLabs
- Sync: Enable iCloud Sync

### Paste App
- Activate the license
- Enable Launch on startup
- Uncheck "Enable Direct Paste"
- Uncheck "Enable sound effects"
- Uncheck "Show Paste icon in the menu bar"

### Pure Paste
- Check "Automatically clear formatting"
- Check "Launch at login"
- Check "Hide menu bar icon"

### VS Code
- Enable "Settings Sync" and sign in via GitHub

### Others
- Trip Mode 3: Activate the license
- Simple Notes: Login
- F.lux: Check Start f.lux at login
- Rectangle: Import config from dotfiles

https://apps.apple.com/in/app/xcode/id497799835?mt=12 