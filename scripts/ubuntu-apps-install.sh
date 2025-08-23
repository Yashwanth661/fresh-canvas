log "Installing messaging apps..."

# Ensure Flatpak is installed
if ! command_exists flatpak; then
  log "Installing Flatpak..."
  sudo apt update
  sudo apt install -y flatpak
  success "Flatpak installed!"
fi

# Add Flathub repository
if ! flatpak remote-list | grep -q flathub; then
  log "Adding Flathub repository..."
  sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
  success "Flathub added!"
fi

# Telegram Desktop via Flatpak
log "Installing Telegram Desktop..."
flatpak install -y flathub org.telegram.desktop
success "Telegram Desktop installed!"

# WhatsApp Desktop via Flatpak
log "Installing WhatsApp Desktop..."
flatpak install -y flathub io.github.eneshecan.WhatsAppDesktop
success "WhatsApp Desktop installed!"

# Discord via official .deb
log "Installing Discord (.deb)..."
wget -O /tmp/discord.deb "https://dl.discordapp.net/apps/linux/0.0.28/discord-0.0.28.deb"
sudo apt update
sudo apt install -y libglib2.0-0 libgconf-2-4 libgtk2.0-0 libnotify4 \
                    libxtst6 libxss1 libnss3 libasound2 libcap2 \
                    libxrandr2 libappindicator1 libdbusmenu-glib4 \
                    libdbusmenu-gtk4 libgdk-pixbuf2.0-0
sudo dpkg -i /tmp/discord.deb || sudo apt -f install -y
success "Discord installed!"

# BetterDiscord (unchanged)
log "Installing BetterDiscord..."
if ! command_exists npm; then
  sudo apt install -y nodejs npm
fi
git clone https://github.com/BetterDiscord/installer.git ~/betterdiscord-installer
cd ~/betterdiscord-installer
npm install --silent
sudo node index.js install
cd ~
success "BetterDiscord installed!"

success "All messaging apps installed!"
