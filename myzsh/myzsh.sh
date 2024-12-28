#!/usr/bin/env zsh

# Source the common script
eval "$(curl -s https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/common_script.sh)"

# Set the GITPATH variable to the directory where the script is located
GITPATH="$SCRIPT_DIR"
print_info "GITPATH is set to: $GITPATH"

# GitHub URL base for the necessary configuration files
GITHUB_BASE_URL="https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/myzsh"

# Function to install dependencies
installDepend() {
    # List of dependencies
    DEPENDENCIES=(zsh zsh-autocomplete bat tree multitail fastfetch wget unzip fontconfig starship fzf zoxide)

    print_info "Installing dependencies..."
    for package in "${DEPENDENCIES[@]}"; do
        print_info "Installing $package..."
        if ! brew install "$package"; then
            print_error "Failed to install $package. Please check your brew installation."
            exit 1
        fi
    done

    # List of cask dependencies
    CASK_DEPENDENCIES=("kitty" "ghostty" "font-fira-code-nerd-font")

    print_info "Installing cask dependencies: ${CASK_DEPENDENCIES[*]}"
    for cask in "${CASK_DEPENDENCIES[@]}"; do
        print_info "Installing $cask..."
        if ! brew install --cask "$cask"; then
            print_error "Failed to install $cask. Please check your brew installation."
            exit 1
        fi
    done

    # Complete fzf installation
    if [ -e ~/.fzf/install ]; then
        ~/.fzf/install --all
    fi
}

# Function to link or copy configurations
linkConfig() {
    USER_HOME="$HOME"
    CONFIG_DIR="$USER_HOME/.config"
    
    # Create config directories
    mkdir -p "$CONFIG_DIR/fastfetch"
    
    # Handle fastfetch config
    FASTFETCH_CONFIG="$CONFIG_DIR/fastfetch/config.jsonc"
    if [ -f "$GITPATH/config.jsonc" ]; then
        print_info "Linking config.jsonc..."
        ln -svf "$GITPATH/config.jsonc" "$FASTFETCH_CONFIG" || {
            print_error "Failed to create symbolic link for config.jsonc"
            exit 1
        }
    else
        print_warning "Downloading config.jsonc from GitHub..."
        curl -fsSL "$GITHUB_BASE_URL/config.jsonc" -o "$FASTFETCH_CONFIG" || {
            print_error "Failed to download config.jsonc from GitHub."
            exit 1
        }
    fi

    # Handle starship config
    STARSHIP_CONFIG="$CONFIG_DIR/starship.toml"
    if [ -f "$GITPATH/starship.toml" ]; then
        print_info "Linking starship.toml..."
        ln -svf "$GITPATH/starship.toml" "$STARSHIP_CONFIG" || {
            print_error "Failed to create symbolic link for starship.toml"
            exit 1
        }
    else
        print_warning "Downloading starship.toml from GitHub..."
        curl -fsSL "$GITHUB_BASE_URL/starship.toml" -o "$STARSHIP_CONFIG" || {
            print_error "Failed to download starship.toml from GitHub."
            exit 1
        }
    fi
}

# Function to replace .zshrc
replace_zshrc() {
    USER_HOME="$HOME"
    ZSHRC_FILE="$USER_HOME/.zshrc"
    ZSHRC_SOURCE="$GITPATH/.zshrc"

    if [ -f "$ZSHRC_FILE" ]; then
        print_warning "Backing up existing .zshrc to .zshrc.backup..."
        cp "$ZSHRC_FILE" "$ZSHRC_FILE.backup"
    fi

    if [ -f "$ZSHRC_SOURCE" ]; then
        print_info "Replacing .zshrc with the new version..."
        cp "$ZSHRC_SOURCE" "$ZSHRC_FILE"
    else
        print_warning "Downloading .zshrc from GitHub..."
        if curl -fsSL "$GITHUB_BASE_URL/.zshrc" -o "$ZSHRC_FILE"; then
            print_success "Downloaded .zshrc successfully."
        else
            print_error "Failed to download .zshrc from GitHub."
            exit 1
        fi
    fi
}

# Run all functions
installDepend
linkConfig
replace_zshrc
