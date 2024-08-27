#!/bin/bash

# Set the DOCK_SCRIPTS_PATH variable to the directory where the dock scripts are located
DOCK_SCRIPTS_PATH="$(cd "$(dirname "$0")" && pwd)/dock_scripts"
echo "DOCK_SCRIPTS_PATH is set to: $DOCK_SCRIPTS_PATH"

# Function to remove Dock items using icon_remove.sh
remove_dock_items() {
    if [[ -f "$DOCK_SCRIPTS_PATH/icon_remove.sh" ]]; then
        echo "Running icon_remove.sh to remove Dock items..."
        bash "$DOCK_SCRIPTS_PATH/icon_remove.sh"
    else
        echo "Error: icon_remove.sh not found in $DOCK_SCRIPTS_PATH."
        exit 1
    fi
}

# Function to add Dock items using icon_add.sh
add_dock_items() {
    if [[ -f "$DOCK_SCRIPTS_PATH/icon_add.sh" ]]; then
        echo "Running icon_add.sh to add Dock items..."
        bash "$DOCK_SCRIPTS_PATH/icon_add.sh"
    else
        echo "Error: icon_add.sh not found in $DOCK_SCRIPTS_PATH."
        exit 1
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

echo "Dock management completed."