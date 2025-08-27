#!/bin/sh

# Source the common script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/../common_script.sh" ]; then
    . "$SCRIPT_DIR/../common_script.sh"
else
    eval "$(curl -s https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/common_script.sh)"
fi

# Set the GITPATH variable to the directory where the script is located
GITPATH="$SCRIPT_DIR"
print_info "GITPATH is set to: $GITPATH"

# GitHub URL base for the necessary Homebrew scripts
GITHUB_BASE_URL="https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/homebrew_scripts"

# Function to run the updater script
run_updater() {
    if [ -f "$GITPATH/brew_updater.sh" ]; then
        print_success "Running Brew Updater from local directory..."
        bash "$GITPATH/brew_updater.sh"
    else
        print_warning "Running Brew Updater from GitHub..."
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/brew_updater.sh)"
    fi
}

# Function to run the installer script
run_installer() {
    if [ -f "$GITPATH/brew_installer.sh" ]; then
        print_success "Running Brew Installer from local directory..."
        bash "$GITPATH/brew_installer.sh"
    else
        print_warning "Running Brew Installer from GitHub..."
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/brew_installer.sh)"
    fi
}

# Function to run the uninstaller script
run_uninstaller() {
    if [ -f "$GITPATH/brew_uninstaller.sh" ]; then
        print_success "Running Brew Uninstaller from local directory..."
        bash "$GITPATH/brew_uninstaller.sh"
    else
        print_warning "Running Brew Uninstaller from GitHub..."
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/brew_uninstaller.sh)"
    fi
}

# Function to show brew menu items
show_brew_menu() {
    # Initialize selected if not already set
    if [ -z "$selected" ]; then
        selected=1
    fi
    show_menu_item 1 "$selected" "Run Brew Updater"
    show_menu_item 2 "$selected" "Run Brew Installer"
    show_menu_item 3 "$selected" "Run Brew Uninstaller"
    show_menu_item 4 "$selected" "Return to main menu"
}

# Keep running until user chooses to exit
while true; do
    # Handle menu selection
    handle_menu_selection 4 "Homebrew Manager" show_brew_menu
    choice=$?

    case $choice in
        1)
            print_info "Running Brew Updater..."
            run_updater
            print_success "Update completed"
            ;;
        2)
            print_info "Running Brew Installer..."
            run_installer
            print_success "Installer completed"
            ;;
        3)
            print_info "Running Brew Uninstaller..."
            run_uninstaller
            print_success "Uninstaller completed"
            ;;
        4)
            print_info "Returning to main menu."
            break
            ;;
    esac
done
