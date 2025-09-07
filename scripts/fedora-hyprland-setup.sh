#!/usr/bin/env bash
# Fedora Hyprland Automation Script
# Author: Generated for fresh-canvas dotfiles management
# Description: Automated installation of Hyprland environment on Fedora with btrfs snapshots and dotfiles management

set -euo pipefail

# ANSI Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Logging functions
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }
log_header() { echo -e "${PURPLE}[SETUP]${NC} $1"; }

# Error handling
handle_error() {
    log_error "An error occurred on line $1"
    exit 1
}
trap 'handle_error $LINENO' ERR

# Check if running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        log_error "This script should not be run as root. Please run as regular user."
        exit 1
    fi
}

# Verify Fedora system
verify_fedora() {
    if [[ ! -f /etc/fedora-release ]]; then
        log_error "This script is designed for Fedora Linux only."
        exit 1
    fi
    
    local fedora_version=$(rpm -E %fedora)
    log_info "Detected Fedora $fedora_version"
    
    if [[ $fedora_version -lt 39 ]]; then
        log_warn "This script is optimized for Fedora 39+. Proceed with caution."
    fi
}

# Update system
update_system() {
    log_header "Updating system packages..."
    sudo dnf update -y
    log_success "System updated successfully"
}

# Enable COPR repository for Hyprland ecosystem
enable_hyprland_copr() {
    log_header "Enabling Hyprland COPR repository..."
    
    # Check if the repository is already enabled
    if dnf repolist | grep -q "copr:copr.fedorainfracloud.org:solopasha:hyprland"; then
        log_info "Hyprland COPR repository already enabled"
    else
        log_info "Enabling solopasha/hyprland COPR repository..."
        sudo dnf copr enable -y solopasha/hyprland
        log_success "Hyprland COPR repository enabled"
    fi
}

# Setup btrfs snapshots with snapper
setup_btrfs_snapshots() {
    log_header "Setting up Btrfs snapshots and quotas..."
    
    # Check if filesystem is btrfs
    local fs_type=$(findmnt -no FSTYPE /)
    if [[ "$fs_type" != "btrfs" ]]; then
        log_warn "Root filesystem is not btrfs. Skipping snapshot setup."
        return 0
    fi
    
    # Install btrfs tools and snapper
    log_info "Installing btrfs-assistant and snapper..."
    sudo dnf install -y btrfs-assistant snapper
    
    # Enable btrfs quotas
    log_info "Enabling btrfs quotas..."
    sudo btrfs quota enable /
    
    # Create snapper configuration for root
    log_info "Creating snapper configuration for root filesystem..."
    if [[ ! -d /.snapshots ]]; then
        sudo snapper -c root create-config /
        log_success "Snapper configuration created for root"
    else
        log_info "Snapper configuration already exists for root"
    fi
    
    # Create initial snapshot
    log_info "Creating initial system snapshot..."
    sudo snapper -c root create -d "Initial system snapshot before Hyprland installation"
    
    # Show current snapshots
    log_info "Current snapshots:"
    sudo snapper -c root list
    
    log_success "Btrfs snapshots configured successfully"
}

# Install NVIDIA drivers if NVIDIA GPU detected
install_nvidia_drivers() {
    log_header "Checking for NVIDIA GPU..."
    
    if lspci | grep -i nvidia > /dev/null; then
        log_info "NVIDIA GPU detected. Installing drivers..."
        
        # Enable RPM Fusion repositories
        log_info "Enabling RPM Fusion repositories..."
        sudo dnf install -y https://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
        sudo dnf install -y https://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
        
        # Install NVIDIA drivers
        log_info "Installing NVIDIA drivers and CUDA support..."
        sudo dnf install -y akmod-nvidia xorg-x11-drv-nvidia-cuda
        
        # Build kernel modules
        log_info "Building NVIDIA kernel modules..."
        sudo akmods
        
        log_success "NVIDIA drivers installed. System reboot will be required."
        echo "NVIDIA_REBOOT_REQUIRED=1" >> /tmp/install_flags
    else
        log_info "No NVIDIA GPU detected. Skipping NVIDIA driver installation."
    fi
}

# Install core Hyprland applications
install_hyprland_applications() {
    log_header "Installing Hyprland and core applications..."
    
    local apps=(
        hyprland
        hyprpaper
        hyprlock
        hyprshot
        thunar
        waybar
        rofi-wayland
        swaync
        pasystray
        pavucontrol
        blueman
        wlogout
        obs-studio
    )
    
    log_info "Installing core applications: ${apps[*]}"
    sudo dnf install -y "${apps[@]}"
    
    log_success "Core Hyprland applications installed"
}

# Install dependencies
install_dependencies() {
    log_header "Installing Hyprland dependencies..."
    
    local deps=(
        xdg-desktop-portal-hyprland
        xdg-desktop-portal-gtk
        kitty
        google-noto-fonts-all
        cliphist
        wl-clipboard
        grim
        slurp
        nm-connection-editor
        network-manager-applet
        libappindicator-gtk3
        polkit-gnome
        tumbler
        thunar-volman
        qt5-qtwayland
        qt6-qtwayland
        xdg-user-dirs
        xdg-utils
    )
    
    log_info "Installing dependencies: ${deps[*]}"
    sudo dnf install -y "${deps[@]}"
    
    log_success "Dependencies installed successfully"
}

# Install optional packages
install_optional_packages() {
    log_header "Installing optional packages..."
    
    local optional=(
        gtk3
        gtk4
        gnome-themes-extra
        pipewire-pulseaudio
        brightnessctl
        playerctl
        swappy
        stow
        git
        emacs
        cmake
        ripgrep
        fd-find
        fontconfig
    )
    
    log_info "Installing optional packages: ${optional[*]}"
    sudo dnf install -y "${optional[@]}"
    
    log_success "Optional packages installed"
}

# Setup dotfiles with stow
setup_dotfiles() {
    log_header "Setting up dotfiles from GitHub repository..."
    
    local dotfiles_dir="$HOME/.dotfiles"
    local repo_url="https://github.com/Yashwanth661/fresh-canvas.git"
    
    # Clone repository if it doesn't exist
    if [[ ! -d "$dotfiles_dir" ]]; then
        log_info "Cloning dotfiles repository..."
        git clone "$repo_url" "$dotfiles_dir"
    else
        log_info "Dotfiles repository already exists. Pulling latest changes..."
        cd "$dotfiles_dir"
        git pull origin master
    fi
    
    cd "$dotfiles_dir"
    
    # Use stow to link emacs configuration
    log_info "Deploying Emacs configuration with stow..."
    stow -R emacs
    
    # Create .config directory if it doesn't exist
    mkdir -p "$HOME/.config"
    
    # Note: Add more stow commands here as you add more configurations to your repo
    # Example: stow -R hyprland (when you add hyprland config to your repo)
    
    log_success "Dotfiles deployed successfully"
}

# Create snapshot after installation
create_post_install_snapshot() {
    log_header "Creating post-installation snapshot..."
    
    local fs_type=$(findmnt -no FSTYPE /)
    if [[ "$fs_type" == "btrfs" ]]; then
        sudo snapper -c root create -d "Post Hyprland installation snapshot - $(date)"
        log_success "Post-installation snapshot created"
        
        log_info "Available snapshots:"
        sudo snapper -c root list
    else
        log_info "Not on btrfs filesystem. Skipping snapshot creation."
    fi
}

# Setup user directories
setup_user_dirs() {
    log_header "Setting up user directories..."
    xdg-user-dirs-update
    log_success "User directories configured"
}

# Display completion message and next steps
show_completion_message() {
    log_header "Installation Complete!"
    
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${GREEN}                    HYPRLAND SETUP COMPLETED                     ${NC}"
    echo -e "${GREEN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo
    echo -e "${CYAN}✓ Hyprland and all applications installed${NC}"
    echo -e "${CYAN}✓ Dependencies and optional packages installed${NC}"
    echo -e "${CYAN}✓ Btrfs snapshots configured (if on btrfs)${NC}"
    echo -e "${CYAN}✓ Dotfiles deployed from your GitHub repository${NC}"
    
    if [[ -f /tmp/install_flags ]] && grep -q "NVIDIA_REBOOT_REQUIRED=1" /tmp/install_flags; then
        echo
        echo -e "${YELLOW}⚠️  NVIDIA drivers were installed. Please reboot your system before using Hyprland.${NC}"
    fi
    
    echo
    echo -e "${BLUE}Next Steps:${NC}"
    echo -e "  1. Log out of your current session"
    echo -e "  2. Select 'Hyprland' from your display manager"
    echo -e "  3. Log in to start using Hyprland"
    echo
    echo -e "${BLUE}Useful Commands:${NC}"
    echo -e "  • Create manual snapshot: ${CYAN}sudo snapper -c root create -d \"Description\"${NC}"
    echo -e "  • List snapshots: ${CYAN}sudo snapper -c root list${NC}"
    echo -e "  • Open Btrfs Assistant: ${CYAN}btrfs-assistant${NC}"
    echo -e "  • Update dotfiles: ${CYAN}cd ~/.dotfiles && git pull && stow -R emacs${NC}"
    echo
    echo -e "${GREEN}Enjoy your new Hyprland setup! 🚀${NC}"
    echo
}

# Main execution function
main() {
    echo -e "${PURPLE}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "              FEDORA HYPRLAND AUTOMATION SCRIPT"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo -e "${NC}"
    
    # Preliminary checks
    check_root
    verify_fedora
    
    # Main installation steps
    update_system
    enable_hyprland_copr
    setup_btrfs_snapshots
    install_nvidia_drivers
    install_hyprland_applications
    install_dependencies
    install_optional_packages
    setup_dotfiles
    setup_user_dirs
    create_post_install_snapshot
    
    # Clean up temporary files
    rm -f /tmp/install_flags
    
    # Show completion message
    show_completion_message
}

# Script entry point
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
