#!/bin/bash

# POSIX-compliant color definitions
ESC=$(printf '\033')
RC="${ESC}[0m"    # Reset
RED="${ESC}[31m"  # Red
GREEN="${ESC}[32m"   # Green
YELLOW="${ESC}[33m"  # Yellow
BLUE="${ESC}[34m"    # Blue
CYAN="${ESC}[36m"    # Cyan

# Function to refresh sudo credentials
function refresh_sudo {
    printf "%sRefreshing sudo credentials...%s\n" "${CYAN}" "${RC}"
    sudo -v
}

# Function to show a simple progress spinner
function show_spinner {
    local pid=$1
    local delay=0.1
    local spinner=('|' '/' '-' '\')
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        for i in "${spinner[@]}"; do
            printf "\r%sChecking for updates... %s%s" "${CYAN}" "$i" "${RC}"
            sleep $delay
        done
    done
    printf "\r"
}

# Function to show a simple progress bar using dots
function show_progress {
    while true; do
        printf "%s.%s" "${CYAN}" "${RC}"
        sleep 0.5
    done
}

# Function to update a specific Homebrew item if it's outdated
function update_brew_item {
    local item=$1
    printf "%sUpdating %s%s" "${CYAN}" "$item" "${RC}"

    show_progress &
    progress_pid=$!

    output=$(brew upgrade "$item" 2>&1 || true)
    
    # Always kill the progress indicator first
    kill $progress_pid > /dev/null 2>&1
    wait $progress_pid 2>/dev/null

    if echo "$output" | grep -q "password"; then
        printf "\r%s%s requires password. Running without progress indicator...%s\n" "${YELLOW}" "$item" "${RC}"
        if brew upgrade "$item"; then
            printf "%s%s update completed!%s\n" "${GREEN}" "$item" "${RC}"
        else
            printf "\r%sFailed to update %s. Please check manually.%s\n" "${RED}" "$item" "${RC}"
        fi
    elif echo "$output" | grep -q "already installed"; then
        printf "\r%s%s is already up to date!%s\n" "${GREEN}" "$item" "${RC}"
    elif brew upgrade "$item" &>/dev/null; then
        printf "\r%s%s updated successfully!%s\n" "${GREEN}" "$item" "${RC}"
    else
        printf "\r%sFailed to update %s. Please check manually.%s\n" "${RED}" "$item" "${RC}"
    fi
}

# Function to update all apps and casks
function update_brew_items {
    installed_formulae=$(brew list --formula)
    installed_casks=$(brew list --cask)

    printf "%sChecking for updates to Homebrew apps and casks...%s\n" "${CYAN}" "${RC}"

    (brew outdated --formula > /tmp/brew_outdated_formula.txt) &
    spinner_pid=$!
    show_spinner $spinner_pid

    outdated_formulae=$(cat /tmp/brew_outdated_formula.txt)

    if [ -n "$outdated_formulae" ]; then
        printf "%sOutdated formulae found. Updating...%s\n" "${YELLOW}" "${RC}"
        for item in $outdated_formulae; do
            update_brew_item "$item"
        done
    fi

    printf "%sUpdating all casks...%s\n" "${CYAN}" "${RC}"
    for cask in $installed_casks; do
        printf "%sUpdating %s%s" "${CYAN}" "$cask" "${RC}"
        show_progress &
        progress_pid=$!
        
        output=$(brew install --cask "$cask" 2>&1 || true)
        
        # Always kill the progress indicator first
        kill $progress_pid > /dev/null 2>&1
        wait $progress_pid 2>/dev/null

        if echo "$output" | grep -q "password"; then
            printf "\r%s%s requires password. Running without progress indicator...%s\n" "${YELLOW}" "$cask" "${RC}"
            if brew install --cask "$cask"; then
                printf "%s%s update completed!%s\n" "${GREEN}" "$cask" "${RC}"
            else
                printf "\r%sFailed to update %s. Please check manually.%s\n" "${RED}" "$cask" "${RC}"
            fi
        elif echo "$output" | grep -q "already installed"; then
            printf "\r%s%s is already up to date!%s\n" "${GREEN}" "$cask" "${RC}"
        elif brew install --cask "$cask" &>/dev/null; then
            printf "\r%s%s updated successfully!%s\n" "${GREEN}" "$cask" "${RC}"
        else
            printf "\r%sFailed to update %s. Please check manually.%s\n" "${RED}" "$cask" "${RC}"
        fi
    done

    rm /tmp/brew_outdated_formula.txt
}

# Main script execution
refresh_sudo
update_brew_items

# Final message
printf "%s#################################################%s\n" "${YELLOW}" "${RC}"
printf "%s##%s                                             %s##%s\n" "${YELLOW}" "${RC}" "${YELLOW}" "${RC}"
printf "%s##%s%s All Homebrew apps and casks are up to date! %s##%s\n" "${YELLOW}" "${RC}" "${GREEN}" "${YELLOW}" "${RC}"
printf "%s##%s                                             %s##%s\n" "${YELLOW}" "${RC}" "${YELLOW}" "${RC}"
printf "%s#################################################%s\n" "${YELLOW}" "${RC}"
