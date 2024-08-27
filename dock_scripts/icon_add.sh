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

# List of standard macOS applications in alphabetical order
standard_apps=(
    "Automator" "Books" "Calendar" "Chess" "Clock" "Contacts" "Dictionary"
    "FaceTime" "Font Book" "Freeform" "Home" "Image Capture" "Launchpad"
    "Mail" "Maps" "Messages" "Mission Control" "Music" "News" "Notes"
    "Passwords" "Photo Booth" "Photos" "Podcasts" "Preview" "QuickTime Player"
    "Reminders" "Safari" "Shortcuts" "Siri" "Stickies" "Stocks" "TV"
    "TextEdit" "Voice Memos" "Weather"
)

# Directory containing user-installed applications
applications_dir="/Applications"

# Array to store non-standard applications
non_standard_apps=()

# Find non-standard applications
echo "Scanning for non-standard applications..."
for app_path in "$applications_dir"/*.app; do
    app_name=$(basename "$app_path" .app)
    if [[ ! " ${standard_apps[*]} " =~ " ${app_name} " ]]; then
        non_standard_apps+=("$app_name")
    fi
done

# Array to store apps to be added to the Dock
apps_to_add=()

# Ask user if they want to add non-standard apps to the Dock
if [ ${#non_standard_apps[@]} -gt 0 ]; then
    echo "Found the following non-standard applications:"
    for app in "${non_standard_apps[@]}"; do
        read -p "Do you want to add $app to the Dock? (y/n): " add_app
        if [[ "$add_app" == "y" || "$add_app" == "Y" ]]; then
            apps_to_add+=("$app")
        else
            echo "Not adding $app to the Dock."
        fi
    done
else
    echo "No non-standard applications found."
fi

# Flag to check if any changes were made
changes_made=false

# Add selected apps to the Dock
if [ ${#apps_to_add[@]} -gt 0 ]; then
    echo "Adding selected apps to the Dock..."
    for app in "${apps_to_add[@]}"; do
        app_path="$applications_dir/$app.app"
        if [ -d "$app_path" ]; then
            dockutil --add "$app_path" --allhomes
            if [ $? -eq 0 ]; then
                echo "$app successfully added to the Dock."
                changes_made=true
            else
                echo "Failed to add $app to the Dock. Please check for errors."
            fi
        else
            echo "Application $app not found at $app_path. Skipping..."
        fi
    done
fi

# Reset the Dock only if changes were made
if [ "$changes_made" = true ]; then
    echo "Resetting the Dock to apply changes..."
    killall Dock
else
    echo "No changes made to the Dock. Reset not needed."
fi

echo "###################################"
echo "##                               ##" 
echo "## Dock configuration completed. ##"
echo "##                               ##" 
echo "###################################"