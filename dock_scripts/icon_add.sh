#!/bin/bash

# POSIX-compliant color definitions
ESC=$(printf '\033')
RC="${ESC}[0m"    # Reset
RED="${ESC}[31m"  # Red
GREEN="${ESC}[32m"   # Green
YELLOW="${ESC}[33m"  # Yellow
BLUE="${ESC}[34m"    # Blue
CYAN="${ESC}[36m"    # Cyan

# Function to install dockutil if not installed
install_dockutil() {
    if ! command -v dockutil &> /dev/null; then
        printf "%sdockutil is not installed. Installing dockutil...%s\n" "${YELLOW}" "${RC}"
        brew install dockutil
    else
        printf "%sdockutil is already installed.%s\n" "${GREEN}" "${RC}"
    fi
}

# Ensure Homebrew is installed
if ! command -v brew &> /dev/null; then
    printf "%sHomebrew is required but not installed. Installing Homebrew...%s\n" "${YELLOW}" "${RC}"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
else
    printf "%sHomebrew is already installed.%s\n" "${GREEN}" "${RC}"
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
printf "%sScanning for installed applications...%s\n" "${CYAN}" "${RC}"
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
    printf "%sAvailable applications:%s\n" "${CYAN}" "${RC}"
    
    # Calculate number of rows needed for 3 columns
    total_apps=${#sorted_apps[@]}
    rows=$(( (total_apps + 2) / 3 ))
    
    # Print applications in columns
    for (( i=0; i<rows; i++ )); do
        for (( j=0; j<3; j++ )); do
            index=$((i + j*rows))
            if [ $index -lt $total_apps ]; then
                printf "%s%-3d)%s %-25s" "${GREEN}" "$((index+1))" "${RC}" "${sorted_apps[$index]}"
            fi
        done
        printf "\n"
    done

    # Get user selection
    printf "\n%sEnter the numbers of the applications you want to add to the Dock (separated by space):%s " "${CYAN}" "${RC}"
    read -r selected_numbers

    # Process selections
    apps_to_add=()
    for num in $selected_numbers; do
        if [[ "$num" =~ ^[0-9]+$ ]] && [ "$num" -ge 1 ] && [ "$num" -le ${#sorted_apps[@]} ]; then
            apps_to_add+=("${sorted_apps[$((num-1))]}")
        else
            printf "%sInvalid selection: %s. Skipping...%s\n" "${RED}" "$num" "${RC}"
        fi
    done
else
    printf "%sNo non-standard applications found in %s%s\n" "${YELLOW}" "$applications_dir" "${RC}"
fi

# Flag to check if any changes were made
changes_made=false

# Add selected apps to the Dock
if [ ${#apps_to_add[@]} -gt 0 ]; then
    printf "%sAdding selected apps to the Dock...%s\n" "${CYAN}" "${RC}"
    for app in "${apps_to_add[@]}"; do
        app_path="$applications_dir/$app.app"
        if [ -d "$app_path" ]; then
            dockutil --add "$app_path" --allhomes
            if [ $? -eq 0 ]; then
                printf "%s%s successfully added to the Dock.%s\n" "${GREEN}" "$app" "${RC}"
                changes_made=true
            else
                printf "%sFailed to add %s to the Dock. Please check for errors.%s\n" "${RED}" "$app" "${RC}"
            fi
        else
            printf "%sApplication %s not found at %s. Skipping...%s\n" "${YELLOW}" "$app" "$app_path" "${RC}"
        fi
    done
fi

# Reset the Dock only if changes were made
if [ "$changes_made" = true ]; then
    printf "%sResetting the Dock to apply changes...%s\n" "${CYAN}" "${RC}"
    killall Dock
else
    printf "%sNo changes made to the Dock. Reset not needed.%s\n" "${YELLOW}" "${RC}"
fi

printf "%s###################################%s\n" "${YELLOW}" "${RC}"
printf "%s##%s                               %s##%s\n" "${YELLOW}" "${RC}" "${YELLOW}" "${RC}"
printf "%s##%s%s Dock configuration completed. %s##%s\n" "${YELLOW}" "${RC}" "${GREEN}" "${YELLOW}" "${RC}"
printf "%s##%s                               %s##%s\n" "${YELLOW}" "${RC}" "${YELLOW}" "${RC}"
printf "%s###################################%s\n" "${YELLOW}" "${RC}"
