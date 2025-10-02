#!/bin/bash
# System font installation script
set -euo pipefail

detect_pm() {
    if command -v dnf &> /dev/null; then echo "dnf"
    elif command -v apt &> /dev/null; then echo "apt"
    elif command -v pacman &> /dev/null; then echo "pacman"
    elif command -v brew &> /dev/null; then echo "brew"
    else echo "unknown"; fi
}

install_dotfiles() {
    if [ -d ~/dotfiles ]; then
        echo "~/dotfiles already exists, pulling latest changes..."
        cd ~/dotfiles && git pull
    else
        echo "Cloning dotfiles repository..."
        git clone https://github.com/Yashwanth661/fresh-canvas.git ~/dotfiles && cd ~/dotfiles
    fi
    
    echo "Deploying configurations with stow..."
    stow emacs colors hypr rofi swaync waybar wlogout
}

setup_waydroid() {
    sudo waydroid init -s GAPPS
    echo 'none /dev/binderfs binder nofail 0 0' | sudo tee -a /etc/fstab
    sudo mkdir -p /dev/binderfs
    sudo mount -t binder none /dev/binderfs
    sudo systemctl enable --now waydroid-container
    sudo pacman -S waydroid-script-git
    echo "Please do run sudo waydroid-extras, Select Android 13 -> libhoudini, libndk, install these two."
    echo "Make the device trusted by fetch the android ID of waydroid and get it registered. In order to be able to install apps from PlayStore."
}

main() {
    local pm=$(detect_pm)
    
    case $pm in
        "dnf")
            sudo dnf copr enable atim/ubuntu-fonts -y 2>/dev/null || true
            sudo dnf install -y ubuntu-family-fonts jetbrains-mono-fonts liberation-fonts
            ;;
        "apt")
            sudo apt update && sudo apt install -y fonts-ubuntu fonts-jetbrains-mono fonts-liberation
            ;;
        "pacman")
            echo "Installing packages via pacman..."
            sudo pacman -S --noconfirm \
                ttf-ubuntu-font-family \
                ttf-jetbrains-mono \
                ttf-liberation \
                hyprland \
                hyprpaper \
                hyprlock \
                blueman \
                stow \
                waybar \
                rofi-wayland \
                swaync \
                wlogout \
                xdg-desktop-portal-hyprland \
                qt5-wayland \
                qt6-wayland \
		hyprshot \
		brightnessctl \
		pavucontrol \
		waydroid \
		waydroid-helper \
		bitwarden \
		emacs \
		librewolf \
		cmake
            
            echo "Installing AUR packages..."
            yay -S --noconfirm proton-vpn-gtk-app pasystray-wayland
            
            install_dotfiles
	    setup_waydroid
            ;;
        "brew")
            brew tap homebrew/cask-fonts
            brew install --cask font-ubuntu font-jetbrains-mono font-liberation
            ;;
        *)
            echo "Unsupported package manager: $pm"
            exit 1
            ;;
    esac
    
    echo "Refreshing font cache..."
    fc-cache -fv
    echo "Setup completed successfully!"
}

main "$@"

