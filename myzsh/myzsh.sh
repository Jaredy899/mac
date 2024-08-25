#!/usr/bin/env zsh

# Set the GITPATH variable to the directory where the script is located
GITPATH="$(cd "$(dirname "$0")" && pwd)"
echo "GITPATH is set to: $GITPATH"

# GitHub URL base for the necessary configuration files
GITHUB_BASE_URL="https://raw.githubusercontent.com/Jaredy899/mac/main/myzsh"

# Function to install dependencies
installDepend() {
    # List of dependencies
    DEPENDENCIES=(zsh zsh-autocomplete bat croc tree multitail fastfetch wget unzip fontconfig starship fzf zoxide)

    echo "Installing dependencies..."
    for package in "${DEPENDENCIES[@]}"; do
        echo "Installing $package..."
        if ! brew install "$package"; then
            echo "Failed to install $package. Please check your brew installation."
            exit 1
        fi
    done

    # List of cask dependencies, including the Nerd Font
    CASK_DEPENDENCIES=("alacritty" "kitty" "tabby" "font-caskaydia-cove-nerd-font" "font-fira-code-nerd-font")

    echo "Installing cask dependencies: ${CASK_DEPENDENCIES[*]}..."
    for cask in "${CASK_DEPENDENCIES[@]}"; do
        echo "Installing $cask..."
        if ! brew install --cask "$cask"; then
            echo "Failed to install $cask. Please check your brew installation."
            exit 1
        fi
    done

    # Complete fzf installation
    if [ -e ~/.fzf/install ]; then
        ~/.fzf/install --all
    fi
}

# Function to link or copy fastfetch and starship configurations
linkConfig() {
    USER_HOME="$HOME"
    CONFIG_DIR="$USER_HOME/.config"

    # Fastfetch configuration
    FASTFETCH_CONFIG_DIR="$CONFIG_DIR/fastfetch"
    FASTFETCH_CONFIG="$FASTFETCH_CONFIG_DIR/config.jsonc"

    if [ ! -d "$FASTFETCH_CONFIG_DIR" ]; then
        mkdir -p "$FASTFETCH_CONFIG_DIR"
    fi

    if [ ! -f "$FASTFETCH_CONFIG" ]; then
        if [ -f "$GITPATH/config.jsonc" ]; then
            ln -svf "$GITPATH/config.jsonc" "$FASTFETCH_CONFIG" || {
                echo "Failed to create symbolic link for config.jsonc"
                exit 1
            }
            echo "Linked config.jsonc to $FASTFETCH_CONFIG."
        else
            echo "config.jsonc not found in $GITPATH. Attempting to download from GitHub..."
            curl -fsSL "$GITHUB_BASE_URL/config.jsonc" -o "$FASTFETCH_CONFIG" || {
                echo "Failed to download config.jsonc from GitHub."
                exit 1
            }
            echo "Downloaded config.jsonc from GitHub to $FASTFETCH_CONFIG."
        fi
    else
        echo "config.jsonc already exists in $FASTFETCH_CONFIG_DIR."
    fi

    # Starship configuration
    STARSHIP_CONFIG="$CONFIG_DIR/starship.toml"
    if [ ! -f "$STARSHIP_CONFIG" ]; then
        if [ -f "$GITPATH/starship.toml" ]; then
            ln -svf "$GITPATH/starship.toml" "$STARSHIP_CONFIG" || {
                echo "Failed to create symbolic link for starship.toml"
                exit 1
            }
            echo "Linked starship.toml to $STARSHIP_CONFIG."
        else
            echo "starship.toml not found in $GITPATH. Attempting to download from GitHub..."
            curl -fsSL "$GITHUB_BASE_URL/starship.toml" -o "$STARSHIP_CONFIG" || {
                echo "Failed to download starship.toml from GitHub."
                exit 1
            }
            echo "Downloaded starship.toml from GitHub to $STARSHIP_CONFIG."
        fi
    else
        echo "starship.toml already exists in $CONFIG_DIR."
    fi
}

# Function to replace .zshrc with the one from the myzsh folder or download it from GitHub
replace_zshrc() {
    USER_HOME="$HOME"
    ZSHRC_FILE="$USER_HOME/.zshrc"
    ZSHRC_SOURCE="$GITPATH/.zshrc"

    # Backup existing .zshrc if it exists
    if [ -f "$ZSHRC_FILE" ]; then
        echo "Backing up existing .zshrc to .zshrc.backup..."
        cp "$ZSHRC_FILE" "$ZSHRC_FILE.backup"
        echo "Your previous .zshrc has been backed up as .zshrc.backup in your home directory."
    fi

    # Replace .zshrc with the one from myzsh folder or download from GitHub
    if [ -f "$ZSHRC_SOURCE" ]; then
        echo "Replacing .zshrc with the new version from $GITPATH..."
        cp "$ZSHRC_SOURCE" "$ZSHRC_FILE"
        echo ".zshrc replaced successfully."
    else
        echo ".zshrc not found in $GITPATH. Attempting to download from GitHub..."
        if curl -fsSL "$GITHUB_BASE_URL/.zshrc" -o "$ZSHRC_FILE"; then
            echo "Downloaded .zshrc from GitHub to $ZSHRC_FILE."
        else
            echo "Failed to download .zshrc from GitHub."
            exit 1
        fi
    fi
}

# Run all functions
installDepend
linkConfig
replace_zshrc

echo "Use the terminal of your choice and change the font to Caskaydia NF or Fira-Code NF"
echo "Setup completed successfully."