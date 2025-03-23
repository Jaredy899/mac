#!/bin/sh

# Source the common script
eval "$(curl -s https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/common_script.sh)"

# Check for Homebrew
if ! command -v brew &>/dev/null; then
    print_error "Homebrew is not installed. Please install Homebrew first."
    return 1 2>/dev/null || exit 1
fi

# Function to generate backup script
generate_backup() {
    local output_file="$HOME/homebrew_backup_$(date +%Y%m%d_%H%M%S).sh"
    
    print_info "Generating Homebrew backup script at: $output_file"
    
    # Create backup script header
    cat > "$output_file" << 'EOF'
#!/bin/bash

# Homebrew Backup Restore Script
# Generated on $(date)
# This script will restore your Homebrew packages, casks, and taps

# Script colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Check if Homebrew is installed
if ! command -v brew &>/dev/null; then
    echo -e "${RED}Homebrew is not installed. Please install Homebrew first.${NC}"
    echo -e "${BLUE}Run this command to install Homebrew:${NC}"
    echo '/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
    exit 1
fi

echo -e "${GREEN}=== Restoring Homebrew configuration ===${NC}"

# First update Homebrew
echo -e "${BLUE}Updating Homebrew...${NC}"
brew update

EOF
    
    # Add taps - safer approach that handles spaces
    echo -e "\n# Restore taps" >> "$output_file"
    print_info "Processing taps..."
    brew tap | while IFS= read -r tap; do
        echo "echo -e \"${BLUE}Tapping $tap...${NC}\"" >> "$output_file"
        echo "brew tap \"$tap\"" >> "$output_file"
    done
    
    # Add formulae (CLI tools) - safer approach that handles spaces
    echo -e "\n# Restore formulae (CLI tools)" >> "$output_file"
    echo "echo -e \"${GREEN}=== Installing CLI tools ===${NC}\"" >> "$output_file"
    
    print_info "Processing formulae..."
    brew list --formula | while IFS= read -r formula; do
        # Skip Homebrew dependencies to avoid conflicts
        if [[ "$formula" != "openssl@"* && "$formula" != "libressl" && "$formula" != "gcc" && "$formula" != "python@"* ]]; then
            echo "echo -e \"${BLUE}Installing $formula...${NC}\"" >> "$output_file"
            echo "brew install \"$formula\" || echo -e \"${YELLOW}Failed to install $formula${NC}\"" >> "$output_file"
        fi
    done
    
    # Add casks (GUI applications) - safer approach that handles spaces
    echo -e "\n# Restore casks (GUI applications)" >> "$output_file"
    echo "echo -e \"${GREEN}=== Installing GUI applications ===${NC}\"" >> "$output_file"
    
    print_info "Processing casks..."
    brew list --cask | while IFS= read -r cask; do
        echo "echo -e \"${BLUE}Installing $cask...${NC}\"" >> "$output_file"
        echo "brew install --cask \"$cask\" || echo -e \"${YELLOW}Failed to install $cask${NC}\"" >> "$output_file"
    done
    
    # Add script footer
    cat >> "$output_file" << 'EOF'

echo -e "${GREEN}=== Cleanup ===${NC}"
brew cleanup

echo -e "${GREEN}=== Homebrew restore completed ===${NC}"
echo -e "${BLUE}Installed formulae:${NC} $(brew list --formula | wc -l | xargs)"
echo -e "${BLUE}Installed casks:${NC} $(brew list --cask | wc -l | xargs)"
EOF
    
    # Make executable
    chmod +x "$output_file"
    
    print_success "Backup script generated successfully at: $output_file"
    print_info "You can copy this script to another Mac and run it to restore your Homebrew setup."
    
    # Force return to menu
    return 0
}

# Function to generate simple list files
generate_lists() {
    local base_dir="$HOME/homebrew_lists_$(date +%Y%m%d_%H%M%S)"
    mkdir -p "$base_dir"
    
    print_info "Generating Homebrew package lists in: $base_dir"
    
    # Generate list of taps
    brew tap > "$base_dir/taps.txt"
    
    # Generate list of formulae
    brew list --formula > "$base_dir/formulae.txt"
    
    # Generate list of casks
    brew list --cask > "$base_dir/casks.txt"
    
    # Generate CSV with more details - header line
    echo "Type,Name,Version,Installed On" > "$base_dir/all_packages.csv"
    
    # Process formulae - safer approach to handle packages with spaces
    print_info "Processing formulae..."
    brew list --formula | while IFS= read -r formula; do
        if [ -n "$formula" ]; then
            version=$(brew list --versions "$formula" | awk '{print $2}')
            install_date=$(date -r "$(brew --prefix)/Cellar/$formula" "+%Y-%m-%d" 2>/dev/null || echo "Unknown")
            echo "formula,$formula,$version,$install_date" >> "$base_dir/all_packages.csv"
        fi
    done
    
    # Process casks - safer approach to handle packages with spaces
    print_info "Processing casks..."
    brew list --cask | while IFS= read -r cask; do
        if [ -n "$cask" ]; then
            version=$(brew list --versions --cask "$cask" | awk '{print $2}')
            install_date=$(date -r "$(brew --prefix)/Caskroom/$cask" "+%Y-%m-%d" 2>/dev/null || echo "Unknown")
            echo "cask,$cask,$version,$install_date" >> "$base_dir/all_packages.csv"
        fi
    done
    
    print_success "Package lists generated successfully in: $base_dir"
    print_info "You can use these lists for reference or backup purposes."
    
    # Force return to menu
    return 0
}

# Function to restore from lists
restore_from_list() {
    print_info "Select a list file containing packages to restore:"
    print_info "File should contain one package name per line."
    
    read -p "Enter path to list file: " list_file
    
    if [ ! -f "$list_file" ]; then
        print_error "File not found: $list_file"
        return 1
    fi
    
    print_info "What type of packages does this list contain?"
    print_info "1) Formula (CLI tools)"
    print_info "2) Casks (GUI applications)"
    read -p "Enter choice (1 or 2): " list_type
    
    case $list_type in
        1)
            print_info "Installing formulae from list..."
            # Process each line directly with proper handling of spaces
            while IFS= read -r formula || [ -n "$formula" ]; do
                if [ -n "$formula" ]; then
                    print_info "Installing $formula..."
                    if brew list --formula "$formula" &>/dev/null; then
                        print_warning "$formula is already installed."
                    else
                        if brew install "$formula"; then
                            print_success "$formula installed successfully!"
                        else
                            print_error "Failed to install $formula"
                        fi
                    fi
                fi
            done < "$list_file"
            ;;
        2)
            print_info "Installing casks from list..."
            # Process each line directly with proper handling of spaces
            while IFS= read -r cask || [ -n "$cask" ]; do
                if [ -n "$cask" ]; then
                    print_info "Installing $cask..."
                    if brew list --cask "$cask" &>/dev/null; then
                        print_warning "$cask is already installed."
                    else
                        if brew install --cask "$cask"; then
                            print_success "$cask installed successfully!"
                        else
                            print_error "Failed to install $cask"
                        fi
                    fi
                fi
            done < "$list_file"
            ;;
        *)
            print_error "Invalid choice."
            return 1
            ;;
    esac
    
    print_success "Restore from list completed."
    
    # Force return to menu
    return 0
}

# Function to show menu
show_backup_menu() {
    show_menu_item 1 "$selected" "Generate backup script (restore everything)"
    show_menu_item 2 "$selected" "Generate package lists (for reference)"
    show_menu_item 3 "$selected" "Restore from list file"
    show_menu_item 4 "$selected" "Return to main menu"
}

# Main functionality
backup_main() {
    # Main menu loop
    while true; do
        handle_menu_selection 4 "Homebrew Backup and Restore" show_backup_menu
        choice=$?
        
        case $choice in
            1)
                generate_backup
                ;;
            2)
                generate_lists
                ;;
            3)
                restore_from_list
                ;;
            4)
                print_info "Returning to main menu."
                return 0
                ;;
        esac
    done
}

# Check if the script is being sourced or executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    # Script is being executed directly
    backup_main
    exit $?
else
    # Script is being sourced
    backup_main
    return $?
fi 