#!/usr/bin/env zsh

# Set the GITPATH variable to the directory where the script is located
GITPATH="$(cd "$(dirname "$0")" && pwd)"

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

    # Automatically install Alacritty and Tabby
    CASK_DEPENDENCIES=("alacritty" "tabby")
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

# Function to install MesloLGS Nerd Font
installFont() {
    FONT_NAME="MesloLGS Nerd Font Mono"
    FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/Meslo.zip"
    FONT_DIR="$HOME/Library/Fonts"

    if fc-list :family | grep -iq "$FONT_NAME"; then
        echo "Font '$FONT_NAME' is already installed."
    else
        echo "Installing font '$FONT_NAME'..."
        if wget -q --spider "$FONT_URL"; then
            TEMP_DIR=$(mktemp -d)
            wget -q --show-progress $FONT_URL -O "$TEMP_DIR"/"${FONT_NAME}".zip
            unzip "$TEMP_DIR"/"${FONT_NAME}".zip -d "$FONT_DIR"
            rm -rf "${TEMP_DIR}"
            echo "'$FONT_NAME' installed successfully."
        else
            echo "Font '$FONT_NAME' not installed. Font URL is not accessible."
            exit 1
        fi
    fi
}

# Function to link fastfetch and starship configurations
linkConfig() {
    USER_HOME="$HOME"
    CONFIG_DIR="$USER_HOME/.config"

    # Link fastfetch configuration
    FASTFETCH_CONFIG="$CONFIG_DIR/fastfetch/config.jsonc"
    if [ ! -d "$CONFIG_DIR/fastfetch" ]; then
        mkdir -p "$CONFIG_DIR/fastfetch"
    fi

    if [ -f "$GITPATH/config.jsonc" ]; then
        ln -svf "$GITPATH/config.jsonc" "$FASTFETCH_CONFIG" || {
            echo "Failed to create symbolic link for fastfetch config.jsonc"
            exit 1
        }
        echo "Linked fastfetch config.jsonc to $FASTFETCH_CONFIG."
    else
        echo "config.jsonc not found in $GITPATH."
        exit 1
    fi

    # Link starship configuration
    STARSHIP_CONFIG="$CONFIG_DIR/starship.toml"
    if [ -f "$GITPATH/starship.toml" ]; then
        ln -svf "$GITPATH/starship.toml" "$STARSHIP_CONFIG" || {
            echo "Failed to create symbolic link for starship.toml"
            exit 1
        }
        echo "Linked starship.toml to $STARSHIP_CONFIG."
    else
        echo "starship.toml not found in $GITPATH."
        exit 1
    fi
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
