#!/bin/sh

# common_script.sh - Shared functions and utilities for Mac setup scripts
# Author: Jared Cervantes
# Version: 1.1.0

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
RC='\033[0m' # Reset color

# Check for required tools and utilities
check_dependencies() {
    local missing_deps=0
    
    for cmd in "$@"; do
        if ! command -v "$cmd" &> /dev/null; then
            print_error "Required command not found: $cmd"
            missing_deps=1
        fi
    done
    
    if [ "$missing_deps" -eq 1 ]; then
        print_error "Please install missing dependencies and try again."
        return 1
    fi
    
    return 0
}

# Basic dependencies check
check_dependencies curl grep || {
    echo -e "${RED}ERROR: Missing basic dependencies. Please install curl and grep before proceeding.${RC}"
    exit 1
}

# Function to read keyboard input with timeout
read_key_with_timeout() {
    local timeout=$1
    
    # Save current terminal settings
    saved_stty=$(stty -g)
    
    # Set terminal to raw mode
    stty raw -echo
    
    # Read a single keystroke with timeout
    if [ -n "$timeout" ]; then
        # With timeout (only on systems that support it)
        if command -v read &> /dev/null && [ "$(uname)" = "Darwin" ]; then
            # macOS read doesn't support -t, use perl workaround
            key=$(perl -e 'use Time::HiRes qw(time); $start=time(); $timeout='$timeout'; $char=""; 
                $stdin = "STDIN"; 
                $rin = ""; vec($rin, fileno($stdin), 1) = 1;
                if (select($rin, undef, undef, $timeout)) {
                    sysread($stdin, $char, 1);
                }
                print $char;')
        else
            # Fallback with dd
            key=$(dd bs=1 count=1 timeout=$timeout 2>/dev/null | od -An -tx1)
        fi
    else
        # Without timeout
        key=$(dd bs=1 count=1 2>/dev/null | od -An -tx1)
    fi
    
    # Restore terminal settings
    stty "$saved_stty"
    
    echo "$key"
}

# Function to read keyboard input
read_key() {
    read_key_with_timeout ""
}

# Function to show menu item
show_menu_item() {
    if [ "$selected" -eq "$1" ]; then
        printf "  ${GREEN}→ %s${RC}\n" "$3"
    else
        printf "    %s\n" "$3"
    fi
}

# Function to handle menu selection
handle_menu_selection() {
    selected=1
    total_options=$1
    saved_stty=$(stty -g)

    cleanup() {
        stty "$saved_stty"
        printf "\n${GREEN}Script terminated.${RC}\n"
        exit 0
    }

    trap cleanup INT

    while true; do
        # Clear screen and show header
        printf "\033[2J\033[H"
        print_colored "$CYAN" "$2"
        echo

        # Call the function that displays menu items
        $3

        printf "\n${MAGENTA}Use arrow keys to navigate, Enter to select, 'q' to exit${RC}\n"

        # Read keyboard input
        stty raw -echo
        key=$(dd bs=3 count=1 2>/dev/null | hexdump -v -e '/1 "%02X"' 2>/dev/null)
        
        # Handle key codes
        case "$key" in
            "1B5B41") # Up arrow
                if [ $selected -eq 1 ]; then
                    selected=$total_options
                else
                    selected=$((selected - 1))
                fi
                ;;
            "1B5B42") # Down arrow
                if [ $selected -eq $total_options ]; then
                    selected=1
                else
                    selected=$((selected + 1))
                fi
                ;;
            "0A"|"0D") # Enter
                stty "$saved_stty"
                return $selected
                ;;
            "03") # Ctrl+C
                stty "$saved_stty"
                cleanup
                ;;
            "71"|"51") # q or Q
                stty "$saved_stty"
                cleanup
                ;;
        esac
        stty "$saved_stty"
    done
}

# Function to print colored text
print_colored() {
    local color=$1
    local message=$2
    printf "${color}%s${RC}\n" "$message"
}

# Function to print error message
print_error() {
    print_colored "$RED" "ERROR: $1"
}

# Function to print success message
print_success() {
    print_colored "$GREEN" "SUCCESS: $1"
}

# Function to print warning message
print_warning() {
    print_colored "$YELLOW" "WARNING: $1"
}

# Function to print info message
print_info() {
    print_colored "$BLUE" "INFO: $1"
}

# Function to prompt user for yes/no confirmation
confirm() {
    local prompt="$1"
    local default="${2:-y}"
    
    while true; do
        if [ "$default" = "y" ]; then
            printf "${YELLOW}%s [Y/n]: ${RC}" "$prompt"
        else
            printf "${YELLOW}%s [y/N]: ${RC}" "$prompt"
        fi
        
        local answer
        read answer
        
        # Convert to lowercase
        answer=$(echo "$answer" | tr '[:upper:]' '[:lower:]')
        
        if [ -z "$answer" ]; then
            answer=$default
        fi
        
        case "$answer" in
            y|yes)
                return 0
                ;;
            n|no)
                return 1
                ;;
            *)
                echo "Please answer yes or no."
                ;;
        esac
    done
}

# Function to check if running on supported OS
check_os() {
    if [ "$(uname)" != "Darwin" ]; then
        print_error "This script is designed to run on macOS only."
        return 1
    fi
    
    local version_str=$(sw_vers -productVersion)
    local major_version=$(echo "$version_str" | cut -d. -f1)
    local minor_version=$(echo "$version_str" | cut -d. -f2)
    
    if [ "$major_version" -lt 10 ] || ([ "$major_version" -eq 10 ] && [ "$minor_version" -lt 15 ]); then
        print_warning "This script is tested on macOS 10.15 Catalina and later."
        if ! confirm "Continue anyway?"; then
            return 1
        fi
    fi
    
    return 0
}

# Function to check for root/sudo access
check_sudo() {
    if [ "$EUID" -eq 0 ]; then
        print_error "This script should not be run as root or with sudo."
        return 1
    fi
    
    print_info "Checking sudo access..."
    if ! sudo -n true 2>/dev/null; then
        print_warning "This script requires sudo access for some operations."
        if ! sudo true; then
            print_error "Failed to obtain sudo access."
            return 1
        fi
    fi
    
    return 0
}

# Function to check internet connectivity
check_internet() {
    print_info "Checking internet connectivity..."
    
    if ping -c 1 -W 3 github.com >/dev/null 2>&1; then
        print_success "Internet connection is available."
        return 0
    else
        print_error "No internet connection detected."
        return 1
    fi
}

# Function to backup a file
backup_file() {
    local file="$1"
    local backup="${file}.backup-$(date +%Y%m%d-%H%M%S)"
    
    if [ -f "$file" ]; then
        print_info "Backing up $file to $backup"
        if cp "$file" "$backup"; then
            print_success "Backup created at $backup"
            return 0
        else
            print_error "Failed to create backup of $file"
            return 1
        fi
    else
        print_warning "File $file does not exist, no backup needed"
        return 0
    fi
}

# Check OS compatibility
check_os || {
    print_error "OS compatibility check failed."
    exit 1
}

# Debug information
if [ -n "$DEBUG" ]; then
    print_info "Running on macOS $(sw_vers -productVersion)"
    print_info "Script directory: $SCRIPT_DIR"
fi 
