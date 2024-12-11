#!/bin/bash

# POSIX-compliant color definitions
ESC=$(printf '\033')
RC="${ESC}[0m"    # Reset
RED="${ESC}[31m"  # Red
GREEN="${ESC}[32m"   # Green
YELLOW="${ESC}[33m"  # Yellow
BLUE="${ESC}[34m"    # Blue
CYAN="${ESC}[36m"    # Cyan

# Function to uninstall selected casks
function uninstall_casks {
    local selected_casks=("$@")
    for cask in "${selected_casks[@]}"; do                      
        printf "%sUninstalling %s...%s\n" "${CYAN}" "$cask" "${RC}"
        brew uninstall --cask "$cask"
    done
}

# Function to print apps in columns
function print_columns {
    local app_list=("$@")
    local num_columns=3  # Number of columns to display
    local num_apps=${#app_list[@]}
    local rows=$(( (num_apps + num_columns - 1) / num_columns ))  # Calculate number of rows

    for (( i=0; i<$rows; i++ )); do
        for (( j=0; j<$num_columns; j++ )); do
            index=$(( i + j * rows ))
            if [ $index -lt $num_apps ]; then
                printf "%s%-3d)%s %-22s" "${GREEN}" "$((index + 1))" "${RC}" "${app_list[$index]}"
            fi
        done
        printf "\n"
    done
}

# Function to list installed casks and prompt for uninstallation
function list_and_uninstall {
    printf "%sChecking installed Homebrew casks...%s\n" "${CYAN}" "${RC}"
    installed_casks=$(brew list --cask)

    if [ -z "$installed_casks" ]; then
        printf "%sNo casks are currently installed.%s\n" "${YELLOW}" "${RC}"
        return
    fi

    printf "%sInstalled casks:%s\n" "${CYAN}" "${RC}"
    cask_list=()
    for cask in $installed_casks; do
        cask_list+=("$cask")
    done

    print_columns "${cask_list[@]}"

    printf "Enter the numbers of the casks you want to uninstall (separated by space), or press Enter to skip: "
    read -a selected
    if [ ${#selected[@]} -gt 0 ]; then
        selected_casks=()
        for number in "${selected[@]}"; do
            selected_casks+=("${cask_list[number-1]}")
        done
        uninstall_casks "${selected_casks[@]}"
    else
        printf "%sNo casks selected for uninstallation.%s\n" "${YELLOW}" "${RC}"
    fi
}

# Main script
list_and_uninstall

# Completion message
printf "%s############################%s\n" "${YELLOW}" "${RC}"
printf "%s##%s                        %s##%s\n" "${YELLOW}" "${RC}" "${YELLOW}" "${RC}"
printf "%s##%s%s Uninstaller completed. %s##%s\n" "${YELLOW}" "${RC}" "${GREEN}" "${YELLOW}" "${RC}"
printf "%s##%s                        %s##%s\n" "${YELLOW}" "${RC}" "${YELLOW}" "${RC}"
printf "%s############################%s\n" "${YELLOW}" "${RC}"