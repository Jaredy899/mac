#!/bin/sh

# Source the common script
eval "$(curl -s https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/common_script.sh)"

# Function to install dockutil if not installed
install_dockutil() {
    if ! command -v dockutil &> /dev/null; then
        print_warning "dockutil is not installed. Installing dockutil..."
        brew install dockutil
    else
        print_success "dockutil is already installed."
    fi
}

# Ensure Homebrew is installed
if ! command -v brew &> /dev/null; then
    print_warning "Homebrew is required but not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    print_success "Homebrew is already installed."
fi

# Install dockutil if necessary
install_dockutil

# Check which applications are currently in the Dock
print_info "Checking current Dock applications..."
IFS=$'\n' read -rd '' -a current_dock_apps < <(dockutil --list | awk -F"\t" '{print $1}' && printf '\0')

# Array to store apps to be removed from the Dock
apps_to_remove=()

# Display a numbered list of current Dock applications and let user pick which ones to remove
if [ ${#current_dock_apps[@]} -gt 0 ]; then
    print_info "Found the following applications in the Dock:"
    
    # Calculate number of rows needed for 3 columns
    total_apps=${#current_dock_apps[@]}
    rows=$(( (total_apps + 2) / 3 ))
    
    # Print applications in columns
    for (( i=0; i<rows; i++ )); do
        for (( j=0; j<3; j++ )); do
            index=$((i + j*rows))
            if [ $index -lt $total_apps ]; then
                # Format the number with padding
                num=$((index+1))
                if [ $num -lt 10 ]; then
                    num_pad=" $num"
                else
                    num_pad="$num"
                fi
                printf "  %s) %-25s" "$num_pad" "${current_dock_apps[$index]}"
            fi
        done
        echo
    done

    print_info "Enter the numbers of the applications you want to remove (separated by space): "
    read -r selected_numbers

    for num in $selected_numbers; do
        if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le ${#current_dock_apps[@]} ]; then
            apps_to_remove+=("${current_dock_apps[$((num-1))]}")
        else
            print_error "Invalid selection: $num. Skipping..."
        fi
    done
else
    print_warning "No applications found in the Dock."
fi

# Remove selected apps from the Dock
if [ ${#apps_to_remove[@]} -gt 0 ]; then
    print_info "Removing selected apps from the Dock..."
    for app in "${apps_to_remove[@]}"; do
        dockutil --remove "$app" --allhomes
        if [ $? -eq 0 ]; then
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
