#!/bin/bash

# Set the GITPATH variable to the directory where the script is located
GITPATH="$(cd "$(dirname "$0")" && pwd)"
echo "GITPATH is set to: $GITPATH"

# GitHub URL base for the necessary Homebrew scripts
GITHUB_BASE_URL="https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/homebrew_scripts"

# Function to run the updater script
run_updater() {
    if [[ -f "$GITPATH/brew_updater.sh" ]]; then
        echo "Running Brew Updater from local directory..."
        bash "$GITPATH/brew_updater.sh"
    else
        echo "Running Brew Updater from GitHub..."
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/brew_updater.sh)"
    fi
}

# Function to run the installer script
run_installer() {
    if [[ -f "$GITPATH/brew_installer.sh" ]]; then
        echo "Running Brew Installer from local directory..."
        bash "$GITPATH/brew_installer.sh"
    else
        echo "Running Brew Installer from GitHub..."
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/brew_installer.sh)"
    fi
}

# Function to run the uninstaller script
run_uninstaller() {
    if [[ -f "$GITPATH/brew_uninstaller.sh" ]]; then
        echo "Running Brew Uninstaller from local directory..."
        bash "$GITPATH/brew_uninstaller.sh"
    else
        echo "Running Brew Uninstaller from GitHub..."
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/brew_uninstaller.sh)"
    fi
}

# Function to manage brew operations
manage_brew() {
    while true; do
        echo "Please select from the following options:"
        echo "1) Run Brew Updater"
        echo "2) Run Brew Installer"
        echo "3) Run Brew Uninstaller"
        echo "0) Return to main menu"
        read -p "Enter your choice (0-3): " choice

        case $choice in
            1)
                echo "Running Brew Updater..."
                run_updater
                ;;
            2)
                echo "Running Brew Installer..."
                run_installer
                ;;
            3)
                echo "Running Brew Uninstaller..."
                run_uninstaller
                ;;
            0)
                echo "Returning to main menu."
                break
                ;;
            *)
                echo "Invalid option. Please enter a number between 0 and 3."
                ;;
        esac
        echo # Empty line for better readability
    done
}

# Run the brew manager
manage_brew
