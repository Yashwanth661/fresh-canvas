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
  log "Installing Telegram Desktop via Flatpak..."
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
