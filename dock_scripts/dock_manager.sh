#!/bin/bash

# Check if a path argument is provided
if [ -n "$1" ]; then
    GITPATH="$1"
else
    GITPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

echo "GITPATH is set to: $GITPATH"
echo "Current working directory: $(pwd)"
echo "Script location: ${BASH_SOURCE[0]}"

# GitHub URL base for the necessary Dock scripts
GITHUB_BASE_URL="https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/dock_scripts/"

# Function to remove Dock items using icon_remove.sh
remove_dock_items() {
    local script_path="$GITPATH/icon_remove.sh"
    echo "Checking for icon_remove.sh at: $script_path"
    if [[ -f "$script_path" ]]; then
        echo "Running icon_remove.sh from local directory..."
        bash "$script_path"
    else
        echo "Local icon_remove.sh not found. Running from GitHub..."
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/icon_remove.sh)"
    fi
}

# Function to add Dock items using icon_add.sh
add_dock_items() {
    local script_path="$GITPATH/icon_add.sh"
    echo "Checking for icon_add.sh at: $script_path"
    if [[ -f "$script_path" ]]; then
        echo "Running icon_add.sh from local directory..."
        bash "$script_path"
    else
        echo "Local icon_add.sh not found. Running from GitHub..."
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/icon_add.sh)"
    fi
}

# Function to manage dock items
manage_dock() {
    while true; do
        echo "Please select from the following options:"
        echo "1) Add Dock icons"
        echo "2) Remove Dock icons"
        echo "0) Return to main menu"
        read -p "Enter your choice (0-2): " choice

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
                echo "Returning to main menu."
                break
                ;;
            *)
                echo "Invalid option. Please enter a number between 0 and 2."
                ;;
        esac
        echo # Empty line for better readability
    done
}

# Run the dock manager
manage_dock

echo "################################"
echo "##                            ##"
echo "## Dock management completed. ##"
echo "##                            ##"
echo "################################"
