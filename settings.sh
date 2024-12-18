#!/bin/sh

# Source the common script
eval "$(curl -s https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/dev/common_script.sh)"

# Check for sudo privileges and request if needed
check_sudo() {
    if [ "$EUID" -ne 0 ]; then
        print_warning "This script requires sudo privileges for some operations."
        sudo -v || {
            print_error "Failed to obtain sudo privileges. Exiting."
            exit 1
        }
        # Keep sudo alive
        while true; do sudo -n true; sleep 60; kill -0 "$$" || exit; done 2>/dev/null &
    fi
}

# Function to setup Kitty keyboard shortcut
setup_kitty_shortcut() {
    print_info "Setting up Kitty keyboard shortcut..."
    
    # Create Scripts directory if it doesn't exist
    mkdir -p ~/Library/Scripts
    
    # Create the AppleScript
    cat << 'EOF' > ~/Library/Scripts/open-kitty.scpt
tell application "kitty"
    activate
end tell
EOF

    chmod +x ~/Library/Scripts/open-kitty.scpt

    print_success "Kitty shortcut script created at ~/Library/Scripts/open-kitty.scpt"
    print_warning "Please set up your keyboard shortcut manually in System Settings > Keyboard > Keyboard Shortcuts"
}

# Function to toggle window tiling
toggle_window_tiling() {
    print_info "Toggling window tiling settings..."
    
    current_state=$(defaults read com.apple.dock window-tiling-enabled)
    if [ "$current_state" = "1" ]; then
        defaults write com.apple.dock window-tiling-enabled -bool false
        defaults write com.apple.dock window-tiling-margin -int 0
        print_warning "Window tiling disabled"
    else
        defaults write com.apple.dock window-tiling-enabled -bool true
        defaults write com.apple.dock window-tiling-margin -int 5
        print_success "Window tiling enabled"
    fi
    
    killall Dock
    print_success "Dock restarted with new settings"
}

# Function to configure trackpad settings
configure_trackpad() {
    print_info "Configuring trackpad settings..."
    
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
    defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 1
    defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 1
    
    print_success "Trackpad settings updated successfully"
}

# Function to configure dock settings
configure_dock() {
    print_info "Configuring dock settings..."
    
    defaults write com.apple.dock autohide -bool true
    killall Dock
    
    print_success "Dock settings updated"
}

# Function to enable SSH access
enable_ssh() {
    print_info "Enabling SSH access..."
    
    sudo systemsetup -setremotelogin on
    sudo systemsetup -getremotelogin
    
    print_success "SSH access enabled"
}

# Main execution
print_info "Starting macOS setup script..."

check_sudo
setup_kitty_shortcut
toggle_window_tiling
configure_trackpad
configure_dock
enable_ssh

print_colored "$GREEN" "Setup complete!"
