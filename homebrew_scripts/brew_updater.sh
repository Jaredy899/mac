#!/bin/bash

# Function to check if pv is installed, and install it if not
function check_and_install_pv {
    if ! command -v pv &> /dev/null; then
        echo "pv (Pipe Viewer) is not installed. Installing now..."
        brew install pv
        echo "pv installed successfully."
    fi
}

# Function to refresh sudo credentials
function refresh_sudo {
    echo "Refreshing sudo credentials..."
    sudo -v
}

# Function to show a simple progress spinner
function show_spinner {
    local pid=$1
    local delay=0.1
    local spinner=('|' '/' '-' '\')
    while [ "$(ps a | awk '{print $1}' | grep $pid)" ]; do
        for i in "${spinner[@]}"; do
            echo -ne "\rChecking for updates... $i"
            sleep $delay
        done
    done
    echo -ne "\r"
}

# Function to show a simple progress bar using dots
function show_progress {
    while true; do
        echo -n "."
        sleep 0.5
    done
}

# Function to update a specific Homebrew item if it's outdated
function update_brew_item {
    local item=$1
    echo -n "Updating $item"

    # Start progress bar in the background
    show_progress &
    progress_pid=$!

    # Update the item and suppress output
    if brew upgrade "$item" > /dev/null 2>&1; then
        # Kill the progress bar process
        kill $progress_pid > /dev/null 2>&1
        echo -e "\r$item updated successfully!"
    else
        # If brew upgrade fails, kill the progress bar and show error message
        kill $progress_pid > /dev/null 2>&1
        echo -e "\rFailed to update $item. Please check manually."
    fi
}

# Function to update all apps and casks
function update_brew_items {
    # Get a list of installed formulae (apps) and casks
    installed_formulae=$(brew list --formula)
    installed_casks=$(brew list --cask)

    # Combine formulae and casks into a single list
    all_installed=($installed_formulae $installed_casks)

    echo "Checking for updates to Homebrew apps and casks..."

    # Start the spinner in the background
    (brew outdated > /tmp/brew_outdated_list.txt) &
    spinner_pid=$!
    show_spinner $spinner_pid

    # Read outdated items from the file
    outdated_items=$(cat /tmp/brew_outdated_list.txt)

    if [ -z "$outdated_items" ]; then
        echo "No updates needed."
    else
        echo "Outdated items found. Updating..."
        for item in $outdated_items; do
            update_brew_item "$item"
        done
    fi

    # Clean up temporary file
    rm /tmp/brew_outdated_list.txt
}

# Main script execution
check_and_install_pv  # Ensure pv is installed before proceeding
refresh_sudo  # Refresh sudo credentials to avoid mid-script password prompts
update_brew_items

# Final message
echo "#################################################"
echo "##                                             ##"
echo "## All Homebrew apps and casks are up to date! ##"
echo "##                                             ##"
echo "#################################################"