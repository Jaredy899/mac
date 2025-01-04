#!/bin/sh

# Source the common script
eval "$(curl -s https://raw.githubusercontent.com/Jaredy899/mac/refs/heads/main/common_script.sh)"

# Variables
SSH_DIR="$HOME/.ssh"
AUTHORIZED_KEYS="$SSH_DIR/authorized_keys"
SSHD_CONFIG="/etc/ssh/sshd_config"

# Function to configure sshd
configure_sshd() {
    # Check if we need sudo
    if [ "$(id -u)" -ne 0 ]; then
        print_info "Requesting sudo privileges to configure sshd..."
        # Only run the sshd configuration part with sudo
        sudo sh -c '
            SSHD_CONFIG="/etc/ssh/sshd_config"
            if [ -f "$SSHD_CONFIG" ]; then
                # Ensure PubkeyAuthentication is enabled
                if grep -q "^PubkeyAuthentication" "$SSHD_CONFIG"; then
                    sed -i "s/^PubkeyAuthentication.*/PubkeyAuthentication yes/" "$SSHD_CONFIG"
                else
                    echo "PubkeyAuthentication yes" >> "$SSHD_CONFIG"
                fi
                
                # Ensure AuthorizedKeysFile is set correctly
                if grep -q "^AuthorizedKeysFile" "$SSHD_CONFIG"; then
                    sed -i "s/^AuthorizedKeysFile.*/AuthorizedKeysFile .ssh\/authorized_keys/" "$SSHD_CONFIG"
                else
                    echo "AuthorizedKeysFile .ssh/authorized_keys" >> "$SSHD_CONFIG"
                fi

                echo "SSH daemon configured to accept public key authentication."
                
                # Restart SSH daemon to apply changes
                if command -v systemctl >/dev/null 2>&1; then
                    systemctl restart sshd
                elif command -v service >/dev/null 2>&1; then
                    service sshd restart
                else
                    echo "Could not restart SSH daemon automatically. Please restart it manually."
                fi
            else
                echo "SSH daemon config file not found at $SSHD_CONFIG"
                exit 1
            fi
        '
        return $?
    fi
}

# Function to ensure directory and file exist with correct permissions
ensure_ssh_setup() {
    if [ ! -d "$SSH_DIR" ]; then
        mkdir -p "$SSH_DIR"
        chmod 700 "$SSH_DIR"
        print_success "Created $SSH_DIR and set permissions to 700."
    else
        print_warning "$SSH_DIR already exists."
    fi

    if [ ! -f "$AUTHORIZED_KEYS" ]; then
        touch "$AUTHORIZED_KEYS"
        chmod 600 "$AUTHORIZED_KEYS"
        print_success "Created $AUTHORIZED_KEYS and set permissions to 600."
    else
        print_warning "$AUTHORIZED_KEYS already exists."
    fi

    # Configure sshd separately
    configure_sshd
}

# Function to import SSH keys from GitHub
import_ssh_keys() {
    print_info "Enter the GitHub username: "
    read -r github_user

    ssh_keys_url="https://github.com/$github_user.keys"
    keys=$(curl -s "$ssh_keys_url")

    if [ -z "$keys" ]; then
        print_error "No SSH keys found for GitHub user: $github_user"
    else
        print_success "SSH keys found for $github_user:"
        printf "%s\n" "$keys"
        print_info "Do you want to import these keys? [Y/n]: "
        read -r confirm

        case "$confirm" in
            [Nn]*)
                print_warning "SSH key import cancelled."
                ;;
            *)
                printf "%s\n" "$keys" >> "$AUTHORIZED_KEYS"
                chmod 600 "$AUTHORIZED_KEYS"
                print_success "SSH keys imported successfully!"
                ;;
        esac
    fi
}

# Function to add a manually entered public key
add_manual_key() {
    print_info "Enter the public key to add: "
    read -r PUBLIC_KEY

    if grep -q "$PUBLIC_KEY" "$AUTHORIZED_KEYS"; then
        print_warning "Public key already exists in $AUTHORIZED_KEYS."
    else
        printf "%s\n" "$PUBLIC_KEY" >> "$AUTHORIZED_KEYS"
        chmod 600 "$AUTHORIZED_KEYS"
        print_success "Public key added to $AUTHORIZED_KEYS."
    fi
}

# Function to show SSH key menu
show_ssh_menu() {
    show_menu_item 1 "$selected" "Import from GitHub"
    show_menu_item 2 "$selected" "Enter your own public key"
}

# Main script
ensure_ssh_setup

# Handle menu selection
handle_menu_selection 2 "Select SSH key option" show_ssh_menu
choice=$?

case $choice in
    1)
        import_ssh_keys
        ;;
    2)
        add_manual_key
        ;;
esac

print_colored "$GREEN" "SSH key setup completed"
