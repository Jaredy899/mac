#!/bin/bash

# Set the URL to download the binary from
BINARY_URL="https://raw.githubusercontent.com/Jaredy899/mac/main/apps_installer/brew_gui_installer"
BINARY_NAME="brew_gui_installer"

# Check if the binary already exists
if [ ! -f "$BINARY_NAME" ]; then
    echo "Downloading $BINARY_NAME..."
    curl -L -o "$BINARY_NAME" "$BINARY_URL"
fi

# Make the binary executable
chmod +x "$BINARY_NAME"

# Run the binary
./"$BINARY_NAME"

# Optional: Clean up by removing the binary after use
# Uncomment the line below to delete the binary after execution
rm "$BINARY_NAME"