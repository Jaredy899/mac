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
print_info "Scanning for installed applications..."
while IFS= read -r app; do
    app_name=$(basename "$app" .app)
    if [[ ! " ${standard_apps[@]} " =~ " ${app_name} " ]]; then
        non_standard_apps+=("$app_name")
    fi
done < <(find "$applications_dir" -maxdepth 1 -name "*.app" -print)

# Sort non-standard applications alphabetically
IFS=$'\n' sorted_apps=($(sort <<<"${non_standard_apps[*]}"))
unset IFS

# Display available applications in columns
if [ ${#sorted_apps[@]} -gt 0 ]; then
    print_info "Available applications:"
    
    # Calculate number of rows needed for 3 columns
    total_apps=${#sorted_apps[@]}
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
                printf "  %s) %-25s" "$num_pad" "${sorted_apps[$index]}"
            fi
        done
        echo
    done

    print_info "Enter the numbers of the applications you want to add to the Dock (separated by space): "
    read -r selected_numbers

    # Process selections
    apps_to_add=()
    for num in $selected_numbers; do
        if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le ${#sorted_apps[@]} ]; then
            apps_to_add+=("${sorted_apps[$((num-1))]}")
        else
            print_error "Invalid selection: $num. Skipping..."
        fi
    done
else
    print_warning "No non-standard applications found in $applications_dir"
fi

# Flag to check if any changes were made
changes_made=false

# Add selected apps to the Dock
if [ ${#apps_to_add[@]} -gt 0 ]; then
    print_info "Adding selected apps to the Dock..."
    for app in "${apps_to_add[@]}"; do
        app_path="$applications_dir/$app.app"
        if [ -d "$app_path" ]; then
            dockutil --add "$app_path" --allhomes
            if [ $? -eq 0 ]; then
                print_success "$app successfully added to the Dock."
                changes_made=true
            else
                print_error "Failed to add $app to the Dock. Please check for errors."
            fi
        else
            print_warning "Application $app not found at $app_path. Skipping..."
        fi
    done
fi

# Reset the Dock only if changes were made
if [ "$changes_made" = true ]; then
    print_info "Resetting the Dock to apply changes..."
    killall Dock
else
    print_warning "No changes made to the Dock. Reset not needed."
fi
