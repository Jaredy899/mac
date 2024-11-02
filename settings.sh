#!/bin/bash

# Function to setup Kitty keyboard shortcut
setup_kitty_shortcut() {
    echo "Setting up Kitty keyboard shortcut..."
    
    # Create Scripts directory if it doesn't exist
    mkdir -p ~/Library/Scripts
    
    # Create the AppleScript to handle the keyboard shortcut
    cat << 'EOF' > ~/Library/Scripts/open-kitty.scpt
tell application "kitty"
    activate
end tell
EOF

    # Make the script executable
    chmod +x ~/Library/Scripts/open-kitty.scpt

    echo "Kitty shortcut script created at ~/Library/Scripts/open-kitty.scpt"
    echo "Please set up your keyboard shortcut manually in System Settings > Keyboard > Keyboard Shortcuts"
}

# Function to toggle window tiling
toggle_window_tiling() {
    echo "Toggling window tiling settings..."
    
    current_state=$(defaults read com.apple.dock window-tiling-enabled)
    if [ "$current_state" = "1" ]; then
        defaults write com.apple.dock window-tiling-enabled -bool false
        defaults write com.apple.dock window-tiling-margin -int 0
        echo "Window tiling disabled"
    else
        defaults write com.apple.dock window-tiling-enabled -bool true
        defaults write com.apple.dock window-tiling-margin -int 5
        echo "Window tiling enabled"
    fi
    
    killall Dock
    echo "Dock restarted with new settings"
}

# Function to configure trackpad settings
configure_trackpad() {
    echo "Configuring trackpad settings..."
    
    # Enable tap to click
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
    defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
    
    # Disable natural scrolling
    defaults write NSGlobalDomain com.apple.swipescrolldirection -bool false
    
    # Enable three finger swipe between pages
    defaults write NSGlobalDomain AppleEnableSwipeNavigateWithScrolls -bool true
    defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerHorizSwipeGesture -int 1
    defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerHorizSwipeGesture -int 1
}

# Function to configure dock settings
configure_dock() {
    echo "Configuring dock settings..."
    
    # Enable auto-hide for the dock
    defaults write com.apple.dock autohide -bool true
    
    killall Dock
    echo "Dock settings updated"
}

# Function to enable SSH access
enable_ssh() {
    echo "Enabling SSH access..."
    
    # Check if running with sudo
    if [ "$EUID" -ne 0 ]; then 
        echo "Please run with sudo to enable SSH"
        return 1
    fi
    
    # Enable remote login
    sudo systemsetup -setremotelogin on
    
    # Verify SSH is enabled
    sudo systemsetup -getremotelogin
    
    echo "SSH access enabled"
}

# Main execution
echo "Starting macOS setup script..."

# Run setup functions
setup_kitty_shortcut
toggle_window_tiling
configure_trackpad
configure_dock
enable_ssh

echo "Setup complete!"