#!/bin/sh

# Source the common script
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ -f "$SCRIPT_DIR/../common_script.sh" ]; then
    . "$SCRIPT_DIR/../common_script.sh"
else
    eval "$(curl -s https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/common_script.sh)"
fi

# Function to uninstall selected casks
uninstall_casks() {
    selected_casks="$*"
    for cask in $selected_casks; do
        print_info "Uninstalling $cask..."
        brew uninstall --cask "$cask"
    done
}

# Function to print apps in columns
print_columns() {
    app_list="$*"
    num_columns=3  # Number of columns to display
    num_apps=$(echo "$app_list" | wc -w)
    rows=$(( (num_apps + num_columns - 1) / num_columns ))  # Calculate number of rows

    i=0
    while [ $i -lt $rows ]; do
        j=0
        while [ $j -lt $num_columns ]; do
            index=$(( i + j * rows ))
            if [ $index -lt "$num_apps" ]; then
                # Get the app name from the list
                app=$(echo "$app_list" | cut -d' ' -f $((index + 1)))
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

# Function to list installed casks and prompt for uninstallation
list_and_uninstall() {
    print_info "Checking installed Homebrew casks..."
    installed_casks=$(brew list --cask)

    if [ -z "$installed_casks" ]; then
        print_warning "No casks are currently installed."
        return
    fi

    print_info "Installed casks:"
    cask_list=""
    for cask in $installed_casks; do
        if [ -n "$cask_list" ]; then
            cask_list="$cask_list $cask"
        else
            cask_list="$cask"
        fi
    done

    print_columns "$cask_list"

    print_info "Enter the numbers of the casks you want to uninstall (separated by space), or press Enter to skip: "
    read -r selected_input
    if [ -n "$selected_input" ]; then
        selected_casks=""
        for number in $selected_input; do
            # Get the cask name by position
            cask=$(echo "$cask_list" | cut -d' ' -f "$number")
            if [ -n "$selected_casks" ]; then
                selected_casks="$selected_casks $cask"
            else
                selected_casks="$cask"
            fi
        done
        uninstall_casks "$selected_casks"
    else
        print_warning "No casks selected for uninstallation."
    fi
}

# Main script
list_and_uninstall

print_success "Uninstaller completed"
