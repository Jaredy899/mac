#!/bin/bash

# Set the GITPATH variable to the directory where the script is located
GITPATH="$(cd "$(dirname "$0")" && pwd)"
echo "GITPATH is set to: $GITPATH"

# GitHub URL base for the necessary Homebrew scripts
GITHUB_BASE_URL="https://raw.githubusercontent.com/Jaredy899/mac/main/homebrew-scripts"

# Function to run the updater script
run_updater() {
    if [[ -f "$GITPATH/brew_updater.sh" ]]; then
        echo "Running brew_updater.sh from local directory..."
        bash "$GITPATH/brew_updater.sh"
    else
        echo "Running brew_updater.sh from GitHub..."
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/brew_updater.sh)"
    fi
}

# Function to run the installer script
run_installer() {
    if [[ -f "$GITPATH/brew_installer.sh" ]]; then
        echo "Running brew_installer.sh from local directory..."
        bash "$GITPATH/brew_installer.sh"
    else
        echo "Running brew_installer.sh from GitHub..."
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/brew_installer.sh)"
    fi
}

# Function to run the uninstaller script
run_uninstaller() {
    if [[ -f "$GITPATH/brew_uninstaller.sh" ]]; then
        echo "Running brew_uninstaller.sh from local directory..."
        bash "$GITPATH/brew_uninstaller.sh"
    else
        echo "Running brew_uninstaller.sh from GitHub..."
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/brew_uninstaller.sh)"
    fi
}

# Main script execution
echo "Welcome to the Brew Manager!"

# Run the updater script
run_updater

# Run the installer script
run_installer

# Run the uninstaller script
run_uninstaller

echo "Brew Manager operations complete. Have a nice day!"