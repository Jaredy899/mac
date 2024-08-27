#!/bin/bash

# Function to display a menu and get the user's choice
function show_menu {
    echo "Select category:"
    echo "1. Browsers"
    echo "2. Communications"
    echo "3. Development"
    echo "4. Document"
    echo "5. Multimedia"
    echo "6. Utilities"
    echo "7. Exit"
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
            app_display=("Arc" "Brave" "Google Chrome" "Chromium" "Edge" "Firefox" "Floorp" "LibreWolf" "Mullvad Browser" "Thorium Browser" "Tor Browser" "Ungoogled" "Vivaldi" "Waterfox")
            app_casks=("arc" "brave-browsers" "google-chrome" "microsoft-edge" "firefox" "floorp" "Librewolf" "mullvad-browser" "alex313031-thorium" "tor-browser" "eloston-chromium" "vivaldi" "waterfox")
            print_columns "${app_display[@]}"
            read -p "Enter the numbers of the browsers you want to install (separated by space): " -a selected
            install_casks "${selected[@]}"
            ;;
        2)
            echo "Communications:"
            app_display=("Chatterino" "Discord" "Ferdium" "Jami" "Element" "Signal" "Skype" "Microsoft Teams" "Telegram" "Thunderbird" "Viber" "Zoom" "Zulip")
            app_casks=("chatterino" "discord" "ferdium" "jami" "element" "signal" "skype" "microsoft-teams" "telegram" "thunderbird" "viber" "zoom" "zulip" "itsycal" "cleanmymac")
            print_columns "${app_display[@]}"
            read -p "Enter the numbers of the utilities you want to install (separated by space): " -a selected
            install_casks "${selected[@]}"
            ;;
        3)
            echo "Development:"
            app_display=("Anaconda" "CMake" "Docker Desktop" "Fork" "Git Butler" "GitHub Desktop" "Gitify" "GitKraken" "Godot Engine" "Miniconda" "OrbStack" "Postman" "Pulsar" "Sublime Merge" "Sublime Text" "Thonny Python IDE" "Vagrant" "VS Code" "VS Codium" "Wezterm" )
            app_casks=("anaconda" "cmake" "docker" "fork" "gitbutler" "github" "gitify" "gitkraken" "godot" "miniconda" "orbstack" "postman" "sublime-merge" "sublime-text" "thonny" "vagrant" "visual-studio-code" "vscodium" "wezterm" )
            print_columns "${app_display[@]}"
            read -p "Enter the numbers of the development tools you want to install (separated by space): " -a selected
            install_casks "${selected[@]}"
            ;;
        4)
            echo "Documents:"
            app_display=("Adobe Acrobat Reader" "AFFiNE" "Anki" "Calibre" "Foxit PDF Editor" " Foxit Reader" "Joplin" "LibreOffice" "Logseq" "massCode" "NAPS2" "Obsidian" "ONLYOFFICE" "Apache OpenOffice" "PDFsam Basic" "Simplenote" "Znote" "Zotero")
            app_casks=("adobe-acrobat-reader" "affine" "anki" "calibre" "foxit-pdf-editor" "foxitreader" "joplin" "libreoffice" "logseq" "masscode" "naps2" "obsidian" "onlyoffice" "openoffice" "pdfsam-basic" "simplenote" "znote" "zotero")
            print_columns "${app_display[@]}"
            read -p "Enter the numbers of the multimedia apps you want to install (separated by space): " -a selected
            install_casks "${selected[@]}"
            ;;
        5)
            echo "Games:"
            app_display=("ATLauncher" "Clone Hero" "EA App" "Epic Games Launcher" "Heroic Games Launcher" "Moonlight" "PS Remote Play" "SideQuest" "Steam" "XEMU")
            app_casks=("atlauncher" "clone-hero" "ea" "epic-games" "heroic" "moonlight" "sony-ps-remote-play" "sidequest" "steam" "xemu")
            print_columns "${app_display[@]}"
            read -p "Enter the numbers of the apps you want to install (separated by space): " -a selected
            install_casks "${selected[@]}"
            ;;
        6)
            echo "Multimedia:"
            app_display=("Audacity" "Blender" "darktable" "foobar2000" "FreeCAD" "GIMP" "HandBrake" "Inkscape" "Jellyfin Media Player" "Jellyfin Server" "Kdenlive" "KiCad" "Krita" "Mp3tag" "OBS" "Plex Media Server" "Plex Desktop" "Shotcut" "Spotify" "Tidal" "VLC" "XnViewMP" "Yt-dip")
            app_casks=("audacity" "blender" "darktable" "foobar2000" "freecad" "gimp" "handbrake" "inkscape" "jellyfin-media-player" "jellyfin" "kdenlive" "kicad" "krita" "mp3tag" "obs" "plex-media-server" "plex" "shotcut" "spotify" "tidal" "vlc" "xnviewmp" "yt-dip")
            print_columns "${app_display[@]}"
            read -p "Enter the numbers of the apps you want to install (separated by space): " -a selected
            install_casks "${selected[@]}"
            ;;
        7)
            echo "Utilities:"
            app_display=("1Password" "Alacritty Terminal" "AnyDesk" "Barrier" "Bitwarden" "CopyQ" "Cpuinfo" "DevToys" "Dropbox" "Duplicati" "Espanso" "Etcher" "f.lux" "iTerm2" "KeePassXC" "Macs Fan Control" "Malwarebytes" "Motrix" "Mullvad VPN" "Nextcloud" "OpenRBG" "Ollama" "Orca Slicer" "ownCloud" "Parsec" "PowerShell" "Raspberry Pi Imager" "Rectangle" "Renamer" "PrusaSlicer" "qBittorent" "Spacedrive File Manager" "Syncthing" "Tabby.sh" "Tailscale" "TeamViewer" "Termius" "Transmission" "Wireshark" "Xtreme Download Manager" "ZeroTier One" )
            app_casks=("1password" "alacritty" "anydesk" "barrier" "bitwarden" "copyq" "cpuinfo" "devtoys" "dropbox" "duplicati" "espanso" "balenaetcher" "flux" "iterm2" "keepassxc" "macs-fan-control" "malwarebytes" "motrix" "mullvadvpn" "nextcloud" "openrgb" "ollama" "orcaslicer" "owncloud" "parsec" "powershell" "raspberry-pi-imager" "rectangle" "renamer" "qbittorrent" "spacedrive" "syncthing" "tabby" "tailscale" "teamviewer" "termius" "transmission" "wireshark" "xdm" "zerotier-one" )
            print_columns "${app_display[@]}"
            read -p "Enter the numbers of the apps you want to install (separated by space): " -a selected
            install_casks "${selected[@]}"
            ;;
        8)
            echo "Exiting..."
            break
            ;;
        *)
            echo "Invalid choice. Please try again."
            ;;
    esac
done

echo "##########################" 
echo "##                      ##"  
echo "## Installer completed. ##"
echo "##                      ##"  
echo "##########################" 