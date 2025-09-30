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
            sudo pacman -S --noconfirm ttf-ubuntu-font-family ttf-jetbrains-mono ttf-liberation hyprland hyprpaper hyprlock blueman stow waybar rofi-wayland swaync wlogout xdg-desktop-portal-hyprland qt5-wayland qt6-wayland
	    yay -S proton-vpn-gtk-app
	    git clone https://github.com/Yashwanth661/fresh-canvas.git ~/dotfiles && cd ~/dotfiles
	    stow emacs colors hypr rofi swaync waybar wlogout
            ;;
        "brew")
            brew tap homebrew/cask-fonts
            brew install --cask font-ubuntu font-jetbrains-mono font-liberation
            ;;
    esac
    
    fc-cache -fv
    echo "Fonts installed successfully!"
}

main "$@"
