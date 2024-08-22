#!/usr/bin/env zsh

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

# Function to create fastfetch config
create_fastfetch_config() {
    USER_HOME="$HOME"
    CONFIG_DIR="$USER_HOME/.config/fastfetch"

    echo "Setting up fastfetch configuration..."
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
    fi

    if [ -f "config.jsonc" ]; then
        cp config.jsonc "$CONFIG_DIR/config.jsonc"
        echo "Fastfetch configuration copied to $CONFIG_DIR."
    else
        echo "Fastfetch configuration (config.jsonc) not found in the script directory."
        exit 1
    fi
}

# Function to install starship.toml
install_starship_config() {
    USER_HOME="$HOME"
    CONFIG_DIR="$USER_HOME/.config"

    echo "Setting up starship configuration..."
    if [ ! -d "$CONFIG_DIR" ]; then
        mkdir -p "$CONFIG_DIR"
    fi

    if [ -f "starship.toml" ]; then
        cp starship.toml "$CONFIG_DIR/starship.toml"
        echo "Starship configuration copied to $CONFIG_DIR."
    else
        echo "Starship configuration (starship.toml) not found in the script directory."
        exit 1
    fi
}

# Function to update .zshrc
update_zshrc() {
    USER_HOME="$HOME"
    ZSHRC_FILE="$USER_HOME/.zshrc"

    # Check if .zshrc file exists, if not create it
    if [ ! -f "$ZSHRC_FILE"; then
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
create_fastfetch_config
install_starship_config
update_zshrc

echo "Setup completed successfully."