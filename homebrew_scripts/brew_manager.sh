#!/bin/sh

# Source the common script
eval "$(curl -s https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/common_script.sh)"

# Set the GITPATH variable to the directory where the script is located
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
GITPATH="$SCRIPT_DIR"
print_info "GITPATH is set to: $GITPATH"

# GitHub URL base for the necessary Homebrew scripts
GITHUB_BASE_URL="https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/homebrew_scripts"

# Function to run a script from local directory or GitHub
run_script() {
    local script_name="$1"
    local script_path="$GITPATH/$script_name"
    local script_url="$GITHUB_BASE_URL/$script_name"
    
    if [[ -f "$script_path" ]]; then
        print_success "Running $script_name from local directory..."
        if ! bash "$script_path"; then
            print_error "$script_name execution failed."
            return 1
        fi
    else
        print_warning "Running $script_name from GitHub..."
        local script_content
        if ! script_content=$(curl -fsSL "$script_url"); then
            print_error "Failed to download $script_name from GitHub."
            return 1
        fi
        
        if ! bash -c "$script_content"; then
            print_error "$script_name execution failed."
            return 1
        fi
    fi
    
    return 0
}

# Function to run the updater script
run_updater() {
    run_script "brew_updater.sh"
}

# Function to run the installer script
run_installer() {
    run_script "brew_installer.sh"
}

# Function to run the uninstaller script
run_uninstaller() {
    run_script "brew_uninstaller.sh"
}

# Function to run the backup script
run_backup() {
    local script_path="$GITPATH/brew_backup.sh"
    local script_url="$GITHUB_BASE_URL/brew_backup.sh"
    
    if [[ -f "$script_path" ]]; then
        print_success "Running brew_backup.sh from local directory..."
        # Source the script instead of executing it to properly return
        source "$script_path"
    else
        print_warning "Running brew_backup.sh from GitHub..."
        local script_content
        if ! script_content=$(curl -fsSL "$script_url"); then
            print_error "Failed to download brew_backup.sh from GitHub."
            return 1
        fi
        
        # Evaluate the script content in the current shell context
        eval "$script_content"
    fi
    
    return 0
}

# Function to show brew menu items
show_brew_menu() {
    show_menu_item 1 "$selected" "Run Brew Updater"
    show_menu_item 2 "$selected" "Run Brew Installer"
    show_menu_item 3 "$selected" "Run Brew Uninstaller"
    show_menu_item 4 "$selected" "Run Brew Backup & Restore"
    show_menu_item 5 "$selected" "Check Homebrew Health"
    show_menu_item 6 "$selected" "Return to main menu"
}

# Function to check Homebrew health
check_homebrew_health() {
    print_info "Checking Homebrew health..."
    
    # Check Homebrew installation
    if ! command -v brew &>/dev/null; then
        print_error "Homebrew is not installed!"
        return 1
    fi
    
    print_success "Homebrew is installed at: $(which brew)"
    print_info "Homebrew version: $(brew --version | head -1)"
    
    # Check doctor
    print_info "Running brew doctor..."
    if brew doctor; then
        print_success "Homebrew is healthy!"
    else
        print_warning "Homebrew reported issues. See above for details."
    fi
    
    # Print statistics
    print_info "Homebrew Statistics:"
    print_info "Installed formulae: $(brew list --formula | wc -l | xargs)"
    print_info "Installed casks: $(brew list --cask | wc -l | xargs)"
    print_info "Tapped repositories: $(brew tap | wc -l | xargs)"
    
    # Check for outdated packages
    print_info "Checking for outdated packages..."
    outdated_formulae=$(brew outdated --formula --verbose)
    outdated_casks=$(brew outdated --cask --verbose)
    
    if [ -n "$outdated_formulae" ]; then
        print_warning "Outdated formulae:"
        echo "$outdated_formulae" | while read line; do
            echo "  - $line"
        done
    else
        print_success "All formulae are up to date!"
    fi
    
    if [ -n "$outdated_casks" ]; then
        print_warning "Outdated casks:"
        echo "$outdated_casks" | while read line; do
            echo "  - $line"
        done
    else
        print_success "All casks are up to date!"
    fi
    
    if [ -n "$outdated_formulae" ] || [ -n "$outdated_casks" ]; then
        if confirm "Would you like to update outdated packages now?"; then
            run_updater
        fi
    fi
}

# Keep running until user chooses to exit
while true; do
    # Handle menu selection
    handle_menu_selection 6 "Homebrew Manager" show_brew_menu
    choice=$?

    case $choice in
        1)
            print_info "Running Brew Updater..."
            run_updater
            print_colored "$GREEN" "Update completed"
            ;;
        2)
            print_info "Running Brew Installer..."
            run_installer
            print_colored "$GREEN" "Installer completed"
            ;;
        3)
            print_info "Running Brew Uninstaller..."
            run_uninstaller
            print_colored "$GREEN" "Uninstaller completed"
            ;;
        4)
            print_info "Running Brew Backup & Restore..."
            run_backup
            print_colored "$GREEN" "Backup & Restore completed"
            ;;
        5)
            print_info "Checking Homebrew Health..."
            check_homebrew_health
            print_colored "$GREEN" "Health check completed"
            ;;
        6)
            print_info "Returning to main menu."
            break
            ;;
    esac
done
