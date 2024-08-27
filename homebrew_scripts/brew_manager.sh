#!/bin/bash

# Base URL for GitHub raw content (adjust to match the structure of your repository)
GITHUB_RAW_URL="https://raw.githubusercontent.com/your-username/my-big-repo/main/homebrew-scripts"

# Function to fetch a script from GitHub if it's not present
function fetch_script {
    local script_name=$1
    local script_path="./homebrew-scripts/$script_name"
    
    if [[ ! -f "$script_path" ]]; then
        echo "Fetching $script_name from GitHub..."
        curl -o "$script_path" "$GITHUB_RAW_URL/$script_name"
        chmod +x "$script_path"
    fi
}

# Function to run the updater script
function run_updater {
    echo "Would you like to update your current Homebrew apps and casks? (y/n)"
    read -r update_choice
    if [[ "$update_choice" == "y" || "$update_choice" == "Y" ]]; then
        ./homebrew-scripts/brew_updater.sh
    else
        echo "Skipping updates."
    fi
}

# Function to run the installer script
function run_installer {
    echo "Would you like to install any new Homebrew apps and casks? (y/n)"
    read -r install_choice
    if [[ "$install_choice" == "y" || "$install_choice" == "Y" ]]; then
        ./homebrew-scripts/brew_installer.sh
    else
        echo "Skipping installation."
    fi
}

# Function to run the uninstaller script
function run_uninstaller {
    echo "Would you like to uninstall any Homebrew apps and casks? (y/n)"
    read -r uninstall_choice
    if [[ "$uninstall_choice" == "y" || "$uninstall_choice" == "Y" ]]; then
        ./homebrew-scripts/brew_uninstaller.sh
    else
        echo "Skipping uninstallation."
    fi
}

# Main script execution
echo "Welcome to the Brew Manager!"

# Ensure the homebrew-scripts directory exists
mkdir -p homebrew-scripts

# Fetch necessary scripts from GitHub if they are not already present
fetch_script "brew_updater.sh"
fetch_script "brew_installer.sh"
fetch_script "brew_uninstaller.sh"

# Run the updater script
run_updater

# Run the installer script
run_installer

# Run the uninstaller script
run_uninstaller

echo "Brew Manager operations complete. Have a nice day!"