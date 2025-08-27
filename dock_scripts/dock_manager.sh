#!/bin/sh

# Source the common script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/../common_script.sh" ]; then
    . "$SCRIPT_DIR/../common_script.sh"
else
    eval "$(curl -s https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/common_script.sh)"
fi

# Check if a path argument is provided
if [ -n "$1" ]; then
    GITPATH="$1"
else
    GITPATH="$SCRIPT_DIR"
fi

print_info "GITPATH is set to: $GITPATH"
print_info "Current working directory: $(pwd)"
print_info "Script location: $0"

# Initialize selected menu item
selected=1

# GitHub URL base for the necessary Dock scripts
GITHUB_BASE_URL="https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/dock_scripts/"

# Function to remove Dock items using icon_remove.sh
remove_dock_items() {
    script_path="$GITPATH/icon_remove.sh"
    print_info "Checking for icon_remove.sh at: $script_path"
    if [ -f "$script_path" ]; then
        print_success "Running icon_remove.sh from local directory..."
        bash "$script_path"
    else
        print_warning "Local icon_remove.sh not found. Running from GitHub..."
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/icon_remove.sh)"
    fi
}

# Function to add Dock items using icon_add.sh
add_dock_items() {
    script_path="$GITPATH/icon_add.sh"
    print_info "Checking for icon_add.sh at: $script_path"
    if [ -f "$script_path" ]; then
        print_success "Running icon_add.sh from local directory..."
        bash "$script_path"
    else
        print_warning "Local icon_add.sh not found. Running from GitHub..."
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/icon_add.sh)"
    fi
}

# Function to show dock menu items
show_dock_menu() {
    show_menu_item 1 "$selected" "Add Dock icons"
    show_menu_item 2 "$selected" "Remove Dock icons"
    show_menu_item 3 "$selected" "Return to main menu"
}

# Keep running until user chooses to exit
while true; do
    # Reset selected to 1 for each menu iteration
    selected=1
    # Handle menu selection
    handle_menu_selection 3 "Dock Manager" show_dock_menu
    choice=$?

    case $choice in
        1)
            print_info "Adding Dock items..."
            add_dock_items
            print_success "Dock completed"
            ;;
        2)
            print_info "Removing Dock items..."
            remove_dock_items
            print_success "Dock completed"
            ;;
        3)
            print_info "Returning to main menu."
            break
            ;;
    esac
done
