#!/bin/sh

# Source the common script
eval "$(curl -s https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/common_script.sh)"

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
    # Disable dock animation
    defaults write com.apple.dock autohide-time-modifier -float 0
    killall Dock
    
    print_success "Dock settings updated (auto-hide enabled, animations disabled)"
}

# Function to enable SSH access
enable_ssh() {
    print_info "Enabling SSH access..."
    
    sudo systemsetup -setremotelogin on
    sudo systemsetup -getremotelogin
    
    print_success "SSH access enabled"
}

# Function to enable TouchID for sudo
enable_touchid_sudo() {
    print_info "Enabling TouchID authentication for sudo..."
    
    # Check if /etc/pam.d/sudo exists
    if [ -f "/etc/pam.d/sudo" ]; then
        # Check if TouchID is already enabled
        if ! grep -q "pam_tid.so" "/etc/pam.d/sudo"; then
            # Add TouchID authentication to sudo
            sudo sed -i '.bak' '1i\
auth       sufficient     pam_tid.so\
' /etc/pam.d/sudo
            print_success "TouchID authentication for sudo enabled"
        else
            print_warning "TouchID authentication for sudo is already enabled"
        fi
    else
        print_error "sudo PAM configuration file not found"
    fi
}

# Function to configure Finder preferences
configure_finder() {
    print_info "Configuring Finder preferences..."
    
    # Show hidden files
    defaults write com.apple.finder AppleShowAllFiles -bool true
    # Show path bar
    defaults write com.apple.finder ShowPathbar -bool true
    # Show status bar
    defaults write com.apple.finder ShowStatusBar -bool true
    
    killall Finder
    print_success "Finder preferences updated"
}

# Function to set default screenshot location
set_screenshot_location() {
    print_info "Setting default screenshot location..."
    
    mkdir -p ~/Screenshots
    defaults write com.apple.screencapture location ~/Screenshots
    killall SystemUIServer
    
    print_success "Screenshot location set to ~/Screenshots"
}

# Function to configure energy saver settings
# configure_energy_saver() {
#     print_info "Configuring energy saver settings..."
    
#     sudo pmset -a displaysleep 10
#     sudo pmset -a sleep 30
    
#     print_success "Energy saver settings updated"
# }

# Function to enable firewall
# enable_firewall() {
#     print_info "Enabling firewall..."
    
#     sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setglobalstate on
#     sudo /usr/libexec/ApplicationFirewall/socketfilterfw --setstealthmode on
    
#     print_success "Firewall enabled and stealth mode activated"
# }

# Main execution
print_info "Starting macOS setup script..."

check_sudo
toggle_window_tiling
configure_trackpad
configure_dock
enable_ssh
enable_touchid_sudo
configure_finder
set_screenshot_location
#configure_energy_saver
#enable_firewall

print_colored "$GREEN" "Setup complete!"
