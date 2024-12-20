#!/bin/sh

# Source the common script
eval "$(curl -s https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/dev/common_script.sh)"

# Function to uninstall selected casks
function uninstall_casks {
    local selected_casks=("$@")
    for cask in "${selected_casks[@]}"; do                      
        print_info "Uninstalling $cask..."
        brew uninstall --cask "$cask"
    done
}

# Function to print apps in columns
function print_columns {
    local app_list=("$@")
    local num_columns=3  # Number of columns to display
    local num_apps=${#app_list[@]}
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
                printf "  %s) %-25s" "$num_pad" "${app_list[$index]}"
            fi
        done
        echo
    done
}

# Function to list installed casks and prompt for uninstallation
function list_and_uninstall {
    print_info "Checking installed Homebrew casks..."
    installed_casks=$(brew list --cask)

    if [ -z "$installed_casks" ]; then
        print_warning "No casks are currently installed."
        return
    fi

    print_info "Installed casks:"
    cask_list=()
    for cask in $installed_casks; do
        cask_list+=("$cask")
    done

    print_columns "${cask_list[@]}"

    print_info "Enter the numbers of the casks you want to uninstall (separated by space), or press Enter to skip: "
    read -a selected
    if [ ${#selected[@]} -gt 0 ]; then
        selected_casks=()
        for number in "${selected[@]}"; do
            selected_casks+=("${cask_list[number-1]}")
        done
        uninstall_casks "${selected_casks[@]}"
    else
        print_warning "No casks selected for uninstallation."
    fi
}

# Main script
list_and_uninstall

print_colored "$GREEN" "Uninstaller completed"
