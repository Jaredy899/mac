#!/bin/bash

# Set the GITPATH variable to the directory where the script is located
GITPATH="$(cd "$(dirname "$0")" && pwd)"
echo "GITPATH is set to: $GITPATH"

# GitHub URL base for the necessary Dock scripts
GITHUB_BASE_URL="https://raw.githubusercontent.com/Jaredy899/mac/main/dock_scripts"

# Function to remove Dock items using icon_remove.sh
remove_dock_items() {
    if [[ -f "$GITPATH/icon_remove.sh" ]]; then
        echo "Running icon_remove.sh from local directory..."
        bash "$GITPATH/icon_remove.sh"
    else
        echo "Running icon_remove.sh from GitHub..."
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/icon_remove.sh)"
    fi
}

# Function to add Dock items using icon_add.sh
add_dock_items() {
    if [[ -f "$GITPATH/icon_add.sh" ]]; then
        echo "Running icon_add.sh from local directory..."
        bash "$GITPATH/icon_add.sh"
    else
        echo "Running icon_add.sh from GitHub..."
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/icon_add.sh)"
    fi
}

# Prompt to remove Dock items
read -p "Do you want to remove Dock items? (y/n): " remove_dock_choice
if [[ "$remove_dock_choice" == "y" || "$remove_dock_choice" == "Y" ]]; then
    echo "Removing Dock items..."
    remove_dock_items
else
    echo "Skipping Dock item removal."
fi

# Prompt to add Dock items
read -p "Do you want to add Dock items? (y/n): " add_dock_choice
if [[ "$add_dock_choice" == "y" || "$add_dock_choice" == "Y" ]]; then
    echo "Adding Dock items..."
    add_dock_items
else
    echo "Skipping Dock item addition."
fi

echo "################################"
echo "##                            ##"
echo "## Dock management completed. ##"
echo "##                            ##"
echo "################################"
