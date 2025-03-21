#!/bin/sh

# Source the common script
eval "$(curl -s https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/common_script.sh)"

# Function to refresh sudo credentials
function refresh_sudo {
    print_info "Refreshing sudo credentials..."
    sudo -v
}

# Function to update a specific Homebrew item if it's outdated
function update_brew_item {
    local item=$1
    print_info "Updating $item"

    output=$(brew upgrade "$item" 2>&1 || true)
    
    if echo "$output" | grep -q "password"; then
        print_warning "$item requires password..."
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

    brew outdated --formula > /tmp/brew_outdated_formula.txt
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
