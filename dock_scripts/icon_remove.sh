#!/bin/bash

# POSIX-compliant color definitions
ESC=$(printf '\033')
RC="${ESC}[0m"    # Reset
RED="${ESC}[31m"  # Red
GREEN="${ESC}[32m"   # Green
YELLOW="${ESC}[33m"  # Yellow
BLUE="${ESC}[34m"    # Blue
CYAN="${ESC}[36m"    # Cyan

# Function to install dockutil if not installed
install_dockutil() {
    if ! command -v dockutil &> /dev/null; then
        printf "%sdockutil is not installed. Installing dockutil...%s\n" "${YELLOW}" "${RC}"
        brew install dockutil
    else
        printf "%sdockutil is already installed.%s\n" "${GREEN}" "${RC}"
    fi
}

# Ensure Homebrew is installed
if ! command -v brew &> /dev/null; then
    printf "%sHomebrew is required but not installed. Installing Homebrew...%s\n" "${YELLOW}" "${RC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    printf "%sHomebrew is already installed.%s\n" "${GREEN}" "${RC}"
fi

# Install dockutil if necessary
install_dockutil

# Check which applications are currently in the Dock
printf "%sChecking current Dock applications...%s\n" "${CYAN}" "${RC}"
IFS=$'\n' read -rd '' -a current_dock_apps < <(dockutil --list | awk -F"\t" '{print $1}' && printf '\0')

# Array to store apps to be removed from the Dock
apps_to_remove=()

# Display a numbered list of current Dock applications and let user pick which ones to remove
if [ ${#current_dock_apps[@]} -gt 0 ]; then
    printf "%sFound the following applications in the Dock:%s\n" "${CYAN}" "${RC}"
    
    # Calculate number of rows needed for 3 columns
    total_apps=${#current_dock_apps[@]}
    rows=$(( (total_apps + 2) / 3 ))
    
    # Print applications in columns
    for (( i=0; i<rows; i++ )); do
        for (( j=0; j<3; j++ )); do
            index=$((i + j*rows))
            if [ $index -lt $total_apps ]; then
                printf "%s%-3d)%s %-25s" "${GREEN}" "$((index+1))" "${RC}" "${current_dock_apps[$index]}"
            fi
        done
        printf "\n"
    done

    printf "\n%sEnter the numbers of the applications you want to remove (separated by space):%s " "${CYAN}" "${RC}"
    read -r selected_numbers

    for num in $selected_numbers; do
        if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le ${#current_dock_apps[@]} ]; then
            apps_to_remove+=("${current_dock_apps[$((num-1))]}")
        else
            printf "%sInvalid selection: %s. Skipping...%s\n" "${RED}" "$num" "${RC}"
        fi
    done
else
    printf "%sNo applications found in the Dock.%s\n" "${YELLOW}" "${RC}"
fi

# Remove selected apps from the Dock
if [ ${#apps_to_remove[@]} -gt 0 ]; then
    printf "%sRemoving selected apps from the Dock...%s\n" "${CYAN}" "${RC}"
    for app in "${apps_to_remove[@]}"; do
        dockutil --remove "$app" --allhomes
        if [ $? -eq 0 ]; then
            printf "%s\"%s\" successfully removed from the Dock.%s\n" "${GREEN}" "$app" "${RC}"
        else
            printf "%sFailed to remove \"%s\" from the Dock. Please check for errors.%s\n" "${RED}" "$app" "${RC}"
        fi
    done
else
    printf "%sNo apps selected for removal. Dock remains unchanged.%s\n" "${YELLOW}" "${RC}"
fi

# Reset the Dock to apply changes
printf "%sResetting the Dock...%s\n" "${CYAN}" "${RC}"
killall Dock

printf "%s###################################%s\n" "${YELLOW}" "${RC}"
printf "%s##%s                               %s##%s\n" "${YELLOW}" "${RC}" "${YELLOW}" "${RC}"
printf "%s##%s%s Dock configuration completed. %s##%s\n" "${YELLOW}" "${RC}" "${GREEN}" "${YELLOW}" "${RC}"
printf "%s##%s                               %s##%s\n" "${YELLOW}" "${RC}" "${YELLOW}" "${RC}"
printf "%s###################################%s\n" "${YELLOW}" "${RC}"
