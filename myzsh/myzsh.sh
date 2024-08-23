#!/usr/bin/env zsh

# Set the GITPATH variable to the directory where the script is located
GITPATH="$(cd "$(dirname "$0")" && pwd)"

# GitHub URL base for config files
GITHUB_URL_BASE="https://raw.githubusercontent.com/Jaredy899/mac/main"

# Function to install dependencies
installDepend() {
    # List of dependencies
    DEPENDENCIES=(zsh zsh-completions bat tree multitail fastfetch wget unzip fontconfig starship fzf zoxide)

    echo "Installing dependencies..."
    for package in "${DEPENDENCIES[@]}"; do
        echo "Installing $package..."
        if ! brew install "$package"; then
            echo "Failed to install $package. Please check your brew installation."
            exit 1
        fi
    done

    # Automatically install Alacritty, Kitty, and Tabby
    CASK_DEPENDENCIES=("alacritty" "kitty" "tabby")
    echo "Installing terminal applications: ${CASK_DEPENDENCIES[*]}..."
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

# Function to download a file from GitHub if it doesn't exist locally
download_or_use_local() {
    local file_name=$1
    local local_path=$2
    local github_url="$GITHUB_URL_BASE/$file_name"

    if [ ! -f "$local_path" ]; then
        echo "$file_name not found locally, downloading from GitHub..."
        if wget -q -O "$local_path" "$github_url"; then
            echo "$file_name downloaded successfully."
        else
            echo "Failed to download $file_name from GitHub. Please check the URL or your network connection."
            exit 1
        fi
    else
        echo "$file_name found locally at $local_path."
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

    # Download or use local config.jsonc
    download_or_use_local "config.jsonc" "$GITPATH/config.jsonc"
    ln -svf "$GITPATH/config.jsonc" "$FASTFETCH_CONFIG" || {
        echo "Failed to create symbolic link for config.jsonc"
        exit 1
    }
    echo "Linked config.jsonc to $FASTFETCH_CONFIG."

    # Starship configuration
    STARSHIP_CONFIG="$CONFIG_DIR/starship.toml"
    download_or_use_local "starship.toml" "$GITPATH/starship.toml"
    ln -svf "$GITPATH/starship.toml" "$STARSHIP_CONFIG" || {
        echo "Failed to create symbolic link for starship.toml"
        exit 1
    }
    echo "Linked starship.toml to $STARSHIP_CONFIG."
}

# Function to update .zshrc
update_zshrc() {
    USER_HOME="$HOME"
    ZSHRC_FILE="$USER_HOME/.zshrc"

    # Check if .zshrc file exists, if not create it
    if [ ! -f "$ZSHRC_FILE" ]; then
        touch "$ZSHRC_FILE"
    fi

    # Add line to the top of the .zshrc file
    AUTOCOMPLETE_LINE="source /opt/homebrew/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"
    if ! grep -Fxq "$AUTOCOMPLETE_LINE" "$ZSHRC_FILE"; then
        echo "$AUTOCOMPLETE_LINE" | cat - "$ZSHRC_FILE" > temp && mv temp "$ZSHRC_FILE"
    fi

    # Add lines to the bottom of the .zshrc file
    STARSHIP_INIT="eval \"\$(starship init zsh)\""
    ZOXIDE_INIT="eval \"\$(zoxide init zsh)\""
    FASTFETCH="fastfetch"

    for LINE in "$STARSHIP_INIT" "$ZOXIDE_INIT" "$FASTFETCH"; do
        if ! grep -Fxq "$LINE" "$ZSHRC_FILE"; then
            echo "$LINE" >> "$ZSHRC_FILE"
        fi
    done

    echo ".zshrc updated."
}

# Run all functions
installDepend
installFont
linkConfig
update_zshrc

echo "Setup completed successfully."