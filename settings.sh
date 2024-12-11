#!/bin/bash

# POSIX-compliant color definitions
ESC=$(printf '\033')
RC="${ESC}[0m"    # Reset
RED="${ESC}[31m"  # Red
GREEN="${ESC}[32m"   # Green
YELLOW="${ESC}[33m"  # Yellow
BLUE="${ESC}[34m"    # Blue
CYAN="${ESC}[36m"    # Cyan

# Check for sudo privileges and request if needed
check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        printf "%sThis script requires sudo privileges for some operations.%s\n" "${YELLOW}" "${RC}"
        sudo -v || {
            printf "%sFailed to obtain sudo privileges. Exiting.%s\n" "${RED}" "${RC}"
            exit 1
        }
        # Keep sudo alive
        while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    fi
}

# Function to setup Kitty keyboard shortcut
setup_kitty_shortcut() {
    printf "%sSetting up Kitty keyboard shortcut...%s\n" "${CYAN}" "${RC}"
    
    # Create Scripts directory if it doesn't exist
    mkdir -p ~/Library/Scripts
    
    # Create the AppleScript
    cat << 'EOF' > ~/Library/Scripts/open-kitty.scpt
tell application "kitty"
    activate
end tell
EOF

    chmod +x ~/Library/Scripts/open-kitty.scpt

    printf "%sKitty shortcut script created at ~/Library/Scripts/open-kitty.scpt%s\n" "${GREEN}" "${RC}"
    printf "%sPlease set up your keyboard shortcut manually in System Settings > Keyboard > Keyboard Shortcuts%s\n" "${YELLOW}" "${RC}"
}

# Function to toggle window tiling
toggle_window_tiling() {
    printf "%sToggling window tiling settings...%s\n" "${CYAN}" "${RC}"
    
    current_state=$(defaults read com.apple.dock window-tiling-enabled)
    if [ "$current_state" = "1" ]; then
        defaults write com.apple.dock window-tiling-enabled -bool false
        defaults write com.apple.dock window-tiling-margin -int 0
        printf "%sWindow tiling disabled%s\n" "${YELLOW}" "${RC}"
    else
        defaults write com.apple.dock window-tiling-enabled -bool true
        defaults write com.apple.dock window-tiling-margin -int 5
        printf "%sWindow tiling enabled%s\n" "${GREEN}" "${RC}"
    fi
    
    killall Dock
    printf "%sDock restarted with new settings%s\n" "${GREEN}" "${RC}"
}

# Function to configure trackpad settings
configure_trackpad() {
    printf "%sConfiguring trackpad settings...%s\n" "${CYAN}" "${RC}"
    
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
    defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 1
    defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 1
    
    printf "%sTrackpad settings updated successfully%s\n" "${GREEN}" "${RC}"
}

# Function to configure dock settings
configure_dock() {
    printf "%sConfiguring dock settings...%s\n" "${CYAN}" "${RC}"
    
    defaults write com.apple.dock autohide -bool true
    killall Dock
    
    printf "%sDock settings updated%s\n" "${GREEN}" "${RC}"
}

# Function to enable SSH access
enable_ssh() {
    printf "%sEnabling SSH access...%s\n" "${CYAN}" "${RC}"
    
    sudo systemsetup -setremotelogin on
    sudo systemsetup -getremotelogin
    
    printf "%sSSH access enabled%s\n" "${GREEN}" "${RC}"
}

# Main execution
printf "%sStarting macOS setup script...%s\n" "${CYAN}" "${RC}"

check_sudo
setup_kitty_shortcut
toggle_window_tiling
configure_trackpad
configure_dock
enable_ssh

printf "%sSetup complete!%s\n" "${GREEN}" "${RC}"