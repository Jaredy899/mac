#!/bin/bash

# POSIX-compliant color definitions
ESC=$(printf '\033')
RC="${ESC}[0m"    # Reset
RED="${ESC}[31m"  # Red
GREEN="${ESC}[32m"   # Green
YELLOW="${ESC}[33m"  # Yellow
BLUE="${ESC}[34m"    # Blue
CYAN="${ESC}[36m"    # Cyan

# Check if a path argument is provided
if [ -n "$1" ]; then
    GITPATH="$1"
else
    GITPATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

printf "%sGITPATH is set to: %s%s\n" "${CYAN}" "$GITPATH" "${RC}"
printf "%sCurrent working directory: %s%s\n" "${CYAN}" "$(pwd)" "${RC}"
printf "%sScript location: %s%s\n" "${CYAN}" "${BASH_SOURCE[0]}" "${RC}"

# GitHub URL base for the necessary Dock scripts
GITHUB_BASE_URL="https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/dock_scripts/"

# Function to remove Dock items using icon_remove.sh
remove_dock_items() {
    local script_path="$GITPATH/icon_remove.sh"
    printf "%sChecking for icon_remove.sh at: %s%s\n" "${CYAN}" "$script_path" "${RC}"
    if [[ -f "$script_path" ]]; then
        printf "%sRunning icon_remove.sh from local directory...%s\n" "${GREEN}" "${RC}"
        bash "$script_path"
    else
        printf "%sLocal icon_remove.sh not found. Running from GitHub...%s\n" "${YELLOW}" "${RC}"
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/icon_remove.sh)"
    fi
}

# Function to add Dock items using icon_add.sh
add_dock_items() {
    local script_path="$GITPATH/icon_add.sh"
    printf "%sChecking for icon_add.sh at: %s%s\n" "${CYAN}" "$script_path" "${RC}"
    if [[ -f "$script_path" ]]; then
        printf "%sRunning icon_add.sh from local directory...%s\n" "${GREEN}" "${RC}"
        bash "$script_path"
    else
        printf "%sLocal icon_add.sh not found. Running from GitHub...%s\n" "${YELLOW}" "${RC}"
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/icon_add.sh)"
    fi
}

# Function to manage dock items
manage_dock() {
    while true; do
        printf "%sPlease select from the following options:%s\n" "${CYAN}" "${RC}"
        printf "%s1)%s Add Dock icons\n" "${GREEN}" "${RC}"
        printf "%s2)%s Remove Dock icons\n" "${GREEN}" "${RC}"
        printf "%s0)%s Return to main menu\n" "${RED}" "${RC}"
        printf "Enter your choice (0-2): "
        read choice

        case $choice in
            1)
                printf "%sAdding Dock items...%s\n" "${CYAN}" "${RC}"
                add_dock_items
                ;;
            2)
                printf "%sRemoving Dock items...%s\n" "${CYAN}" "${RC}"
                remove_dock_items
                ;;
            0)
                printf "%sReturning to main menu.%s\n" "${YELLOW}" "${RC}"
                break
                ;;
            *)
                printf "%sInvalid option. Please enter a number between 0 and 2.%s\n" "${RED}" "${RC}"
                ;;
        esac
        printf "\n"
    done
}

# Run the dock manager
manage_dock

printf "%s################################%s\n" "${YELLOW}" "${RC}"
printf "%s##%s                            %s##%s\n" "${YELLOW}" "${RC}" "${YELLOW}" "${RC}"
printf "%s##%s%s Dock management completed. %s##%s\n" "${YELLOW}" "${RC}" "${GREEN}" "${YELLOW}" "${RC}"
printf "%s##%s                            %s##%s\n" "${YELLOW}" "${RC}" "${YELLOW}" "${RC}"
printf "%s################################%s\n" "${YELLOW}" "${RC}"
