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

# Check which applications are currently in the Dock
echo "Checking current Dock applications..."
IFS=$'\n' read -rd '' -a current_dock_apps < <(dockutil --list | awk -F"\t" '{print $1}' && printf '\0')

# Array to store apps to be removed from the Dock
apps_to_remove=()

# Display a numbered list of current Dock applications and let user pick which ones to remove from the Dock
if [ ${#current_dock_apps[@]} -gt 0 ]; then
    echo "Found the following applications in the Dock:"
    
    # Calculate number of rows needed for 3 columns
    total_apps=${#current_dock_apps[@]}
    rows=$(( (total_apps + 2) / 3 ))
    
    # Print in 3 columns
    for ((i=0; i<rows; i++)); do
        # Calculate indices for each column
        idx1=$((i))
        idx2=$((i + rows))
        idx3=$((i + 2*rows))
        
        # Format each line with proper spacing
        printf "%-3d. %-25s" "$((idx1+1))" "${current_dock_apps[idx1]:-}"
        [[ $idx2 -lt $total_apps ]] && printf "%-3d. %-25s" "$((idx2+1))" "${current_dock_apps[idx2]:-}"
        [[ $idx3 -lt $total_apps ]] && printf "%-3d. %-25s" "$((idx3+1))" "${current_dock_apps[idx3]:-}"
        echo
    done

    echo "Enter the numbers of the applications you want to remove from the Dock, separated by spaces (e.g., 1 3 5):"
    read -r selected_numbers

    for num in $selected_numbers; do
        if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le ${#current_dock_apps[@]} ]; then
            apps_to_remove+=("${current_dock_apps[$((num-1))]}")
        else
            echo "Invalid selection: $num. Skipping..."
        fi
    done
else
    echo "No applications found in the Dock."
fi

# Remove selected apps from the Dock
if [ ${#apps_to_remove[@]} -gt 0 ]; then
    echo "Removing selected apps from the Dock..."
    for app in "${apps_to_remove[@]}"; do
        dockutil --remove "$app" --allhomes
        if [ $? -eq 0 ]; then
            echo "\"$app\" successfully removed from the Dock."
        else
            echo "Failed to remove \"$app\" from the Dock. Please check for errors."
        fi
    done
else
    echo "No apps selected for removal. Dock remains unchanged."
fi

# Reset the Dock to apply changes
echo "Resetting the Dock..."
killall Dock

echo "###################################"
echo "##                               ##" 
echo "## Dock configuration completed. ##"
echo "##                               ##" 
echo "###################################"
