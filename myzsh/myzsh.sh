#!/bin/bash

# Set the GITPATH variable to the directory where the script is located
GITPATH="$(cd "$(dirname "$0")" && pwd)"
echo "GITPATH is set to: $GITPATH"

# GitHub URL base for the necessary configuration files
GITHUB_BASE_URL="https://raw.githubusercontent.com/Jaredy899/my-big-repo/main"

# Function to install Homebrew
install_homebrew() {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
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

# Function to remove Dock items using local script or GitHub
remove_dock_items() {
    if [[ -f "$GITPATH/dock_scripts/icon_remove.sh" ]]; then
        echo "Removing Dock items using local script..."
        bash "$GITPATH/dock_scripts/icon_remove.sh"
    else
        echo "Removing Dock items using script from GitHub..."
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/dock_scripts/icon_remove.sh)"
    fi
}

# Function to add Dock items using local script or GitHub
add_dock_items() {
    if [[ -f "$GITPATH/dock_scripts/icon_add.sh" ]]; then
        echo "Adding Dock items using local script..."
        bash "$GITPATH/dock_scripts/icon_add.sh"
    else
        echo "Adding Dock items using script from GitHub..."
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/dock_scripts/icon_add.sh)"
    fi
}

# Function to run the brew_manager.sh script from local or GitHub
run_brew_manager() {
    if [[ -f "$GITPATH/homebrew-scripts/brew_manager.sh" ]]; then
        echo "Running brew_manager.sh from local directory..."
        bash "$GITPATH/homebrew-scripts/brew_manager.sh"
    else
        echo "Running brew_manager.sh from GitHub..."
        bash -c "$(curl -fsSL $GITHUB_BASE_URL/homebrew-scripts/brew_manager.sh)"
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

# Prompt to remove Dock items
read -p "Do you want to remove Dock items? (y/n): " remove_dock_script
if [[ "$remove_dock_script" == "y" || "$remove_dock_script" == "Y" ]]; then
    echo "Removing Dock items..."
    remove_dock_items
else
    echo "Skipping Dock item removal."
fi

# Prompt to add Dock items
read -p "Do you want to add Dock items from your Application? (y/n): " add_dock_script
if [[ "$add_dock_script" == "y" || "$add_dock_script" == "Y" ]]; then
    echo "Adding Dock items..."
    add_dock_items
else
    echo "Skipping Dock item addition."
fi

# Prompt to run myzsh.sh
read -p "Do you want to run myzsh.sh from your GitHub? (y/n): " run_myzsh_script
if [[ "$run_myzsh_script" == "y" || "$run_myzsh_script" == "Y" ]]; then
    echo "Running myzsh.sh..."
    run_myzsh
else
    echo "Skipping myzsh.sh."
fi

# Prompt to run brew_manager.sh
read -p "Do you want to manage your Homebrew apps using brew_manager.sh? (y/n): " run_brew_manager_script
if [[ "$run_brew_manager_script" == "y" || "$run_brew_manager_script" == "Y" ]]; then
    echo "Running brew_manager.sh..."
    run_brew_manager
else
    echo "Skipping brew_manager.sh."
fi

echo "Script completed."