#!/bin/sh

# Source the common script
eval "$(curl -s https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/common_script.sh)"

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

# List of standard macOS applications in alphabetical order (POSIX compliant)
standard_apps="Automator Books Calendar Chess Clock Contacts Dictionary FaceTime FontBook Freeform Home ImageCapture Launchpad Mail Maps Messages MissionControl Music News Notes Passwords PhotoBooth Photos Podcasts Preview QuickTimePlayer Reminders Safari Shortcuts Siri Stickies Stocks TV TextEdit VoiceMemos Weather"

# Directory containing user-installed applications
applications_dir="/Applications"

# String to store non-standard applications (POSIX compliant)
non_standard_apps=""

# Find non-standard applications
print_info "Scanning for installed applications..."

# Use a temporary file to capture results since pipeline creates subshell
temp_file=$(mktemp)
find "$applications_dir" -maxdepth 1 -name "*.app" -print > "$temp_file"

while IFS= read -r app; do
    app_name=$(basename "$app" .app)
    # Check if app_name is not in standard_apps list
    if ! echo "$standard_apps" | grep -q -w "$app_name"; then
        if [ -n "$non_standard_apps" ]; then
            non_standard_apps="$non_standard_apps $app_name"
        else
            non_standard_apps="$app_name"
        fi
    fi
done < "$temp_file"

# Clean up temp file
rm -f "$temp_file"

# Sort non-standard applications alphabetically
if [ -n "$non_standard_apps" ]; then
    sorted_apps=$(echo "$non_standard_apps" | tr ' ' '\n' | sort | tr '\n' ' ')
else
    sorted_apps=""
fi

# Display available applications in columns
# Count total apps by counting words
total_apps=$(echo "$sorted_apps" | wc -w)
if [ "$total_apps" -gt 0 ]; then
    print_info "Available applications:"

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
                app=$(echo "$sorted_apps" | cut -d' ' -f $((index + 1)))
                # Format the number with padding
                num=$((index + 1))
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

    print_info "Enter the numbers of the applications you want to add to the Dock (separated by space): "
    read -r selected_numbers

    # Process selections (POSIX compliant)
    apps_to_add=""
    for num in $selected_numbers; do
        # Check if num is a valid number
        if echo "$num" | grep -q '^[0-9][0-9]*$' && [ "$num" -ge 1 ] && [ "$num" -le "$total_apps" ]; then
            # Get the app name and add to selection list
            app=$(echo "$sorted_apps" | cut -d' ' -f "$num")
            if [ -n "$apps_to_add" ]; then
                apps_to_add="$apps_to_add $app"
            else
                apps_to_add="$app"
            fi
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
if [ -n "$apps_to_add" ]; then
    print_info "Adding selected apps to the Dock..."
    for app in $apps_to_add; do
        app_path="$applications_dir/$app.app"
        if [ -d "$app_path" ]; then
            if dockutil --add "$app_path" --allhomes; then
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
