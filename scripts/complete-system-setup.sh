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
		pavucontrol
            
            echo "Installing AUR packages..."
            if command -v yay &> /dev/null; then
                yay -S --noconfirm proton-vpn-gtk-app
            else
                echo "Warning: yay not found, skipping ProtonVPN installation"
                echo "Install yay manually and run: yay -S proton-vpn-gtk-app"
            fi
            
            install_dotfiles
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

