#!/bin/bash

# Function to install dockutil if not installed
install_dockutil() {
    if ! command -v dockutil &> /dev/null; then
        echo "dockutil is not installed. Installing dockutil..."
        brew install dockutil
    else
        echo "dockutil is already installed."
    fi
}

# Ensure Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "Homebrew is required but not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    echo "Homebrew is already installed."
fi

# Install dockutil if necessary
install_dockutil

# List of standard macOS applications in alphabetical order
standard_apps=(
    "Automator" "Books" "Calendar" "Chess" "Clock" "Contacts" "Dictionary"
    "FaceTime" "Font Book" "Freeform" "Home" "Image Capture" "Launchpad"
    "Mail" "Maps" "Messages" "Mission Control" "Music" "News" "Notes"
    "Passwords" "Photo Booth" "Photos" "Podcasts" "Preview" "QuickTime Player"
    "Reminders" "Safari" "Shortcuts" "Siri" "Stickies" "Stocks" "TV"
    "TextEdit" "Voice Memos" "Weather"
)

# Directory containing user-installed applications
applications_dir="/Applications"

# Array to store non-standard applications
non_standard_apps=()

# Find non-standard applications
echo "Scanning for non-standard applications..."
for app_path in "$applications_dir"/*.app; do
    app_name=$(basename "$app_path" .app)
    if [[ ! " ${standard_apps[*]} " =~ " ${app_name} " ]]; then
        non_standard_apps+=("$app_name")
    fi
done

# Array to store apps to be added to the Dock
apps_to_add=()

# Display a numbered list of non-standard applications and let user pick which ones to add to the Dock
if [ ${#non_standard_apps[@]} -gt 0 ]; then
    echo "Found the following non-standard applications:"
    
    # Calculate number of rows needed for 3 columns
    total_apps=${#non_standard_apps[@]}
    rows=$(( (total_apps + 2) / 3 ))
    
    # Print in 3 columns
    for ((i=0; i<rows; i++)); do
        # Calculate indices for each column
        idx1=$((i))
        idx2=$((i + rows))
        idx3=$((i + 2*rows))
        
        # Format each line with proper spacing
        printf "%-3d. %-25s" "$((idx1+1))" "${non_standard_apps[idx1]:-}"
        [[ $idx2 -lt $total_apps ]] && printf "%-3d. %-25s" "$((idx2+1))" "${non_standard_apps[idx2]:-}"
        [[ $idx3 -lt $total_apps ]] && printf "%-3d. %-25s" "$((idx3+1))" "${non_standard_apps[idx3]:-}"
        echo
    done

    echo "Enter the numbers of the applications you want to add to the Dock, separated by spaces (e.g., 1 3 5):"
    read -r selected_numbers

    for num in $selected_numbers; do
        if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le ${#non_standard_apps[@]} ]; then
            apps_to_add+=("${non_standard_apps[$((num-1))]}")
        else
            echo "Invalid selection: $num. Skipping..."
        fi
    done
else
    echo "No non-standard applications found."
fi

# Flag to check if any changes were made
changes_made=false

# Add selected apps to the Dock
if [ ${#apps_to_add[@]} -gt 0 ]; then
    echo "Adding selected apps to the Dock..."
    for app in "${apps_to_add[@]}"; do
        app_path="$applications_dir/$app.app"
        if [ -d "$app_path" ]; then
            dockutil --add "$app_path" --allhomes
            if [ $? -eq 0 ]; then
                echo "$app successfully added to the Dock."
                changes_made=true
            else
                echo "Failed to add $app to the Dock. Please check for errors."
            fi
        else
            echo "Application $app not found at $app_path. Skipping..."
        fi
    done
fi

# Reset the Dock only if changes were made
if [ "$changes_made" = true ]; then
    echo "Resetting the Dock to apply changes..."
    killall Dock
else
    echo "No changes made to the Dock. Reset not needed."
fi

echo "###################################"
echo "##                               ##" 
echo "## Dock configuration completed. ##"
echo "##                               ##" 
echo "###################################"
