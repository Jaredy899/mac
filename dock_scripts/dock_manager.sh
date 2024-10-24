#!/bin/bash

# Set the GITPATH variable to the directory where the script is located
GITPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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

# Function to display menu and get user choice
display_menu() {
    echo "Dock Management Menu:"
    echo "  1. Add Dock icons"
    echo "  2. Remove Dock icons"
    echo "  0. Exit"
    read -p "Enter your choice (0-2): " choice
    echo $choice
}

# Main loop
while true; do
    choice=$(display_menu)
    
    case $choice in
        1)
            echo "Adding Dock items..."
            add_dock_items
            ;;
        2)
            echo "Removing Dock items..."
            remove_dock_items
            ;;
        0)
            echo "Exiting Dock management."
            break
            ;;
        *)
            echo "Invalid option. Please try again."
            ;;
    esac
    
    echo # Empty line for better readability
done

echo "################################"
echo "##                            ##"
echo "## Dock management completed. ##"
echo "##                            ##"
echo "################################"
