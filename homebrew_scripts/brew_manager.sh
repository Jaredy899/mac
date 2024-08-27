#!/bin/bash

# Set the GITPATH variable to the directory where the script is located
GITPATH="$(cd "$(dirname "$0")" && pwd)"
echo "GITPATH is set to: $GITPATH"

# GitHub URL base for the necessary Homebrew scripts
GITHUB_BASE_URL="https://raw.githubusercontent.com/Jaredy899/mac/main/homebrew-scripts"

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

# Main script execution

echo "###################################"
echo "##                               ##"    
echo "## Welcome to the Brew Manager!  ##"
echo "##                               ##"
echo "###################################" 

# Prompt to run the updater script
read -p "Do you want to run the Brew Updater? (y/n): " run_updater_script
if [[ "$run_updater_script" == "y" || "$run_updater_script" == "Y" ]]; then
    echo "Running Brew Updater..."
    run_updater
else
    echo "Skipping Brew Updater."
fi

# Prompt to run the installer script
read -p "Do you want to run the Brew Installer? (y/n): " run_installer_script
if [[ "$run_installer_script" == "y" || "$run_installer_script" == "Y" ]]; then
    echo "Running Brew Installer..."
    run_installer
else
    echo "Skipping Brew Installer."
fi

# Prompt to run the uninstaller script
read -p "Do you want to run the Brew Uninstaller? (y/n): " run_uninstaller_script
if [[ "$run_uninstaller_script" == "y" || "$run_uninstaller_script" == "Y" ]]; then
    echo "Running Brew Uninstaller..."
    run_uninstaller
else
    echo "Skipping Brew Uninstaller."
fi

echo "#######################################"
echo "##                                   ##" 
echo "## Brew Manager operations complete. ##"
echo "##                                   ##"
echo "#######################################" 