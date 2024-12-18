#!/bin/sh

# Source the common script
eval "$(curl -s http://10.24.24.6:3030/Jaredy89/mac/raw/branch/main/common_script.sh)"

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
    show_menu_item 8 "$selected" "Exit"
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

# Function to install selected casks using normal arrays
function install_casks {
    local selected_numbers=("$@")
    for number in "${selected_numbers[@]}"; do
        if [ "$number" -ge 1 ] && [ "$number" -le ${#app_casks[@]} ]; then
            local app_name="${app_casks[number-1]}"
            if brew list --cask "$app_name" &>/dev/null; then
                print_warning "$app_name is already installed."
            else
                print_info "Installing $app_name..."
                if brew install --cask "$app_name"; then
                    print_success "$app_name installed successfully!"
                else
                    print_error "Failed to install $app_name"
                fi
            fi
        else
            print_error "Invalid selection: $number"
        fi
    done
}

# Main script loop
while true; do
    handle_menu_selection 8 "Homebrew Installer" show_installer_menu
    choice=$?

    case $choice in
        1)
            print_info "Browsers:"
            app_display=("Arc" "Brave" "Google Chrome" "Chromium" "Edge" "Firefox" "Floorp" "LibreWolf" "Mullvad Browser" "Thorium Browser" "Tor Browser" "Ungoogled" "Vivaldi" "Waterfox" "Zen Browser")
            app_casks=("arc" "brave-browser" "google-chrome" "chromium" "microsoft-edge" "firefox" "floorp" "Librewolf" "mullvad-browser" "alex313031-thorium" "tor-browser" "eloston-chromium" "vivaldi" "waterfox" "zen-browser")
            print_columns "${app_display[@]}"
            print_info "Enter the numbers of the browsers you want to install (separated by space): "
            read -a selected
            install_casks "${selected[@]}"
            ;;
        2)
            print_info "Communications:"
            app_display=("Chatterino" "Discord" "Ferdium" "Jami" "Element" "Signal" "Skype" "Microsoft Teams" "Telegram" "Thunderbird" "Viber" "Zoom" "Zulip")
            app_casks=("chatterino" "discord" "ferdium" "jami" "element" "signal" "skype" "microsoft-teams" "telegram" "thunderbird" "viber" "zoom" "zulip")
            print_columns "${app_display[@]}"
            print_info "Enter the numbers of the utilities you want to install (separated by space): "
            read -a selected
            install_casks "${selected[@]}"
            ;;
        3)
            print_info "Development:"
            app_display=("Anaconda" "CMake" "Docker Desktop" "Fork" "Git Butler" "GitHub Desktop" "Gitify" "GitKraken" "Godot Engine" "Miniconda" "OrbStack" "Postman" "Pulsar" "Sublime Merge" "Sublime Text" "Thonny Python IDE" "Vagrant" "VS Code" "VS Codium" "Wezterm" )
            app_casks=("anaconda" "cmake" "docker" "fork" "gitbutler" "github" "gitify" "gitkraken" "godot" "miniconda" "orbstack" "postman" "pulsar" "sublime-merge" "sublime-text" "thonny" "vagrant" "visual-studio-code" "vscodium" "wezterm" )
            print_columns "${app_display[@]}"
            print_info "Enter the numbers of the development tools you want to install (separated by space): "
            read -a selected
            install_casks "${selected[@]}"
            ;;
        4)
            print_info "Documents:"
            app_display=("Adobe Acrobat Reader" "AFFiNE" "Anki" "Calibre" "Foxit PDF Editor" "Foxit Reader" "Joplin" "LibreOffice" "Logseq" "massCode" "NAPS2" "Obsidian" "ONLYOFFICE" "Apache OpenOffice" "PDFsam Basic" "Simplenote" "Znote" "Zotero")
            app_casks=("adobe-acrobat-reader" "affine" "anki" "calibre" "foxit-pdf-editor" "foxitreader" "joplin" "libreoffice" "logseq" "masscode" "naps2" "obsidian" "onlyoffice" "openoffice" "pdfsam-basic" "simplenote" "znote" "zotero")
            print_columns "${app_display[@]}"
            print_info "Enter the numbers of the multimedia apps you want to install (separated by space): "
            read -a selected
            install_casks "${selected[@]}"
            ;;
        5)
            print_info "Games:"
            app_display=("ATLauncher" "Clone Hero" "EA App" "Epic Games Launcher" "Heroic Games Launcher" "Moonlight" "PS Remote Play" "SideQuest" "Steam" "XEMU")
            app_casks=("atlauncher" "clone-hero" "ea" "epic-games" "heroic" "moonlight" "sony-ps-remote-play" "sidequest" "steam" "xemu")
            print_columns "${app_display[@]}"
            print_info "Enter the numbers of the apps you want to install (separated by space): "
            read -a selected
            install_casks "${selected[@]}"
            ;;
        6)
            print_info "Multimedia:"
            app_display=("Audacity" "Blender" "darktable" "draw.io" "foobar2000" "FreeCAD" "GIMP" "HandBrake" "Inkscape" "Jellyfin Media Player" "Jellyfin Server" "Kdenlive" "KiCad" "Krita" "Mp3tag" "OBS" "Plex Media Server" "Plex Desktop" "Shotcut" "Spotify" "Tidal" "VLC" "XnViewMP" "Yt-dip")
            app_casks=("audacity" "blender" "darktable" "drawio" "foobar2000" "freecad" "gimp" "handbrake" "inkscape" "jellyfin-media-player" "jellyfin" "kdenlive" "kicad" "krita" "mp3tag" "obs" "plex-media-server" "plex" "shotcut" "spotify" "tidal" "vlc" "xnviewmp" "yt-dip")
            print_columns "${app_display[@]}"
            print_info "Enter the numbers of the apps you want to install (separated by space): "
            read -a selected
            install_casks "${selected[@]}"
            ;;
        7)
            print_info "Utilities:"
            app_display=("1Password" "Alacritty Terminal" "Alfred" "AnyDesk" "AppCleaner" "Barrier" "Bitwarden" "coconutBattery" "Commander One" "CopyQ" "Cpuinfo" "CustomShortcuts" "DevToys" "Dropbox" "Duplicati" "Espanso" "Etcher" "EtreCheck" "Find Any File" "f.lux" "GrandPerspective" "Hidden Bar" "iTerm2" "Itsycal" "KeePassXC" "KeepingYouAwake" "Macs Fan Control" "Malwarebytes" "Memory Cleaner" "Microsoft Remote Desktop" "MonitorControl" "Motrix" "Mullvad VPN" "Nextcloud" "Numi" "OmniDiskSweeper" "OpenRBG" "Ollama" "onyX" "Orca Slicer" "ownCloud" "Parsec" "PowerShell" "Raspberry Pi Imager" "Raycast" "Rectangle" "Renamer" "PrusaSlicer" "qBittorent" "Spacedrive File Manager" "Syncthing" "Tabby.sh" "Tailscale" "TeamViewer" "Termius" "The Unarchiver" "Tiles" "Transmission" "UTM" "Wireshark" "Xtreme Download Manager" "ZeroTier One" )
            app_casks=("1password" "alacritty" "alfred" "anydesk" "appcleaner" "barrier" "bitwarden" "coconutbattery" "commander-one" "copyq" "cpuinfo" "customshortcuts" "devtoys" "dropbox" "duplicati" "espanso" "balenaetcher" "etrecheckpro" "find-any-file" "flux" "grandperspective" "hiddenbar" "iterm2" "itsycal" "keepassxc" "keepingyouawake" "macs-fan-control" "malwarebytes" "memory-cleaner" "microsoft-remote-desktop" "monitorcontrol" "motrix" "mullvadvpn" "nextcloud" "numi" "omnidisksweeper" "openrgb" "ollama" "onyx" "orcaslicer" "owncloud" "parsec" "powershell" "raspberry-pi-imager" "raycast" "rectangle" "renamer" "prusaslicer" "qbittorrent" "spacedrive" "syncthing" "tabby" "tailscale" "teamviewer" "termius" "the-unarchiver" "tiles" "transmission" "utm" "wireshark" "xdm" "zerotier-one" )
            print_columns "${app_display[@]}"
            print_info "Enter the numbers of the apps you want to install (separated by space): "
            read -a selected
            install_casks "${selected[@]}"
            ;;
        8)
            print_info "Exiting..."
            break
            ;;
    esac
done

print_colored "$GREEN" "Installer completed"
