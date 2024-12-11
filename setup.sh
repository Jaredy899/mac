#!/bin/bash

# POSIX-compliant color definitions using printf
# Store the escape sequence in a more portable way
ESC=$(printf '\033')
RC="${ESC}[0m"
RED="${ESC}[31m"
YELLOW="${ESC}[33m"
CYAN="${ESC}[36m"
GREEN="${ESC}[32m"

# Set the GITPATH variable to the directory where the script is located
GITPATH="$(cd "$(dirname "$0")" && pwd)"
echo "GITPATH is set to: $GITPATH"

# GitHub URL base for the necessary configuration files
GITHUB_BASE_URL="https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main"

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
    printf "%sPlease select from the following options:%s\n" "${CYAN}" "${RC}"
    printf "%s1)%s Run Homebrew Manager to manage Homebrew apps and casks\n" "${GREEN}" "${RC}"
    printf "%s2)%s Run Dock Manager to manage Dock items\n" "${GREEN}" "${RC}"
    printf "%s3)%s Run myzsh to enhance your terminal appearance\n" "${GREEN}" "${RC}"
    printf "%s4)%s Run Settings Manager to configure system settings\n" "${GREEN}" "${RC}"
    printf "%s0)%s Exit\n" "${RED}" "${RC}"
    printf "Enter your choice (1-4): "
    read choice

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
        4)
            echo "Running Settings Manager..."
            run_settings
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

# Update the completion message
printf "%s#############################%s\n" "${YELLOW}" "${RC}"
printf "%s##%s                         %s##%s\n" "${YELLOW}" "${RC}" "${YELLOW}" "${RC}"
printf "%s##%s%s Setup script completed. %s##%s\n" "${YELLOW}" "${RC}" "${GREEN}" "${YELLOW}" "${RC}"
printf "%s##%s                         %s##%s\n" "${YELLOW}" "${RC}" "${YELLOW}" "${RC}"
printf "%s#############################%s\n" "${YELLOW}" "${RC}"
