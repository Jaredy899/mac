#!/bin/sh

# setup.sh - Main setup script for Mac automation
# Version: 1.1.0

# Source the common script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
COMMON_SCRIPT_URL="https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/common_script.sh"

# Process command line arguments
SILENT_MODE=0
COMPONENTS_TO_INSTALL=""

print_usage() {
    echo "Usage: $0 [options]"
    echo "Options:"
    echo "  -h, --help                 Show this help message"
    echo "  -s, --silent               Run in silent mode with default options"
    echo "  -c, --components COMP      Specify components to install (comma-separated)"
    echo "                             Available components: homebrew,dock,zsh,settings,ssh,all"
    echo "Examples:"
    echo "  $0 --silent --components all              # Install everything silently"
    echo "  $0 --components homebrew,zsh              # Install only Homebrew and ZSH"
    exit 0
}

# Parse command line arguments
while [ "$#" -gt 0 ]; do
    case "$1" in
        -h|--help)
            print_usage
            ;;
        -s|--silent)
            SILENT_MODE=1
            shift
            ;;
        -c|--components)
            COMPONENTS_TO_INSTALL="$2"
            shift 2
            ;;
        *)
            echo "Unknown option: $1"
            print_usage
            ;;
    esac
done

# Download and verify common script
if ! common_script=$(curl -s "$COMMON_SCRIPT_URL"); then
    echo "ERROR: Failed to download common script from GitHub."
    exit 1
fi

# Execute the common script
eval "$common_script"

# Set the GITPATH variable to the directory where the script is located
GITPATH="$SCRIPT_DIR"
print_info "GITPATH is set to: $GITPATH"

# GitHub URL base for the necessary configuration files
GITHUB_BASE_URL="https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/"

# Function to install Homebrew
install_homebrew() {
    print_info "Installing Homebrew..."
    if ! /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; then
        print_error "Failed to install Homebrew. Please check your internet connection and try again."
        exit 1
    fi
}

# Function to configure Homebrew PATH
configure_homebrew_path() {
    # Detect architecture and set correct Homebrew path
    if [[ "$(uname -m)" == "arm64" ]]; then
        BREW_PATH="/opt/homebrew/bin/brew"
    else
        BREW_PATH="/usr/local/bin/brew"
    fi
    
    # Add to both .zprofile and .zshrc for better compatibility
    if ! grep -q "eval \"\$($BREW_PATH shellenv)\"" "$HOME/.zprofile" 2>/dev/null; then
        echo "eval \"\$($BREW_PATH shellenv)\"" >> "$HOME/.zprofile"
        print_info "Added Homebrew to .zprofile"
    fi
    
    if ! grep -q "eval \"\$($BREW_PATH shellenv)\"" "$HOME/.zshrc" 2>/dev/null; then
        echo "eval \"\$($BREW_PATH shellenv)\"" >> "$HOME/.zshrc"
        print_info "Added Homebrew to .zshrc"
    fi
    
    # Source for current session
    eval "$($BREW_PATH shellenv)"
}

# Function to run the brew_manager.sh script from local or GitHub
run_brew_manager() {
    local script_path="$GITPATH/homebrew_scripts/brew_manager.sh"
    local script_url="$GITHUB_BASE_URL/homebrew_scripts/brew_manager.sh"
    
    if [[ -f "$script_path" ]]; then
        print_info "Running brew_manager.sh from local directory..."
        if ! bash "$script_path"; then
            print_error "brew_manager.sh execution failed."
            return 1
        fi
    else
        print_warning "Running brew_manager.sh from GitHub..."
        local script_content
        if ! script_content=$(curl -fsSL "$script_url"); then
            print_error "Failed to download brew_manager.sh from GitHub."
            return 1
        fi
        
        if ! bash -c "$script_content"; then
            print_error "brew_manager.sh execution failed."
            return 1
        fi
    fi
    
    return 0
}

# Function to install basic Homebrew packages for silent installation
install_basic_homebrew_packages() {
    print_info "Installing basic Homebrew packages for silent installation..."
    
    # Install essential command line tools
    local formulae=(
        "curl"
        "git"
        "wget"
        "zsh"
    )
    
    for formula in "${formulae[@]}"; do
        print_info "Installing $formula..."
        if brew list --formula "$formula" &>/dev/null; then
            print_warning "$formula is already installed."
        else
            if brew install "$formula"; then
                print_success "$formula installed successfully!"
            else
                print_error "Failed to install $formula"
            fi
        fi
    done
    
    print_success "Basic Homebrew packages installation completed."
}

# Function to run the dock_manager.sh script from local or GitHub
run_dock_manager() {
    local dock_scripts_path="$GITPATH/dock_scripts"
    local script_path="$dock_scripts_path/dock_manager.sh"
    local script_url="$GITHUB_BASE_URL/dock_scripts/dock_manager.sh"
    
    if [[ -f "$script_path" ]]; then
        print_info "Running dock_manager.sh from local directory..."
        if ! bash "$script_path" "$dock_scripts_path"; then
            print_error "dock_manager.sh execution failed."
            return 1
        fi
    else
        print_warning "Running dock_manager.sh from GitHub..."
        local script_content
        if ! script_content=$(curl -fsSL "$script_url"); then
            print_error "Failed to download dock_manager.sh from GitHub."
            return 1
        fi
        
        if ! bash -c "$script_content" _ "$dock_scripts_path"; then
            print_error "dock_manager.sh execution failed."
            return 1
        fi
    fi
    
    return 0
}

# Function to set up default Dock items silently
setup_default_dock() {
    print_info "Setting up default Dock items silently..."
    
    # Clear existing Dock items
    defaults delete com.apple.dock persistent-apps || true
    defaults delete com.apple.dock persistent-others || true
    
    # Add common apps to Dock
    local apps=(
        "/System/Applications/Launchpad.app"
        "/System/Applications/System Settings.app"
        "/Applications/Safari.app"
        "/System/Applications/Terminal.app"
    )
    
    for app in "${apps[@]}"; do
        if [ -e "$app" ]; then
            print_info "Adding $app to Dock..."
            defaults write com.apple.dock persistent-apps -array-add "<dict><key>tile-data</key><dict><key>file-data</key><dict><key>_CFURLString</key><string>$app</string><key>_CFURLStringType</key><integer>0</integer></dict></dict></dict>"
        else
            print_warning "App not found: $app"
        fi
    done
    
    # Restart Dock to apply changes
    killall Dock
    
    print_success "Default Dock setup completed."
}

# Function to run the myzsh.sh script from local or GitHub
run_myzsh() {
    local script_path="$GITPATH/myzsh/myzsh.sh"
    local script_url="$GITHUB_BASE_URL/myzsh/myzsh.sh"
    
    if [[ -f "$script_path" ]]; then
        print_info "Running myzsh.sh from local directory..."
        if ! bash "$script_path"; then
            print_error "myzsh.sh execution failed."
            return 1
        fi
    else
        print_warning "Running myzsh.sh from GitHub..."
        local script_content
        if ! script_content=$(curl -fsSL "$script_url"); then
            print_error "Failed to download myzsh.sh from GitHub."
            return 1
        fi
        
        if ! bash -c "$script_content"; then
            print_error "myzsh.sh execution failed."
            return 1
        fi
    fi
    
    return 0
}

# Function to run the settings.sh script from local or GitHub
run_settings() {
    local script_path="$GITPATH/settings.sh"
    local script_url="$GITHUB_BASE_URL/settings.sh"
    
    if [[ -f "$script_path" ]]; then
        print_info "Running settings.sh from local directory..."
        if ! bash "$script_path"; then
            print_error "settings.sh execution failed."
            return 1
        fi
    else
        print_warning "Running settings.sh from GitHub..."
        local script_content
        if ! script_content=$(curl -fsSL "$script_url"); then
            print_error "Failed to download settings.sh from GitHub."
            return 1
        fi
        
        if ! bash -c "$script_content"; then
            print_error "settings.sh execution failed."
            return 1
        fi
    fi
    
    return 0
}

# Function to run the add_ssh_key.sh script from local or GitHub
run_ssh_key_setup() {
    local script_path="$GITPATH/add_ssh_key.sh"
    local script_url="$GITHUB_BASE_URL/add_ssh_key.sh"
    
    if [[ -f "$script_path" ]]; then
        print_info "Running add_ssh_key.sh from local directory..."
        if ! sh "$script_path"; then
            print_error "add_ssh_key.sh execution failed."
            return 1
        fi
    else
        print_warning "Running add_ssh_key.sh from GitHub..."
        local script_content
        if ! script_content=$(curl -fsSL "$script_url"); then
            print_error "Failed to download add_ssh_key.sh from GitHub."
            return 1
        fi
        
        if ! sh -c "$script_content"; then
            print_error "add_ssh_key.sh execution failed."
            return 1
        fi
    fi
    
    return 0
}

# Check if running on macOS
if [ "$(uname)" != "Darwin" ]; then
    print_error "This script is designed for macOS only."
    exit 1
fi

# Function to run interactive menu
run_interactive_menu() {
    # Function to show menu items
    show_setup_menu() {
        show_menu_item 1 "$selected" "Run Homebrew Manager to manage Homebrew apps and casks"
        show_menu_item 2 "$selected" "Run Dock Manager to manage Dock items"
        show_menu_item 3 "$selected" "Run myzsh to enhance your terminal appearance"
        show_menu_item 4 "$selected" "Run Settings Manager to configure system settings"
        show_menu_item 5 "$selected" "Setup SSH Keys"
        show_menu_item 6 "$selected" "Run Full Setup (All options above)"
        show_menu_item 7 "$selected" "Exit"
    }

    # Keep running until user chooses to exit
    while true; do
        # Handle menu selection
        handle_menu_selection 7 "Setup Menu" show_setup_menu
        choice=$?

        case $choice in
            1)
                print_info "Running Homebrew Manager..."
                run_brew_manager
                ;;
            2)
                print_info "Running Dock Manager..."
                run_dock_manager
                ;;
            3)
                print_info "Enhancing terminal appearance with myzsh..."
                run_myzsh
                ;;
            4)
                print_info "Running Settings Manager..."
                run_settings
                ;;
            5)
                print_info "Setting up SSH Keys..."
                run_ssh_key_setup
                ;;
            6)
                print_info "Running Full Setup..."
                run_brew_manager
                run_dock_manager
                run_myzsh
                run_settings
                run_ssh_key_setup
                ;;
            7)
                print_info "Exiting setup script."
                break
                ;;
        esac
    done
}

# Check if Homebrew is installed and install it if not
if ! command -v brew &> /dev/null; then
    print_warning "Homebrew is required but not installed. Installing Homebrew..."
    install_homebrew
    configure_homebrew_path
else
    print_success "Homebrew is already installed."
    # Ensure Homebrew is in PATH for the current session
    if [[ "$(uname -m)" == "arm64" ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    else
        eval "$(/usr/local/bin/brew shellenv)"
    fi
fi

# Run in silent mode if specified
if [ "$SILENT_MODE" -eq 1 ]; then
    print_info "Running in silent mode..."
    
    # Install components based on the COMPONENTS_TO_INSTALL variable
    if [ -z "$COMPONENTS_TO_INSTALL" ]; then
        COMPONENTS_TO_INSTALL="all"
    fi
    
    # Parse components
    if [[ "$COMPONENTS_TO_INSTALL" == *"all"* ]]; then
        print_info "Installing all components..."
        install_basic_homebrew_packages
        setup_default_dock
        run_myzsh
        run_settings
        run_ssh_key_setup
    else
        if [[ "$COMPONENTS_TO_INSTALL" == *"homebrew"* ]]; then
            print_info "Installing Homebrew packages..."
            install_basic_homebrew_packages
        fi
        
        if [[ "$COMPONENTS_TO_INSTALL" == *"dock"* ]]; then
            print_info "Setting up Dock..."
            setup_default_dock
        fi
        
        if [[ "$COMPONENTS_TO_INSTALL" == *"zsh"* ]]; then
            print_info "Setting up ZSH..."
            run_myzsh
        fi
        
        if [[ "$COMPONENTS_TO_INSTALL" == *"settings"* ]]; then
            print_info "Applying system settings..."
            run_settings
        fi
        
        if [[ "$COMPONENTS_TO_INSTALL" == *"ssh"* ]]; then
            print_info "Setting up SSH keys..."
            run_ssh_key_setup
        fi
    fi
    
    print_colored "$GREEN" "Silent setup completed successfully!"
else
    # Run interactive menu
    run_interactive_menu
    
    # Update the completion message
    print_colored "$GREEN" "Setup completed"
fi
