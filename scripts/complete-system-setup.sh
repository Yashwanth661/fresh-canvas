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

install_telegram_downloader() {
    wget https://github.com/iyear/tdl/releases/latest/download/tdl_Linux_64bit.tar.gz
    tar -xzf tdl_Linux_64bit.tar.gz
    sudo mv tdl /usr/local/bin/
    rm -rf tdl_Linux_64bit.tar.gz
}

install_megacmd() {
    wget https://mega.nz/linux/repo/Arch_Extra/x86_64/megacmd-x86_64.pkg.tar.zst && sudo pacman -U "$PWD/megacmd-x86_64.pkg.tar.zst"
}

install_xdmAndSoulseekQt() {
    # Download latest XDM
    wget https://github.com/subhra74/xdm/releases/download/7.2.11/xdm-setup-7.2.11.tar.xz
    tar -xvf xdm-setup-7.2.11.tar.xz
    cd xdm*
    sudo ./install.sh
    paru -S soulseekqt
}

create_dirs() {
	mkdir ~/Downloads/Upload_Section/{CompletedTorrentDownloads,English_Movies,Hindi_Movies,Tamil_Movies,Malayalam_Movies,Japanese_Movies,World_Cinema,Animated_Movies,Anime,Anime_Movies,Cartoons,TV_Shows,World_TV,Manga,YouTube,Documentaries}
	sudo systemctl enable --now tailscaled
	mkdir ~/.local/bin
	mkdir ~/.local/bin/rclone-logs
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

pipx_install() {
	pipx install tidal-dl-ng
}

enable_openssh() {
	sudo systemctl start sshd
	sudo systemctl enable sshd
}

cargo_installations() {
	cargo install magnetfinder
}

iptables_part(){
    sudo iptables -I OUTPUT -p udp --dport 53 -m string --hex-string "|03|www|09|jetbrains|03|com|" --algo bm -j DROP
    sudo iptables -I OUTPUT -p udp --dport 53 -m string --hex-string "|07|account|09|jetbrains|03|com|" --algo bm -j DROP

    sudo ip6tables -I OUTPUT -p udp --dport 53 -m string --hex-string "|03|www|09|jetbrains|03|com|" --algo bm -j DROP
    sudo ip6tables -I OUTPUT -p udp --dport 53 -m string --hex-string "|07|account|09|jetbrains|03|com|" --algo bm -j DROP

    sudo iptables-save | sudo tee /etc/iptables/iptables.rules > /dev/null
    sudo ip6tables-save | sudo tee /etc/iptables/ip6tables.rules > /dev/null
    
    sudo systemctl enable iptables.service
    sudo systemctl enable ip6tables.service
    
    sudo systemctl start iptables.service
    sudo systemctl start ip6tables.service
    
    sudo systemctl status iptables.service
    sudo systemctl status ip6tables.service
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
		cmake \
		obs-studio \
		ffmpeg \
		rclone \
		tailscale \
		claude-code \
		ripgrep \
		git \
		qbittorrent \
		stremio \
		vlc \
		imagemagick \
		kcalc \
		python-pipx \
		openssh \
		rtorrent \
		tmux \
		gdb \
		# Python Tool to Open Excels in terminal
	    	visidata \
		# Dep for above tool
		python-openpyxl \
		# Cargo and Rust
		cargo \
		rust
            echo "Installing AUR packages..."
            yay -S --noconfirm proton-vpn-gtk-app pasystray-wayland plex-desktop plexamp-appimage yt-dlp vlc-plugins-all qimgv streamrip
            
            install_dotfiles
	    setup_waydroid
            install_telegram_downloader
	    install_megacmd
	    create_dirs
	    install_xdmAndSoulseekQt
	    pipx_install
	    cargo_installations
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
    echo "Make sure that you register the waydroid device as a a trsuted device and then login to tdl (telegram downloader) and have a BLAST!!!!!!!!"
}

main "$@"

