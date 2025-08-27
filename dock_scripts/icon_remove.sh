#!/bin/sh

# Source the common script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/../common_script.sh" ]; then
    . "$SCRIPT_DIR/../common_script.sh"
else
    eval "$(curl -s https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/common_script.sh)"
fi

# Function to install dockutil if not installed
install_dockutil() {
    if ! command -v dockutil > /dev/null 2>&1; then
        print_warning "dockutil is not installed. Installing dockutil..."
        brew install dockutil
    else
        print_success "dockutil is already installed."
    fi
}

# Ensure Homebrew is installed
if ! command -v brew > /dev/null 2>&1; then
    print_warning "Homebrew is required but not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    print_success "Homebrew is already installed."
fi

# Install dockutil if necessary
install_dockutil

# Check which applications are currently in the Dock
print_info "Checking current Dock applications..."
current_dock_apps=$(dockutil --list | awk -F"\t" '{print $1}')

# String to store apps to be removed from the Dock (POSIX compliant)
apps_to_remove=""

# Display a numbered list of current Dock applications and let user pick which ones to remove
# Count total apps by counting lines
total_apps=$(echo "$current_dock_apps" | wc -l)
if [ "$total_apps" -gt 0 ]; then
    print_info "Found the following applications in the Dock:"

    # Calculate number of rows needed for 3 columns
    rows=$(( (total_apps + 2) / 3 ))

    # Print applications in columns
    i=0
    while [ $i -lt $rows ]; do
        j=0
        while [ $j -lt 3 ]; do
            index=$((i + j * rows))
            if [ $index -lt "$total_apps" ]; then
                # Get the app name from the list
                app=$(echo "$current_dock_apps" | sed -n "$((index+1))p")
                # Format the number with padding
                num=$((index+1))
                if [ $num -lt 10 ]; then
                    num_pad=" $num"
                else
                    num_pad="$num"
                fi
                printf "  %s) %-25s" "$num_pad" "$app"
            fi
            j=$((j + 1))
        done
        echo
        i=$((i + 1))
    done

    print_info "Enter the numbers of the applications you want to remove (separated by space): "
    read -r selected_numbers

    for num in $selected_numbers; do
        # Check if num is a valid number
        if echo "$num" | grep -q '^[0-9][0-9]*$' && [ "$num" -ge 1 ] && [ "$num" -le "$total_apps" ]; then
            # Get the app name and add to removal list
            app=$(echo "$current_dock_apps" | sed -n "${num}p")
            if [ -n "$apps_to_remove" ]; then
                apps_to_remove="$apps_to_remove $app"
            else
                apps_to_remove="$app"
            fi
        else
            print_error "Invalid selection: $num. Skipping..."
        fi
    done
else
    print_warning "No applications found in the Dock."
fi

# Remove selected apps from the Dock
if [ -n "$apps_to_remove" ]; then
    print_info "Removing selected apps from the Dock..."
    for app in $apps_to_remove; do
        if dockutil --remove "$app" --allhomes; then
            print_success "\"$app\" successfully removed from the Dock."
        else
            print_error "Failed to remove \"$app\" from the Dock. Please check for errors."
        fi
    done
else
    print_warning "No apps selected for removal. Dock remains unchanged."
fi

# Reset the Dock to apply changes
print_info "Resetting the Dock..."
killall Dock
