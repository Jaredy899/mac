#!/bin/bash

# Function to install dockutil if not installed
install_dockutil() {
    if ! command -v dockutil &> /dev/null; then
        echo "dockutil is not installed. Installing dockutil..."
        brew install dockutil
    else
        echo "dockutil is already installed."
    fi
}

# Function to remove a Dock icon
remove_dock_icon() {
    local app_name=$1
    echo "Removing $app_name from the Dock..."
    dockutil --remove "$app_name" --allhomes
}

# Ensure Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is required but not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

# Install dockutil if necessary
install_dockutil

# List of standard macOS applications typically found in the Dock
default_apps=("Mail" "Safari" "Contacts" "Calendar" "Notes" "Reminders" "Maps" "Photos" "Messages" "FaceTime" "Music" "Podcasts" "TV" "News")

# Ask user which icons to remove
for app in "${default_apps[@]}"; do
    read -p "Do you want to remove $app from the Dock? (y/n): " remove_app
    if [[ "$remove_app" == "y" || "$remove_app" == "Y" ]]; then
        remove_dock_icon "$app"
    else
        echo "Keeping $app in the Dock."
    fi
done

echo "Dock configuration completed."