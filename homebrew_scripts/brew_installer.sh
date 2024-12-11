#!/bin/bash

# POSIX-compliant color definitions
ESC=$(printf '\033')
RC="${ESC}[0m"    # Reset
RED="${ESC}[31m"  # Red
GREEN="${ESC}[32m"   # Green
YELLOW="${ESC}[33m"  # Yellow
BLUE="${ESC}[34m"    # Blue
CYAN="${ESC}[36m"    # Cyan

# Function to display a menu and get the user's choice
function show_menu {
    printf "%sSelect category:%s\n" "${CYAN}" "${RC}"
    printf "%s1.%s Browsers\n" "${GREEN}" "${RC}"
    printf "%s2.%s Communications\n" "${GREEN}" "${RC}"
    printf "%s3.%s Development\n" "${GREEN}" "${RC}"
    printf "%s4.%s Documents\n" "${GREEN}" "${RC}"
    printf "%s5.%s Games\n" "${GREEN}" "${RC}"
    printf "%s6.%s Multimedia\n" "${GREEN}" "${RC}"
    printf "%s7.%s Utilities\n" "${GREEN}" "${RC}"
    printf "%s0.%s Exit\n" "${RED}" "${RC}"
    printf "Enter your choice [1-7]: "
    read choice
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
                printf "%s%-3d)%s %-22s" "${GREEN}" "$((index + 1))" "${RC}" "${app_display[$index]}"
            fi
        done
        printf "\n"
    done
}

# Function to install selected casks using normal arrays
function install_casks {
    local selected_numbers=("$@")
    for number in "${selected_numbers[@]}"; do
        if [ "$number" -ge 1 ] && [ "$number" -le ${#app_casks[@]} ]; then
            local app_name="${app_casks[number-1]}"
            if brew list --cask "$app_name" &>/dev/null; then
                printf "%s%s is already installed.%s\n" "${YELLOW}" "$app_name" "${RC}"
            else
                printf "%sInstalling %s...%s\n" "${CYAN}" "$app_name" "${RC}"
                if brew install --cask "$app_name"; then
                    printf "%s%s installed successfully!%s\n" "${GREEN}" "$app_name" "${RC}"
                else
                    printf "%sFailed to install %s%s\n" "${RED}" "$app_name" "${RC}"
                fi
            fi
        else
            printf "%sInvalid selection: %s%s\n" "${RED}" "$number" "${RC}"
        fi
    done
}

# Main script loop
while true; do
    show_menu
    case $choice in
        1)
            printf "%sBrowsers:%s\n" "${CYAN}" "${RC}"
            app_display=("Arc" "Brave" "Google Chrome" "Chromium" "Edge" "Firefox" "Floorp" "LibreWolf" "Mullvad Browser" "Thorium Browser" "Tor Browser" "Ungoogled" "Vivaldi" "Waterfox" "Zen Browser")
            app_casks=("arc" "brave-browser" "google-chrome" "chromium" "microsoft-edge" "firefox" "floorp" "Librewolf" "mullvad-browser" "alex313031-thorium" "tor-browser" "eloston-chromium" "vivaldi" "waterfox" "zen-browser")
            print_columns "${app_display[@]}"
            printf "Enter the numbers of the browsers you want to install (separated by space): "
            read -a selected
            install_casks "${selected[@]}"
            ;;
        2)
            printf "%sCommunications:%s\n" "${CYAN}" "${RC}"
            app_display=("Chatterino" "Discord" "Ferdium" "Jami" "Element" "Signal" "Skype" "Microsoft Teams" "Telegram" "Thunderbird" "Viber" "Zoom" "Zulip")
            app_casks=("chatterino" "discord" "ferdium" "jami" "element" "signal" "skype" "microsoft-teams" "telegram" "thunderbird" "viber" "zoom" "zulip")
            print_columns "${app_display[@]}"
            printf "Enter the numbers of the utilities you want to install (separated by space): "
            read -a selected
            install_casks "${selected[@]}"
            ;;
        3)
            printf "%sDevelopment:%s\n" "${CYAN}" "${RC}"
            app_display=("Anaconda" "CMake" "Docker Desktop" "Fork" "Git Butler" "GitHub Desktop" "Gitify" "GitKraken" "Godot Engine" "Miniconda" "OrbStack" "Postman" "Pulsar" "Sublime Merge" "Sublime Text" "Thonny Python IDE" "Vagrant" "VS Code" "VS Codium" "Wezterm" )
            app_casks=("anaconda" "cmake" "docker" "fork" "gitbutler" "github" "gitify" "gitkraken" "godot" "miniconda" "orbstack" "postman" "pulsar" "sublime-merge" "sublime-text" "thonny" "vagrant" "visual-studio-code" "vscodium" "wezterm" )
            print_columns "${app_display[@]}"
            printf "Enter the numbers of the development tools you want to install (separated by space): "
            read -a selected
            install_casks "${selected[@]}"
            ;;
        4)
            printf "%sDocuments:%s\n" "${CYAN}" "${RC}"
            app_display=("Adobe Acrobat Reader" "AFFiNE" "Anki" "Calibre" "Foxit PDF Editor" "Foxit Reader" "Joplin" "LibreOffice" "Logseq" "massCode" "NAPS2" "Obsidian" "ONLYOFFICE" "Apache OpenOffice" "PDFsam Basic" "Simplenote" "Znote" "Zotero")
            app_casks=("adobe-acrobat-reader" "affine" "anki" "calibre" "foxit-pdf-editor" "foxitreader" "joplin" "libreoffice" "logseq" "masscode" "naps2" "obsidian" "onlyoffice" "openoffice" "pdfsam-basic" "simplenote" "znote" "zotero")
            print_columns "${app_display[@]}"
            printf "Enter the numbers of the multimedia apps you want to install (separated by space): "
            read -a selected
            install_casks "${selected[@]}"
            ;;
        5)
            printf "%sGames:%s\n" "${CYAN}" "${RC}"
            app_display=("ATLauncher" "Clone Hero" "EA App" "Epic Games Launcher" "Heroic Games Launcher" "Moonlight" "PS Remote Play" "SideQuest" "Steam" "XEMU")
            app_casks=("atlauncher" "clone-hero" "ea" "epic-games" "heroic" "moonlight" "sony-ps-remote-play" "sidequest" "steam" "xemu")
            print_columns "${app_display[@]}"
            printf "Enter the numbers of the apps you want to install (separated by space): "
            read -a selected
            install_casks "${selected[@]}"
            ;;
        6)
            printf "%sMultimedia:%s\n" "${CYAN}" "${RC}"
            app_display=("Audacity" "Blender" "darktable" "draw.io" "foobar2000" "FreeCAD" "GIMP" "HandBrake" "Inkscape" "Jellyfin Media Player" "Jellyfin Server" "Kdenlive" "KiCad" "Krita" "Mp3tag" "OBS" "Plex Media Server" "Plex Desktop" "Shotcut" "Spotify" "Tidal" "VLC" "XnViewMP" "Yt-dip")
            app_casks=("audacity" "blender" "darktable" "drawio" "foobar2000" "freecad" "gimp" "handbrake" "inkscape" "jellyfin-media-player" "jellyfin" "kdenlive" "kicad" "krita" "mp3tag" "obs" "plex-media-server" "plex" "shotcut" "spotify" "tidal" "vlc" "xnviewmp" "yt-dip")
            print_columns "${app_display[@]}"
            printf "Enter the numbers of the apps you want to install (separated by space): "
            read -a selected
            install_casks "${selected[@]}"
            ;;
        7)
            printf "%sUtilities:%s\n" "${CYAN}" "${RC}"
            app_display=("1Password" "Alacritty Terminal" "Alfred" "AnyDesk" "AppCleaner" "Barrier" "Bitwarden" "coconutBattery" "Commander One" "CopyQ" "Cpuinfo" "CustomShortcuts" "DevToys" "Dropbox" "Duplicati" "Espanso" "Etcher" "EtreCheck" "Find Any File" "f.lux" "GrandPerspective" "Hidden Bar" "iTerm2" "Itsycal" "KeePassXC" "KeepingYouAwake" "Macs Fan Control" "Malwarebytes" "Memory Cleaner" "Microsoft Remote Desktop" "MonitorControl" "Motrix" "Mullvad VPN" "Nextcloud" "Numi" "OmniDiskSweeper" "OpenRBG" "Ollama" "onyX" "Orca Slicer" "ownCloud" "Parsec" "PowerShell" "Raspberry Pi Imager" "Raycast" "Rectangle" "Renamer" "PrusaSlicer" "qBittorent" "Spacedrive File Manager" "Syncthing" "Tabby.sh" "Tailscale" "TeamViewer" "Termius" "The Unarchiver" "Tiles" "Transmission" "UTM" "Wireshark" "Xtreme Download Manager" "ZeroTier One" )
            app_casks=("1password" "alacritty" "alfred" "anydesk" "appcleaner" "barrier" "bitwarden" "coconutbattery" "commander-one" "copyq" "cpuinfo" "customshortcuts" "devtoys" "dropbox" "duplicati" "espanso" "balenaetcher" "etrecheckpro" "find-any-file" "flux" "grandperspective" "hiddenbar" "iterm2" "itsycal" "keepassxc" "keepingyouawake" "macs-fan-control" "malwarebytes" "memory-cleaner" "microsoft-remote-desktop" "monitorcontrol" "motrix" "mullvadvpn" "nextcloud" "numi" "omnidisksweeper" "openrgb" "ollama" "onyx" "orcaslicer" "owncloud" "parsec" "powershell" "raspberry-pi-imager" "raycast" "rectangle" "renamer" "prusaslicer" "qbittorrent" "spacedrive" "syncthing" "tabby" "tailscale" "teamviewer" "termius" "the-unarchiver" "tiles" "transmission" "utm" "wireshark" "xdm" "zerotier-one" )
            print_columns "${app_display[@]}"
            printf "Enter the numbers of the apps you want to install (separated by space): "
            read -a selected
            install_casks "${selected[@]}"
            ;;
        0)
            printf "%sExiting...%s\n" "${YELLOW}" "${RC}"
            break
            ;;
        *)
            printf "%sInvalid choice. Please try again.%s\n" "${RED}" "${RC}"
            ;;
    esac
done

# Completion message
printf "%s##########################%s\n" "${YELLOW}" "${RC}"
printf "%s##%s                      %s##%s\n" "${YELLOW}" "${RC}" "${YELLOW}" "${RC}"
printf "%s##%s%s Installer completed. %s##%s\n" "${YELLOW}" "${RC}" "${GREEN}" "${YELLOW}" "${RC}"
printf "%s##%s                      %s##%s\n" "${YELLOW}" "${RC}" "${YELLOW}" "${RC}"
printf "%s##########################%s\n" "${YELLOW}" "${RC}"
