#!/bin/bash

# Function to install Homebrew
install_homebrew() {
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

# Function to run the myzsh.sh script from your GitHub
run_myzsh() {
    bash -c "$(curl -fsSL https://raw.githubusercontent.com/Jaredy899/mac/main/myzsh/myzsh.sh)"
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

# Prompt to run myzsh.sh
read -p "Do you want to run myzsh.sh from your GitHub? (y/n): " run_myzsh_script
if [[ "$run_myzsh_script" == "y" || "$run_myzsh_script" == "Y" ]]; then
    echo "Running myzsh.sh..."
    run_myzsh
else
    echo "Skipping myzsh.sh."
fi

echo "Script completed."