#!/bin/bash

# Function to display a menu and get the user's choice
function show_menu {
    echo "Select category:"
    echo "1. Browsers"
    echo "2. Utilities"
    echo "3. Development"
    echo "4. Multimedia"
    echo "5. Other"
    echo "6. Exit"
    read -p "Enter your choice [1-6]: " choice
}

# Function to print apps in columns
function print_columns {
    local app_display=("$@")
    local num_columns=3  # Number of columns to display
    local num_apps=${#app_display[@]}
    local rows=$(( (num_apps + num_columns - 1) / num_columns ))  # Calculate number of rows

    for (( i=0; i<$rows; i++ )); do
        for (( j=0; j<$num_columns; j++ )); do
            index=$(( i + j * rows ))
            if [ $index -lt $num_apps ]; then
                printf "%-25s" "$((index + 1)). ${app_display[$index]}"
            fi
        done
        echo
    done
}

# Function to install selected casks using normal arrays
function install_casks {
    local selected_numbers=("$@")
    for number in "${selected_numbers[@]}"; do
        if [ "$number" -ge 1 ] && [ "$number" -le ${#app_casks[@]} ]; then
            local app_name="${app_casks[number-1]}"
            if brew list --cask "$app_name" &>/dev/null; then
                echo "$app_name is already installed."
            else
                echo "Installing $app_name..."
                brew install --cask "$app_name"
            fi
        else
            echo "Invalid selection: $number"
        fi
    done
}

# Main script loop
while true; do
    show_menu
    case $choice in
        1)
            echo "Browsers:"
            app_display=("Google Chrome" "Firefox" "Brave Browser" "Safari Technology Preview" "Microsoft Edge" "eloston-chromium" "alex313031-thorium")
            app_casks=("google-chrome" "firefox" "brave-browser" "safari-technology-preview" "microsoft-edge" "eloston-chromium" "alex313031-thorium")
            print_columns "${app_display[@]}"
            read -p "Enter the numbers of the browsers you want to install (separated by space): " -a selected
            install_casks "${selected[@]}"
            ;;
        2)
            echo "Utilities:"
            app_display=("Alfred" "Rectangle" "Itsycal" "CleanMyMac X" "BalenaEtcher" "GrandPerspective" "HandBrake" "The Unarchiver" "VLC" "Cloudflare WARP" "Raycast" "Commander One" "RustDesk" "Tailscale" "Termius" "Orbstack" "Ollama" "Raspberry Pi Imager" "PowerShell" "Cursor" "Crystalfetch" "Google Drive")
            app_casks=("alfred" "rectangle" "itsycal" "cleanmymac" "balenaetcher" "grandperspective" "handbrake" "the-unarchiver" "vlc" "cloudflare-warp" "raycast" "commander-one" "rustdesk" "tailscale" "termius" "orbstack" "ollama" "raspberry-pi-imager" "powershell" "cursor" "crystalfetch" "google-drive")
            print_columns "${app_display[@]}"
            read -p "Enter the numbers of the utilities you want to install (separated by space): " -a selected
            install_casks "${selected[@]}"
            ;;
        3)
            echo "Development:"
            app_display=("Visual Studio Code" "Sublime Text" "iTerm2" "Postman" "VSCodium" "Tabby" "UTM" "Parsec" "ChatGPT" "Steam")
            app_casks=("visual-studio-code" "sublime-text" "iterm2" "postman" "vscodium" "tabby" "utm" "parsec" "chatgpt" "steam")
            print_columns "${app_display[@]}"
            read -p "Enter the numbers of the development tools you want to install (separated by space): " -a selected
            install_casks "${selected[@]}"
            ;;
        4)
            echo "Multimedia:"
            app_display=("VLC" "Spotify" "GIMP" "Audacity" "Zoom" "HandBrake")
            app_casks=("vlc" "spotify" "gimp" "audacity" "zoom" "handbrake")
            print_columns "${app_display[@]}"
            read -p "Enter the numbers of the multimedia apps you want to install (separated by space): " -a selected
            install_casks "${selected[@]}"
            ;;
        5)
            echo "Other:"
            app_display=("Visual Studio Code" "VSCodium" "Zoom" "Raspberry Pi Imager" "Tabby" "Tailscale" "PowerShell" "Termius" "Parsec" "Orbstack" "Ollama")
            app_casks=("visual-studio-code" "vscodium" "zoom" "raspberry-pi-imager" "tabby" "tailscale" "powershell" "termius" "parsec" "orbstack" "ollama")
            print_columns "${app_display[@]}"
            read -p "Enter the numbers of the apps you want to install (separated by space): " -a selected
            install_casks "${selected[@]}"
            ;;
        6)
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done

echo "Script completed."