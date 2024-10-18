#!/bin/bash

# Set the GITPATH variable to the directory where the script is located
GITPATH="$(cd "$(dirname "$0")" && pwd)"
echo "GITPATH is set to: $GITPATH"

# GitHub URL base for the necessary configuration files
GITHUB_BASE_URL="https://raw.githubusercontent.com/Jaredy899/mac/main"

# Function to install Homebrew
install_homebrew() {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

# Function to run the brew_manager.sh script from local or GitHub
run_brew_manager() {
    if [[ -f "$GITPATH/homebrew_scripts/brew_manager.sh" ]]; then
        echo "Running brew_manager.sh from local directory..."
        bash "$GITPATH/homebrew_scripts/brew_manager.sh"
    else
        echo "Running brew_manager.sh from GitHub..."
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/homebrew_scripts/brew_manager.sh)"
    fi
}

# Function to run the dock_manager.sh script from local or GitHub
run_dock_manager() {
    if [[ -f "$GITPATH/dock_scripts/dock_manager.sh" ]]; then
        echo "Running dock_manager.sh from local directory..."
        bash "$GITPATH/dock_scripts/dock_manager.sh"
    else
        echo "Running dock_manager.sh from GitHub..."
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/dock_scripts/dock_manager.sh)"
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

# Check if Homebrew is installed and install it if not
if ! command -v brew &> /dev/null; then
    echo "Homebrew is required but not installed. Installing Homebrew..."
    install_homebrew

    # Add Homebrew to PATH and source it immediately
    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> "$HOME/.zprofile"
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "Homebrew is already installed."

    # Ensure Homebrew is in PATH for the current session
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Menu to choose which scripts to run
while true; do
    echo "Please select from the following options:"
    echo "1) Run Homebrew Manager to manage Homebrew apps and casks"
    echo "2) Run Dock Manager to manage Dock items"
    echo "3) Run myzsh to enhance your terminal appearance"
    echo "0) Exit"
    read -p "Enter your choice (1-3): " choice

    case $choice in
        1)
            echo "Running Homebrew Manager..."
            run_brew_manager
            ;;
        2)
            echo "Running Dock Manager..."
            run_dock_manager
            ;;
        3)
            echo "Enhancing terminal appearance with myzsh..."
            run_myzsh
            ;;
        0)
            echo "Exiting setup script."
            break
            ;;
        *)
            echo "Invalid option. Please enter a number between 1 and 4."
            ;;
    esac
done

echo "#############################"
echo "##                         ##"
echo "## Setup script completed. ##"
echo "##                         ##"
echo "#############################"
