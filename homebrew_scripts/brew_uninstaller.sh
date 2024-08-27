#!/bin/bash

# Function to uninstall selected casks
function uninstall_casks {
    local selected_casks=("$@")
    for cask in "${selected_casks[@]}"; do
        echo "Uninstalling $cask..."
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
                printf "%-25s" "$((index + 1)). ${app_list[$index]}"
            fi
        done
        echo
    done
}

# Function to list installed casks and prompt for uninstallation
function list_and_uninstall {
    echo "Checking installed Homebrew casks..."
    installed_casks=$(brew list --cask)

    if [ -z "$installed_casks" ]; then
        echo "No casks are currently installed."
        return
    fi

    echo "Installed casks:"
    cask_list=()
    i=1
    for cask in $installed_casks; do
        cask_list+=("$cask")
    done

    print_columns "${cask_list[@]}"

    read -p "Enter the numbers of the casks you want to uninstall (separated by space), or press Enter to skip: " -a selected
    if [ ${#selected[@]} -gt 0 ]; then
        selected_casks=()
        for number in "${selected[@]}"; do
            selected_casks+=("${cask_list[number-1]}")
        done
        uninstall_casks "${selected_casks[@]}"
    else
        echo "No casks selected for uninstallation."
    fi
}

# Main script
list_and_uninstall

echo "Script completed."