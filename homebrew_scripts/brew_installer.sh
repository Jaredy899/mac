#!/bin/sh

# Source the common script
eval "$(curl -s https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/common_script.sh)"

# Function to display a menu and get the user's choice
show_installer_menu() {
    print_info "Select category:"
    # Initialize selected if not already set
    if [ -z "$selected" ]; then
        selected=1
    fi
    show_menu_item 1 "$selected" "Browsers"
    show_menu_item 2 "$selected" "Communications"
    show_menu_item 3 "$selected" "Development"
    show_menu_item 4 "$selected" "Documents"
    show_menu_item 5 "$selected" "Games"
    show_menu_item 6 "$selected" "Multimedia"
    show_menu_item 7 "$selected" "Utilities"
    show_menu_item 8 "$selected" "Exit"
}

# Function to print apps in columns (POSIX compliant)
print_columns() {
    app_display="$*"
    num_columns=3  # Number of columns to display
    num_apps=$(echo "$app_display" | wc -w)
    rows=$(( (num_apps + num_columns - 1) / num_columns ))  # Calculate number of rows

    i=0
    while [ $i -lt $rows ]; do
        j=0
        while [ $j -lt $num_columns ]; do
            index=$(( i + j * rows ))
            if [ $index -lt "$num_apps" ]; then
                # Get the app name from the list
                app=$(echo "$app_display" | cut -d' ' -f $((index + 1)))
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
}

# Function to install selected casks (POSIX compliant)
install_casks() {
    selected_numbers="$*"
    num_casks=$(echo "$app_casks" | wc -w)

    for number in $selected_numbers; do
        # Check if number is valid
        if echo "$number" | grep -q '^[0-9][0-9]*$' && [ "$number" -ge 1 ] && [ "$number" -le "$num_casks" ]; then
            # Get the app name from the list
            app_name=$(echo "$app_casks" | cut -d' ' -f "$number")
            if brew list --cask "$app_name" > /dev/null 2>&1; then
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
            app_display="Arc Brave GoogleChrome Chromium Edge Firefox Floorp LibreWolf MullvadBrowser ThoriumBrowser TorBrowser Ungoogled Vivaldi Waterfox ZenBrowser"
            app_casks="arc brave-browser google-chrome chromium microsoft-edge firefox floorp Librewolf mullvad-browser alex313031-thorium tor-browser eloston-chromium vivaldi waterfox zen-browser"
            print_columns "$app_display"
            print_info "Enter the numbers of the browsers you want to install (separated by space): "
            read -r selected_input
            install_casks "$selected_input"
            ;;
        2)
            print_info "Communications:"
            app_display="Chatterino Discord Ferdium Jami Element Signal Skype MicrosoftTeams Telegram Thunderbird Viber Zoom Zulip"
            app_casks="chatterino discord ferdium jami element signal skype microsoft-teams telegram thunderbird viber zoom zulip"
            print_columns "$app_display"
            print_info "Enter the numbers of the communication apps you want to install (separated by space): "
            read -r selected_input
            install_casks "$selected_input"
            ;;
        3)
            print_info "Development:"
            app_display="Anaconda CMake DockerDesktop Fork GitButler GitHubDesktop Gitify GitKraken GodotEngine Miniconda OrbStack Postman Pulsar SublimeMerge SublimeText ThonnyPythonIDE Vagrant VSCode VSCodium Wezterm"
            app_casks="anaconda cmake docker fork gitbutler github gitify gitkraken godot miniconda orbstack postman pulsar sublime-merge sublime-text thonny vagrant visual-studio-code vscodium wezterm"
            print_columns "$app_display"
            print_info "Enter the numbers of the development tools you want to install (separated by space): "
            read -r selected_input
            install_casks "$selected_input"
            ;;
        4)
            print_info "Documents:"
            app_display="AdobeAcrobatReader AFFiNE Anki Calibre FoxitPDFEditor FoxitReader Joplin LibreOffice Logseq massCode NAPS2 Obsidian ONLYOFFICE ApacheOpenOffice PDFsamBasic Simplenote Znote Zotero"
            app_casks="adobe-acrobat-reader affine anki calibre foxit-pdf-editor foxitreader joplin libreoffice logseq masscode naps2 obsidian onlyoffice openoffice pdfsam-basic simplenote znote zotero"
            print_columns "$app_display"
            print_info "Enter the numbers of the document apps you want to install (separated by space): "
            read -r selected_input
            install_casks "$selected_input"
            ;;
        5)
            print_info "Games:"
            app_display="ATLauncher CloneHero EAApp EpicGamesLauncher HeroicGamesLauncher Moonlight PSRemotePlay SideQuest Steam XEMU"
            app_casks="atlauncher clone-hero ea epic-games heroic moonlight sony-ps-remote-play sidequest steam xemu"
            print_columns "$app_display"
            print_info "Enter the numbers of the games you want to install (separated by space): "
            read -r selected_input
            install_casks "$selected_input"
            ;;
        6)
            print_info "Multimedia:"
            app_display="Audacity Blender darktable drawio foobar2000 FreeCAD GIMP HandBrake Iina Inkscape JellyfinMediaPlayer JellyfinServer Kdenlive KiCad Krita Mp3tag OBS PlexMediaServer PlexDesktop Shotcut Spotify Tidal VLC XnViewMP Yt-dip"
            app_casks="audacity blender darktable drawio foobar2000 freecad gimp handbrake iina inkscape jellyfin-media-player jellyfin kdenlive kicad krita mp3tag obs plex-media-server plex shotcut spotify tidal vlc xnviewmp yt-dip"
            print_columns "$app_display"
            print_info "Enter the numbers of the multimedia apps you want to install (separated by space): "
            read -r selected_input
            install_casks "$selected_input"
            ;;
        7)
            print_info "Utilities:"
            app_display="1Password AlacrittyTerminal Alfred AnyDesk AppCleaner Barrier Bitwarden coconutBattery CommanderOne CopyQ Cpuinfo CustomShortcuts DevToys Dropbox Duplicati Espanso Etcher EtreCheck FindAnyFile f.lux Ghostty GrandPerspective HiddenBar iTerm2 Itsycal KeePassXC KeepingYouAwake Maccy MacsFanControl Malwarebytes MemoryCleaner MicrosoftRemoteDesktop MonitorControl Motrix MullvadVPN Nextcloud Numi OmniDiskSweeper OpenRBG Ollama onyX OrcaSlicer ownCloud Parsec PodmanDesktop PowerShell RaspberryPiImager Raycast Rectangle Renamer PrusaSlicer qBittorent SpacedriveFileManager Stats Syncthing Tabby.sh Tailscale TeamViewer Termius TheUnarchiver Tiles Transmission UTM Warp Wireshark XtremeDownloadManager ZeroTierOne"
            app_casks="1password alacritty alfred anydesk appcleaner barrier bitwarden coconutbattery commander-one copyq cpuinfo customshortcuts devtoys dropbox duplicati espanso balenaetcher etrecheckpro find-any-file flux ghostty grandperspective hiddenbar iterm2 itsycal keepassxc keepingyouawake maccy macs-fan-control malwarebytes memory-cleaner microsoft-remote-desktop monitorcontrol motrix mullvadvpn nextcloud numi omnidisksweeper openrgb ollama onyx orcaslicer owncloud parsec podman-desktop powershell raspberry-pi-imager raycast rectangle renamer prusaslicer qbittorrent spacedrive stats syncthing tabby tailscale teamviewer termius the-unarchiver tiles transmission utm warp wireshark xdm zerotier-one"
            print_columns "$app_display"
            print_info "Enter the numbers of the utility apps you want to install (separated by space): "
            read -r selected_input
            install_casks "$selected_input"
            ;;
        8)
            print_info "Exiting..."
            break
            ;;
    esac
done

print_success "Installer completed"
