#!/bin/sh

# Color definitions
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
GRAY='\033[0;37m'
RC='\033[0m' # Reset color

# Function to read keyboard input
read_key() {
    dd bs=1 count=1 2>/dev/null | od -An -tx1
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
        key=$(dd bs=3 count=1 2>/dev/null)
        case "$key" in
            $'\x1B\x5B\x41') # Up arrow
                if [ $selected -eq 1 ]; then
                    selected=$total_options
                else
                    selected=$((selected - 1))
                fi
                ;;
            $'\x1B\x5B\x42') # Down arrow
                if [ $selected -eq $total_options ]; then
                    selected=1
                else
                    selected=$((selected + 1))
                fi
                ;;
            $'\x0A'|$'\x0D') # Enter
                stty "$saved_stty"
                return $selected
                ;;
            $'\x03') # Ctrl+C
                stty "$saved_stty"
                cleanup
                ;;
            q|Q) # q or Q
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
