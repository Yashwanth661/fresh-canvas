#!/usr/bin/env bash
# ubuntu-apps-install.sh — Install messaging apps on Ubuntu
set -euo pipefail

# Minimal logging and helper functions
log()    { echo -e "[INFO]    $1"; }
success(){ echo -e "[SUCCESS] $1"; }
warn()   { echo -e "[WARNING] $1"; }
error()  { echo -e "[ERROR]   $1"; }
command_exists(){ command -v "$1" &>/dev/null; }

log "Installing messaging apps on Ubuntu..."

# 1. Telegram Desktop via Flatpak
{
  log "Installing Telegram Desktop via Snap..."
  sudo snap install telegram-desktop
  success "Telegram Desktop installed"
} || warn "Telegram installation failed"

# 2. WhatsApp via Snap (fallback to Flatpak if not found)
{
  log "Installing WhatsApp via Snap..."
  if snap info whatsapp-linux-app &>/dev/null; then
    sudo snap install whatsapp-linux-app
    success "WhatsApp installed via Snap"
  else
    warn "Snap package 'whatsapp-for-linux' not found; skipping Snap install"
    log "Attempting WhatsApp via Flatpak..."
    flatpak install -y flathub io.github.eneshecan.WhatsAppDesktop && \
      success "WhatsApp installed via Flatpak" || \
      warn "WhatsApp Flatpak install also failed"
  fi
} || warn "WhatsApp install encountered an unexpected error"

# 3.Discord and BetterDiscord via RPM Fusion
{
    log "Installing Discord via Snap"
    sudo snap install discord
    
    log "Installing betterDiscord CLI from PPA"
    sudo add-apt-repository ppa:chronobserver/betterdiscordctl
    sudo apt update

    sudo apt install betterdiscordctl
    
    log "Applying betterDiscord to Discord"
    betterdiscordctl --d-install snap install
} || warn "Discord and BetterDiscord encountered an unexpected error"
