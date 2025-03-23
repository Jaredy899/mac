# Mac Setup Automation Suite

A comprehensive set of scripts to automate setting up and configuring macOS environments with custom preferences, applications, terminal configurations, and more.

## ✨ Features

- **Homebrew Management**: Install, update, uninstall, and backup applications
- **Dock Customization**: Easily add or remove icons from your Mac Dock
- **Terminal Enhancement**: Configure zsh with modern tools and beautiful themes
- **macOS Settings**: Apply optimal system settings for development
- **SSH Key Setup**: Automate SSH key generation and GitHub integration

## 🎯 What's New

- **Silent Installation Mode**: Automate setup without user interaction
- **Enhanced Error Handling**: All scripts now have improved error handling and validation
- **Parallel App Installation**: Install multiple applications simultaneously (when GNU parallel is available)
- **Backup & Restore**: Generate scripts to replicate your Homebrew setup on other Macs
- **Search Capability**: Find and install any Homebrew package with the new search feature
- **Homebrew Health Checks**: Diagnose and fix Homebrew installation issues
- **Default App Installations**: Quick setup with common default applications

## 💡 Quick Start

To get started, open your terminal and run:

```sh
sh <(curl -fsSL jaredcervantes.com/mac)
```

## 🚀 Manual Installation

If you prefer to clone the repository:

1. Clone this repository:
   ```sh
   git clone https://github.com/Jaredy899/mac.git
   ```

2. Navigate to the directory:
   ```sh
   cd mac
   ```

3. Run the setup script (interactive mode):
   ```sh
   ./setup.sh
   ```

## 🤖 Silent Installation

For automated/unattended installation, use the silent mode with component selection:

```sh
# Install everything silently
./setup.sh --silent --components all

# Install only specific components
./setup.sh --silent --components homebrew,zsh,settings
```

Available components:
- `homebrew`: Install default Homebrew packages
- `dock`: Configure the macOS Dock with default apps
- `zsh`: Set up ZSH with custom configuration
- `settings`: Apply optimal system settings
- `ssh`: Generate and configure SSH keys
- `all`: Install all components

## 🧩 Components

### Homebrew Scripts

- **brew_manager.sh**: Central manager for all Homebrew operations
- **brew_installer.sh**: Install Homebrew packages and applications with categories
- **brew_updater.sh**: Update Homebrew and all installed packages
- **brew_uninstaller.sh**: Remove unwanted Homebrew packages
- **brew_backup.sh**: Backup and restore your Homebrew environment across machines

### Dock Scripts

- **dock_manager.sh**: Central manager for Dock operations
- **icon_add.sh**: Add applications to the Dock
- **icon_remove.sh**: Remove items from the Dock

### myZSH Configuration

- **myzsh.sh**: Set up and configure zsh with optimal settings
- **starship.toml**: Configuration for the Starship prompt
- **.zshrc**: Custom zsh configuration
- **config.jsonc**: Configuration for fastfetch

## 🔧 Customization

You can customize the installation by editing the following files:

- **homebrew_scripts/brew_installer.sh**: Modify the list of applications to install
- **myzsh/.zshrc**: Customize your shell aliases and functions
- **settings.sh**: Adjust macOS system preferences
- **common_script.sh**: Modify shared functions and utilities

## 🚨 Troubleshooting

If you encounter issues:

1. Check the terminal output for error messages
2. Run the "Check Homebrew Health" option in the Homebrew Manager
3. Ensure your macOS is compatible (10.15 Catalina or newer recommended)
4. Verify you have admin privileges and internet connectivity

## 📋 Requirements

- macOS (tested on Monterey, Big Sur, and Ventura)
- Internet connection
- Admin privileges

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Homebrew](https://brew.sh/) - The missing package manager for macOS
- [Starship](https://starship.rs/) - The minimal, blazing-fast, and infinitely customizable prompt
- [Oh My Zsh](https://ohmyz.sh/) - Framework for managing Zsh configuration
