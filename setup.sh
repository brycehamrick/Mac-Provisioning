#!/usr/bin/env bash

read -p "ℹ️  Grant Terminal Full Disk Access in System Preferences > Security & Privacy > Privacy..."

if [[ $(uname -m) == 'arm64' ]]; then
  PREFIX=/opt/homebrew
else
  PREFIX=/usr/local
fi
PATH=$PREFIX/bin:$PATH
BIN_PATH=$PREFIX/bin
OPT_PATH=$PREFIX/opt

# SSH key
ssh-keygen -t ed25519
echo "ℹ️  Please add this public key to GitHub: https://github.com/account/ssh"
cat ~/.ssh/id_rsa.pub
echo

# Xcode
xcode-select --install

# Homebrew
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi

# Log in to the App Store
open -a "App Store"
read -p "ℹ️  Log in to the App Store and press any key..."

# Customise Dock
dockutil --no-restart --remove all
dockutil --no-restart --add "/Applications/Google Chrome.app"
dockutil --no-restart --add "/Applications/Messenger.app"
dockutil --no-restart --add "/Applications/Slack.app"
dockutil --no-restart --add "/Applications/Notes.app"
dockutil --no-restart --add "/Applications/Reminders.app"
killall Dock

# Defaults
./defaults.sh

echo -e "\033[1mFinal Steps\033[0m"

cat << EOF
macOS
- Log in to iCloud

Chrome
- Sign in
EOF
