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

# Ensure Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is required but not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

# Install dockutil if necessary
install_dockutil

# Check which applications are currently in the Dock
echo "Checking current Dock applications..."
IFS=$'\n' read -rd '' -a current_dock_apps < <(dockutil --list | awk -F"\t" '{print $1}' && printf '\0')

# Array to store apps to be removed from the Dock
apps_to_remove=()

# Ask user if they want to remove current Dock apps
if [ ${#current_dock_apps[@]} -gt 0 ]; then
    echo "Found the following applications in the Dock:"
    for app in "${current_dock_apps[@]}"; do
        read -p "Do you want to remove \"$app\" from the Dock? (y/n): " remove_app
        if [[ "$remove_app" == "y" || "$remove_app" == "Y" ]]; then
            apps_to_remove+=("$app")
        else
            echo "Keeping \"$app\" in the Dock."
        fi
    done
else
    echo "No applications found in the Dock."
fi

# Remove selected apps from the Dock
if [ ${#apps_to_remove[@]} -gt 0 ]; then
    echo "Removing selected apps from the Dock..."
    for app in "${apps_to_remove[@]}"; do
        dockutil --remove "$app" --allhomes
        if [ $? -eq 0 ]; then
            echo "\"$app\" successfully removed from the Dock."
        else
            echo "Failed to remove \"$app\" from the Dock. Please check for errors."
        fi
    done
else
    echo "No apps selected for removal. Dock remains unchanged."
fi

# Reset the Dock to apply changes
echo "Resetting the Dock..."
killall Dock

echo "###################################"
echo "##                               ##" 
echo "## Dock configuration completed. ##"
echo "##                               ##" 
echo "###################################"