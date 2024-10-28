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

    # Create a new Shortcuts automation using osascript
    osascript << 'EOF'
tell application "Shortcuts"
    make new shortcut with properties {name:"Open Kitty"}
    tell shortcut "Open Kitty"
        add action "Open App" with properties {appName:"kitty"}
        set keyboard shortcut to "command K"
    end tell
end tell
EOF

    echo "Kitty shortcut setup complete!"
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

# Main execution
echo "Starting macOS setup script..."

# Run setup functions
setup_kitty_shortcut
toggle_window_tiling

echo "Setup complete!" 