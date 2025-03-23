#!/bin/sh

# Source the common script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
eval "$(curl -s https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/common_script.sh)"

# Set the GITPATH variable to the directory where the script is located
GITPATH="$SCRIPT_DIR"
print_info "GITPATH is set to: $GITPATH"

# GitHub URL base for the necessary configuration files
GITHUB_BASE_URL="https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/"

# Function to install Homebrew
install_homebrew() {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

# Function to run the brew_manager.sh script from local or GitHub
run_brew_manager() {
    if [[ -f "$GITPATH/homebrew_scripts/brew_manager.sh" ]]; then
        print_info "Running brew_manager.sh from local directory..."
        bash "$GITPATH/homebrew_scripts/brew_manager.sh"
    else
        print_warning "Running brew_manager.sh from GitHub..."
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/homebrew_scripts/brew_manager.sh)"
    fi
}

# Function to run the dock_manager.sh script from local or GitHub
run_dock_manager() {
    local dock_scripts_path="$GITPATH/dock_scripts"
    if [[ -f "$dock_scripts_path/dock_manager.sh" ]]; then
        echo "Running dock_manager.sh from local directory..."
        bash "$dock_scripts_path/dock_manager.sh" "$dock_scripts_path"
    else
        echo "Running dock_manager.sh from GitHub..."
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/dock_scripts/dock_manager.sh)" _ "$dock_scripts_path"
    fi
}

# Function to run the myzsh.sh script from local or GitHub
run_myzsh() {
    if [[ -f "$GITPATH/myzsh/myzsh.sh" ]]; then
        echo "Running myzsh.sh from local directory..."
        bash "$GITPATH/myzsh/myzsh.sh"
    else
        echo "Running myzsh.sh from GitHub..."
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/myzsh/myzsh.sh)"
    fi
}

# Function to run the settings.sh script from local or GitHub
run_settings() {
    if [[ -f "$GITPATH/settings.sh" ]]; then
        echo "Running settings.sh from local directory..."
        bash "$GITPATH/settings.sh"
    else
        echo "Running settings.sh from GitHub..."
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/settings.sh)"
    fi
}

# Function to run the add_ssh_key.sh script from local or GitHub
run_ssh_key_setup() {
    if [[ -f "$GITPATH/add_ssh_key.sh" ]]; then
        print_info "Running add_ssh_key.sh from local directory..."
        sh "$GITPATH/add_ssh_key.sh"
    else
        print_warning "Running add_ssh_key.sh from GitHub..."
        sh -c "$(curl -fsSL $GITHUB_BASE_URL/add_ssh_key.sh)"
    fi
}

# Check if Homebrew is installed and install it if not
if ! command -v brew &> /dev/null; then
    print_warning "Homebrew is required but not installed. Installing Homebrew..."
    install_homebrew

    # Add Homebrew to PATH and source it immediately
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    print_success "Homebrew is already installed."

    # Ensure Homebrew is in PATH for the current session
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Function to show menu items
show_setup_menu() {
    show_menu_item 1 "$selected" "Run Homebrew Manager to manage Homebrew apps and casks"
    show_menu_item 2 "$selected" "Run Dock Manager to manage Dock items"
    show_menu_item 3 "$selected" "Run myzsh to enhance your terminal appearance"
    show_menu_item 4 "$selected" "Run Settings Manager to configure system settings"
    show_menu_item 5 "$selected" "Setup SSH Keys"
    show_menu_item 6 "$selected" "Exit"
}

# Keep running until user chooses to exit
while true; do
    # Handle menu selection
    handle_menu_selection 6 "Setup Menu" show_setup_menu
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
            print_info "Exiting setup script."
            break
            ;;
    esac
done

# Update the completion message
print_colored "$GREEN" "Setup completed"
