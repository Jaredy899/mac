#!/bin/bash

# Function to install Homebrew
install_homebrew() {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

# Function to run the myzsh.sh script from your GitHub
run_myzsh() {
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Jaredy899/mac/main/myzsh/myzsh.sh)"
}

# Function to remove Dock items by running the icon_remove.sh script from your GitHub
remove_dock_items() {
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Jaredy899/mac/main/icon_remove.sh)"
}

# Function to add Dock items by running the icon_add.sh script from your GitHub
add_dock_items() {
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Jaredy899/mac/main/icon_add.sh)"
}

# Function to display a prompt with an ASCII box
ask_user() {
    question="$1"
    echo -e "\n┌─────────────────────────────────────────────┐"
    printf "│ %-41s │\n" "$question"
    echo -e "└─────────────────────────────────────────────┘"
    read -p "(y/n): " response
    echo "$response"
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

# Prompt to run myzsh.sh using ASCII box
run_myzsh_script=$(ask_user "Do you want to run myzsh?")
if [[ "$run_myzsh_script" == "y" || "$run_myzsh_script" == "Y" ]]; then
    echo "Running myzsh.sh..."
    run_myzsh
else
    echo "Skipping myzsh.sh."
fi

# Prompt to remove Dock items using ASCII box
remove_dock_script=$(ask_user "Do you want to remove Dock items?")
if [[ "$remove_dock_script" == "y" || "$remove_dock_script" == "Y" ]]; then
    echo "Removing Dock items..."
    remove_dock_items
else
    echo "Skipping Dock item removal."
fi

# Prompt to add Dock items using ASCII box
add_dock_script=$(ask_user "Do you want to add Dock items from your Application?")
if [[ "$add_dock_script" == "y" || "$add_dock_script" == "Y" ]]; then
    echo "Adding Dock items..."
    add_dock_items
else
    echo "Skipping Dock item addition."
fi

echo "Script completed."