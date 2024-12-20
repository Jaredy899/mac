#!/bin/sh

# Source the common script
eval "$(curl -s https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/common_script.sh)"

# Function to refresh sudo credentials
function refresh_sudo {
    print_info "Refreshing sudo credentials..."
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
        printf "."
        sleep 0.5
    done
}

# Function to update a specific Homebrew item if it's outdated
function update_brew_item {
    local item=$1
    print_info "Updating $item"

    show_progress &
    progress_pid=$!

    output=$(brew upgrade "$item" 2>&1 || true)
    
    # Always kill the progress indicator first
    kill $progress_pid > /dev/null 2>&1
    wait $progress_pid 2>/dev/null

    if echo "$output" | grep -q "password"; then
        print_warning "$item requires password. Running without progress indicator..."
        if brew upgrade "$item"; then
            print_success "$item update completed!"
        else
            print_error "Failed to update $item. Please check manually."
        fi
    elif echo "$output" | grep -q "already installed"; then
        print_success "$item is already up to date!"
    elif brew upgrade "$item" &>/dev/null; then
        print_success "$item updated successfully!"
    else
        print_error "Failed to update $item. Please check manually."
    fi
}

# Function to update all apps and casks
function update_brew_items {
    installed_formulae=$(brew list --formula)
    installed_casks=$(brew list --cask)

    print_info "Checking for updates to Homebrew apps and casks..."

    (brew outdated --formula > /tmp/brew_outdated_formula.txt) &
    spinner_pid=$!
    show_spinner $spinner_pid

    outdated_formulae=$(cat /tmp/brew_outdated_formula.txt)

    if [ -n "$outdated_formulae" ]; then
        print_warning "Outdated formulae found. Updating..."
        for item in $outdated_formulae; do
            update_brew_item "$item"
        done
    fi

    print_info "Updating all casks..."
    for cask in $installed_casks; do
        update_brew_item "$cask"
    done

    rm /tmp/brew_outdated_formula.txt
}

# Main script execution
refresh_sudo
update_brew_items

print_colored "$GREEN" "Update completed"
