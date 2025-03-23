#!/bin/sh

# Source the common script
eval "$(curl -s https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/common_script.sh)"

# Check for Homebrew
if ! command -v brew &>/dev/null; then
    print_error "Homebrew is not installed. Please install Homebrew first."
    exit 1
fi

# Check for parallel installation support (GNU parallel)
PARALLEL_AVAILABLE=0
if command -v parallel &>/dev/null; then
    PARALLEL_AVAILABLE=1
    print_success "GNU parallel detected. Will use parallel installation."
else
    print_warning "GNU parallel not found. Installing apps sequentially."
    print_info "To enable parallel installation, run: brew install parallel"
fi

# Define categories with formatted display names
declare -A CATEGORIES
CATEGORIES=(
    ["browsers"]="Browsers"
    ["communications"]="Communications"
    ["development"]="Development"
    ["documents"]="Documents"
    ["games"]="Games"
    ["multimedia"]="Multimedia"
    ["utilities"]="Utilities"
)

# Function to display a menu and get the user's choice
function show_installer_menu {
    print_info "Select category:"
    show_menu_item 1 "$selected" "Browsers"
    show_menu_item 2 "$selected" "Communications"
    show_menu_item 3 "$selected" "Development"
    show_menu_item 4 "$selected" "Documents"
    show_menu_item 5 "$selected" "Games"
    show_menu_item 6 "$selected" "Multimedia"
    show_menu_item 7 "$selected" "Utilities"
    show_menu_item 8 "$selected" "Search for apps"
    show_menu_item 9 "$selected" "Exit"
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
                # Format the number with padding
                num=$((index+1))
                if [ $num -lt 10 ]; then
                    num_pad=" $num"
                else
                    num_pad="$num"
                fi
                printf "  %s) %-25s" "$num_pad" "${app_display[$index]}"
            fi
        done
        echo
    done
}

# Function to install selected casks
function install_casks {
    local category=$1
    shift
    local selected_numbers=("$@")
    local apps_to_install=()
    local already_installed=()
    
    # First loop: check which apps are already installed and prepare list for installation
    for number in "${selected_numbers[@]}"; do
        if [ "$number" -ge 1 ] && [ "$number" -le ${#app_casks[@]} ]; then
            local app_name="${app_casks[number-1]}"
            local display_name="${app_display[number-1]}"
            
            if brew list --cask "$app_name" &>/dev/null; then
                already_installed+=("$display_name")
            else
                apps_to_install+=("$app_name")
                print_info "Queued for installation: $display_name"
            fi
        else
            print_error "Invalid selection: $number"
        fi
    done
    
    # Show already installed apps
    if [ ${#already_installed[@]} -gt 0 ]; then
        print_warning "The following apps are already installed: ${already_installed[*]}"
    fi
    
    # Nothing to install
    if [ ${#apps_to_install[@]} -eq 0 ]; then
        print_info "No new apps to install."
        return 0
    fi
    
    # Confirm installation
    print_info "Ready to install ${#apps_to_install[@]} apps."
    if ! confirm "Proceed with installation?"; then
        print_info "Installation cancelled."
        return 0
    fi
    
    # Second loop: install the apps
    if [ "$PARALLEL_AVAILABLE" -eq 1 ] && [ ${#apps_to_install[@]} -gt 1 ]; then
        print_info "Installing ${#apps_to_install[@]} apps in parallel..."
        
        # Use GNU parallel to install apps in parallel
        parallel -j 4 --progress "brew install --cask {} || echo 'Failed to install {}'" ::: "${apps_to_install[@]}"
        
        # Verify installations
        local failed=()
        for app in "${apps_to_install[@]}"; do
            if ! brew list --cask "$app" &>/dev/null; then
                failed+=("$app")
            fi
        done
        
        if [ ${#failed[@]} -eq 0 ]; then
            print_success "All apps installed successfully!"
        else
            print_error "Failed to install the following apps: ${failed[*]}"
        fi
    else
        # Install sequentially
        local successful=0
        local failed=0
        
        for app in "${apps_to_install[@]}"; do
            print_info "Installing $app..."
            if brew install --cask "$app"; then
                print_success "$app installed successfully!"
                successful=$((successful + 1))
            else
                print_error "Failed to install $app"
                failed=$((failed + 1))
            fi
        done
        
        print_info "Installation complete: $successful successful, $failed failed."
    fi
}

# Function to search for available casks
function search_casks {
    print_info "Enter search term:"
    read search_term
    
    if [ -z "$search_term" ]; then
        print_error "Search term cannot be empty."
        return 1
    fi
    
    print_info "Searching for Homebrew casks matching '$search_term'..."
    results=$(brew search --casks "$search_term" 2>/dev/null)
    
    if [ -z "$results" ]; then
        print_error "No casks found matching '$search_term'"
        return 1
    fi
    
    # Convert results to an array
    IFS=$'\n' read -d '' -r -a found_casks <<< "$results"
    
    # Display results with numbers
    print_info "Found ${#found_casks[@]} casks:"
    for i in "${!found_casks[@]}"; do
        local num=$((i+1))
        if [ $num -lt 10 ]; then
            num_pad=" $num"
        else
            num_pad="$num"
        fi
        printf "  %s) %s\n" "$num_pad" "${found_casks[$i]}"
    done
    
    # Ask which ones to install
    print_info "Enter the numbers of the casks you want to install (separated by space), or 0 to cancel: "
    read -a selected
    
    # Check if user wants to cancel
    if [ "${#selected[@]}" -eq 1 ] && [ "${selected[0]}" -eq 0 ]; then
        print_info "Installation cancelled."
        return 0
    fi
    
    # Prepare arrays for installation
    local casks_to_install=()
    for number in "${selected[@]}"; do
        if [ "$number" -ge 1 ] && [ "$number" -le ${#found_casks[@]} ]; then
            casks_to_install+=("${found_casks[number-1]}")
        else
            print_error "Invalid selection: $number"
        fi
    done
    
    # Install selected casks
    if [ ${#casks_to_install[@]} -gt 0 ]; then
        print_info "Installing ${#casks_to_install[@]} casks..."
        for cask in "${casks_to_install[@]}"; do
            print_info "Installing $cask..."
            if brew install --cask "$cask"; then
                print_success "$cask installed successfully!"
            else
                print_error "Failed to install $cask"
            fi
        done
    else
        print_info "No casks selected for installation."
    fi
}

# Main script loop
while true; do
    handle_menu_selection 9 "Homebrew Installer" show_installer_menu
    choice=$?

    case $choice in
        1)
            print_info "Browsers:"
            app_display=("Arc" "Brave" "Google Chrome" "Chromium" "Edge" "Firefox" "Floorp" "LibreWolf" "Mullvad Browser" "Thorium Browser" "Tor Browser" "Ungoogled" "Vivaldi" "Waterfox" "Zen Browser")
            app_casks=("arc" "brave-browser" "google-chrome" "chromium" "microsoft-edge" "firefox" "floorp" "Librewolf" "mullvad-browser" "alex313031-thorium" "tor-browser" "eloston-chromium" "vivaldi" "waterfox" "zen-browser")
            print_columns "${app_display[@]}"
            print_info "Enter the numbers of the browsers you want to install (separated by space): "
            read -a selected
            install_casks "browsers" "${selected[@]}"
            ;;
        2)
            print_info "Communications:"
            app_display=("Chatterino" "Discord" "Ferdium" "Jami" "Element" "Signal" "Skype" "Microsoft Teams" "Telegram" "Thunderbird" "Viber" "Zoom" "Zulip")
            app_casks=("chatterino" "discord" "ferdium" "jami" "element" "signal" "skype" "microsoft-teams" "telegram" "thunderbird" "viber" "zoom" "zulip")
            print_columns "${app_display[@]}"
            print_info "Enter the numbers of the utilities you want to install (separated by space): "
            read -a selected
            install_casks "communications" "${selected[@]}"
            ;;
        3)
            print_info "Development:"
            app_display=("Anaconda" "CMake" "Docker Desktop" "Fork" "Git Butler" "GitHub Desktop" "Gitify" "GitKraken" "Godot Engine" "Miniconda" "OrbStack" "Postman" "Pulsar" "Sublime Merge" "Sublime Text" "Thonny Python IDE" "Vagrant" "VS Code" "VS Codium" "Wezterm" )
            app_casks=("anaconda" "cmake" "docker" "fork" "gitbutler" "github" "gitify" "gitkraken" "godot" "miniconda" "orbstack" "postman" "pulsar" "sublime-merge" "sublime-text" "thonny" "vagrant" "visual-studio-code" "vscodium" "wezterm" )
            print_columns "${app_display[@]}"
            print_info "Enter the numbers of the development tools you want to install (separated by space): "
            read -a selected
            install_casks "development" "${selected[@]}"
            ;;
        4)
            print_info "Documents:"
            app_display=("Adobe Acrobat Reader" "AFFiNE" "Anki" "Calibre" "Foxit PDF Editor" "Foxit Reader" "Joplin" "LibreOffice" "Logseq" "massCode" "NAPS2" "Obsidian" "ONLYOFFICE" "Apache OpenOffice" "PDFsam Basic" "Simplenote" "Znote" "Zotero")
            app_casks=("adobe-acrobat-reader" "affine" "anki" "calibre" "foxit-pdf-editor" "foxitreader" "joplin" "libreoffice" "logseq" "masscode" "naps2" "obsidian" "onlyoffice" "openoffice" "pdfsam-basic" "simplenote" "znote" "zotero")
            print_columns "${app_display[@]}"
            print_info "Enter the numbers of the document apps you want to install (separated by space): "
            read -a selected
            install_casks "documents" "${selected[@]}"
            ;;
        5)
            print_info "Games:"
            app_display=("ATLauncher" "Clone Hero" "EA App" "Epic Games Launcher" "Heroic Games Launcher" "Moonlight" "PS Remote Play" "SideQuest" "Steam" "XEMU")
            app_casks=("atlauncher" "clone-hero" "ea" "epic-games" "heroic" "moonlight" "sony-ps-remote-play" "sidequest" "steam" "xemu")
            print_columns "${app_display[@]}"
            print_info "Enter the numbers of the games you want to install (separated by space): "
            read -a selected
            install_casks "games" "${selected[@]}"
            ;;
        6)
            print_info "Multimedia:"
            app_display=("Audacity" "Blender" "darktable" "draw.io" "foobar2000" "FreeCAD" "GIMP" "HandBrake" "Iina" "Inkscape" "Jellyfin Media Player" "Jellyfin Server" "Kdenlive" "KiCad" "Krita" "Mp3tag" "OBS" "Plex Media Server" "Plex Desktop" "Shotcut" "Spotify" "Tidal" "VLC" "XnViewMP" "Yt-dip")
            app_casks=("audacity" "blender" "darktable" "drawio" "foobar2000" "freecad" "gimp" "handbrake" "iina" "inkscape" "jellyfin-media-player" "jellyfin" "kdenlive" "kicad" "krita" "mp3tag" "obs" "plex-media-server" "plex" "shotcut" "spotify" "tidal" "vlc" "xnviewmp" "yt-dip")
            print_columns "${app_display[@]}"
            print_info "Enter the numbers of the multimedia apps you want to install (separated by space): "
            read -a selected
            install_casks "multimedia" "${selected[@]}"
            ;;
        7)
            print_info "Utilities:"
            app_display=("1Password" "Alacritty Terminal" "Alfred" "AnyDesk" "AppCleaner" "Barrier" "Bitwarden" "coconutBattery" "Commander One" "CopyQ" "Cpuinfo" "CustomShortcuts" "DevToys" "Dropbox" "Duplicati" "Espanso" "Etcher" "EtreCheck" "Find Any File" "f.lux" "Ghostty" "GrandPerspective" "Hidden Bar" "iTerm2" "Itsycal" "KeePassXC" "KeepingYouAwake" "Maccy" "Macs Fan Control" "Malwarebytes" "Memory Cleaner" "Microsoft Remote Desktop" "MonitorControl" "Motrix" "Mullvad VPN" "Nextcloud" "Numi" "OmniDiskSweeper" "OpenRBG" "Ollama" "onyX" "Orca Slicer" "ownCloud" "Parsec" "Podman Desktop" "PowerShell" "Raspberry Pi Imager" "Raycast" "Rectangle" "Renamer" "PrusaSlicer" "qBittorent" "Spacedrive File Manager" "Stats" "Syncthing" "Tabby.sh" "Tailscale" "TeamViewer" "Termius" "The Unarchiver" "Tiles" "Transmission" "UTM" "Warp" "Wireshark" "Xtreme Download Manager" "ZeroTier One" )
            app_casks=("1password" "alacritty" "alfred" "anydesk" "appcleaner" "barrier" "bitwarden" "coconutbattery" "commander-one" "copyq" "cpuinfo" "customshortcuts" "devtoys" "dropbox" "duplicati" "espanso" "balenaetcher" "etrecheckpro" "find-any-file" "flux" "ghostty" "grandperspective" "hiddenbar" "iterm2" "itsycal" "keepassxc" "keepingyouawake" "maccy" "macs-fan-control" "malwarebytes" "memory-cleaner" "microsoft-remote-desktop" "monitorcontrol" "motrix" "mullvadvpn" "nextcloud" "numi" "omnidisksweeper" "openrgb" "ollama" "onyx" "orcaslicer" "owncloud" "parsec" "podman-desktop" "powershell" "raspberry-pi-imager" "raycast" "rectangle" "renamer" "prusaslicer" "qbittorrent" "spacedrive" "stats" "syncthing" "tabby" "tailscale" "teamviewer" "termius" "the-unarchiver" "tiles" "transmission" "utm" "warp" "wireshark" "xdm" "zerotier-one" )
            print_columns "${app_display[@]}"
            print_info "Enter the numbers of the utilities you want to install (separated by space): "
            read -a selected
            install_casks "utilities" "${selected[@]}"
            ;;
        8)
            search_casks
            ;;
        9)
            print_info "Exiting..."
            break
            ;;
    esac
done

print_colored "$GREEN" "Installer completed"
