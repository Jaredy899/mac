#!/usr/bin/env zsh

# POSIX-compliant color definitions
ESC=$(printf '\033')
RC="${ESC}[0m"    # Reset
RED="${ESC}[31m"  # Red
GREEN="${ESC}[32m"   # Green
YELLOW="${ESC}[33m"  # Yellow
BLUE="${ESC}[34m"    # Blue
CYAN="${ESC}[36m"    # Cyan

# Set the GITPATH variable to the directory where the script is located
GITPATH="$(cd "$(dirname "$0")" && pwd)"
printf "%sGITPATH is set to: %s%s\n" "${CYAN}" "$GITPATH" "${RC}"

# GitHub URL base for the necessary configuration files
GITHUB_BASE_URL="https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/myzsh"

# Function to install dependencies
installDepend() {
    # List of dependencies
    DEPENDENCIES=(zsh zsh-autocomplete bat tree multitail fastfetch wget unzip fontconfig starship fzf zoxide)

    printf "%sInstalling dependencies...%s\n" "${CYAN}" "${RC}"
    for package in "${DEPENDENCIES[@]}"; do
        printf "%sInstalling %s...%s\n" "${CYAN}" "$package" "${RC}"
        if ! brew install "$package"; then
            printf "%sFailed to install %s. Please check your brew installation.%s\n" "${RED}" "$package" "${RC}"
            exit 1
        fi
    done

    # List of cask dependencies
    CASK_DEPENDENCIES=("alacritty" "kitty" "tabby" "font-fira-code-nerd-font")

    printf "%sInstalling cask dependencies: %s%s\n" "${CYAN}" "${CASK_DEPENDENCIES[*]}" "${RC}"
    for cask in "${CASK_DEPENDENCIES[@]}"; do
        printf "%sInstalling %s...%s\n" "${CYAN}" "$cask" "${RC}"
        if ! brew install --cask "$cask"; then
            printf "%sFailed to install %s. Please check your brew installation.%s\n" "${RED}" "$cask" "${RC}"
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
        printf "%sLinking config.jsonc...%s\n" "${CYAN}" "${RC}"
        ln -svf "$GITPATH/config.jsonc" "$FASTFETCH_CONFIG" || {
            printf "%sFailed to create symbolic link for config.jsonc%s\n" "${RED}" "${RC}"
            exit 1
        }
    else
        printf "%sDownloading config.jsonc from GitHub...%s\n" "${YELLOW}" "${RC}"
        curl -fsSL "$GITHUB_BASE_URL/config.jsonc" -o "$FASTFETCH_CONFIG" || {
            printf "%sFailed to download config.jsonc from GitHub.%s\n" "${RED}" "${RC}"
            exit 1
        }
    fi

    # Handle starship config
    STARSHIP_CONFIG="$CONFIG_DIR/starship.toml"
    if [ -f "$GITPATH/starship.toml" ]; then
        printf "%sLinking starship.toml...%s\n" "${CYAN}" "${RC}"
        ln -svf "$GITPATH/starship.toml" "$STARSHIP_CONFIG" || {
            printf "%sFailed to create symbolic link for starship.toml%s\n" "${RED}" "${RC}"
            exit 1
        }
    else
        printf "%sDownloading starship.toml from GitHub...%s\n" "${YELLOW}" "${RC}"
        curl -fsSL "$GITHUB_BASE_URL/starship.toml" -o "$STARSHIP_CONFIG" || {
            printf "%sFailed to download starship.toml from GitHub.%s\n" "${RED}" "${RC}"
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
        printf "%sBacking up existing .zshrc to .zshrc.backup...%s\n" "${YELLOW}" "${RC}"
        cp "$ZSHRC_FILE" "$ZSHRC_FILE.backup"
    fi

    if [ -f "$ZSHRC_SOURCE" ]; then
        printf "%sReplacing .zshrc with the new version...%s\n" "${CYAN}" "${RC}"
        cp "$ZSHRC_SOURCE" "$ZSHRC_FILE"
    else
        printf "%sDownloading .zshrc from GitHub...%s\n" "${YELLOW}" "${RC}"
        if curl -fsSL "$GITHUB_BASE_URL/.zshrc" -o "$ZSHRC_FILE"; then
            printf "%sDownloaded .zshrc successfully.%s\n" "${GREEN}" "${RC}"
        else
            printf "%sFailed to download .zshrc from GitHub.%s\n" "${RED}" "${RC}"
            exit 1
        fi
    fi
}

# Run all functions
installDepend
linkConfig
replace_zshrc

# Final message
printf "%s###########################################################################%s\n" "${YELLOW}" "${RC}"
printf "%s##%s                                                                      %s##%s\n" "${YELLOW}" "${RC}" "${YELLOW}" "${RC}"
printf "%s##%s%s Use the terminal of your choice and change the font to Fira-Code NF. %s##%s\n" "${YELLOW}" "${RC}" "${CYAN}" "${YELLOW}" "${RC}"
printf "%s##%s                                                                      %s##%s\n" "${YELLOW}" "${RC}" "${YELLOW}" "${RC}"
printf "%s##%s%s                        Setup completed successfully.                 %s##%s\n" "${YELLOW}" "${RC}" "${GREEN}" "${YELLOW}" "${RC}"
printf "%s##%s                                                                      %s##%s\n" "${YELLOW}" "${RC}" "${YELLOW}" "${RC}"
printf "%s##########################################################################%s\n" "${YELLOW}" "${RC}"
