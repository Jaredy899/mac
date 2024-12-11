#!/bin/bash

# POSIX-compliant color definitions
ESC=$(printf '\033')
RC="${ESC}[0m"    # Reset
RED="${ESC}[31m"  # Red
GREEN="${ESC}[32m"   # Green
YELLOW="${ESC}[33m"  # Yellow
BLUE="${ESC}[34m"    # Blue
CYAN="${ESC}[36m"    # Cyan

# Set the GITPATH variable to the directory where the script is located
GITPATH="$(cd "$(dirname "$0")" && pwd)"
printf "%sGITPATH is set to: %s%s\n" "${CYAN}" "$GITPATH" "${RC}"

# GitHub URL base for the necessary Homebrew scripts
GITHUB_BASE_URL="https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/homebrew_scripts"

# Function to run the updater script
run_updater() {
    if [[ -f "$GITPATH/brew_updater.sh" ]]; then
        printf "%sRunning Brew Updater from local directory...%s\n" "${GREEN}" "${RC}"
        bash "$GITPATH/brew_updater.sh"
    else
        printf "%sRunning Brew Updater from GitHub...%s\n" "${YELLOW}" "${RC}"
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/brew_updater.sh)"
    fi
}

# Function to run the installer script
run_installer() {
    if [[ -f "$GITPATH/brew_installer.sh" ]]; then
        printf "%sRunning Brew Installer from local directory...%s\n" "${GREEN}" "${RC}"
        bash "$GITPATH/brew_installer.sh"
    else
        printf "%sRunning Brew Installer from GitHub...%s\n" "${YELLOW}" "${RC}"
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/brew_installer.sh)"
    fi
}

# Function to run the uninstaller script
run_uninstaller() {
    if [[ -f "$GITPATH/brew_uninstaller.sh" ]]; then
        printf "%sRunning Brew Uninstaller from local directory...%s\n" "${GREEN}" "${RC}"
        bash "$GITPATH/brew_uninstaller.sh"
    else
        printf "%sRunning Brew Uninstaller from GitHub...%s\n" "${YELLOW}" "${RC}"
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/brew_uninstaller.sh)"
    fi
}

# Function to manage brew operations
manage_brew() {
    while true; do
        printf "%sPlease select from the following options:%s\n" "${CYAN}" "${RC}"
        printf "%s1)%s Run Brew Updater\n" "${GREEN}" "${RC}"
        printf "%s2)%s Run Brew Installer\n" "${GREEN}" "${RC}"
        printf "%s3)%s Run Brew Uninstaller\n" "${GREEN}" "${RC}"
        printf "%s0)%s Return to main menu\n" "${RED}" "${RC}"
        printf "Enter your choice (0-3): "
        read choice

        case $choice in
            1)
                printf "%sRunning Brew Updater...%s\n" "${CYAN}" "${RC}"
                run_updater
                ;;
            2)
                printf "%sRunning Brew Installer...%s\n" "${CYAN}" "${RC}"
                run_installer
                ;;
            3)
                printf "%sRunning Brew Uninstaller...%s\n" "${CYAN}" "${RC}"
                run_uninstaller
                ;;
            0)
                printf "%sReturning to main menu.%s\n" "${YELLOW}" "${RC}"
                break
                ;;
            *)
                printf "%sInvalid option. Please enter a number between 0 and 3.%s\n" "${RED}" "${RC}"
                ;;
        esac
        printf "\n"
    done
}

# Run the brew manager
manage_brew
