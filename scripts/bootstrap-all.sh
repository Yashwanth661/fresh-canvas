#!/usr/bin/env bash
# bootstrap-all.sh — Cross-platform bootstrap for dotfiles
set -euo pipefail

# ANSI colors
GREEN='\033[0;32m'; BLUE='\033[0;34m'; YELLOW='\033[1;33m'; RED='\033[0;31m'; NC='\033[0m'

log()    { echo -e "${BLUE}[INFO]${NC} $1"; }
success(){ echo -e "${GREEN}[OK]  ${NC} $1"; }
warn()   { echo -e "${YELLOW}[WARN]${NC} $1"; }
error()  { echo -e "${RED}[ERR] ${NC} $1"; }

# Detect OS type
detect_os(){
  case "$(uname -s)" in
    Linux)
      if   [ -f /etc/fedora-release ]; then echo "fedora"
      elif [ -f /etc/debian_version ];  then echo "debian"
      elif [ -f /etc/arch-release ];    then echo "arch"
      else echo "linux-other"; fi
      ;;
    Darwin)  echo "macos";;
    CYGWIN*|MINGW*|MSYS*) echo "windows";;
    *)        echo "unknown";;
  esac
}

# Install system packages for each OS
install_deps(){
  local os=$1
  log "Installing dependencies for ${os}..."
  case $os in
    fedora)
      sudo dnf install -y \
        git emacs cmake clang llvm-devel make gcc-c++ \
        curl unzip ripgrep fd-find fontconfig
      ;;
    debian)
      sudo apt update
      sudo apt install -y \
        git emacs cmake build-essential \
        curl unzip ripgrep fd-find fontconfig
      ;;
    arch)
      sudo pacman -Syu --noconfirm \
        git emacs cmake gcc make clang \
        curl unzip ripgrep fd fontconfig
      ;;
    macos)
      if ! command -v brew &>/dev/null; then
        error "Homebrew not found—please install from https://brew.sh/"
        exit 1
      fi
      brew update
      brew install git emacs cmake llvm ripgrep fd fontconfig || true
      brew tap homebrew/cask-fonts
      ;;
    windows)
      if ! command -v winget &>/dev/null && ! command -v choco &>/dev/null; then
        error "Neither winget nor choco found—please install one for Windows package management"
        exit 1
      fi
      if command -v winget &>/dev/null; then
        winget install --id Git.Git -e --silent
        winget install --id GNU.Emacs -e --silent
        winget install --id Kitware.CMake -e --silent
        winget install --id Ripgrep.Ripgrep -e --silent
        # fd and fontconfig may not be available; skip
      else
        choco install git emacs cmake ripgrep -y
      fi
      ;;
    *)
      warn "Unknown OS: $os. Please install dependencies manually."
      ;;
  esac
  success "Dependencies installed for ${os}"
}

# Install fonts (calls your existing setup-fonts.sh)
install_fonts(){
  if [ -x "./scripts/setup-fonts.sh" ]; then
    log "Running font installer..."
    ./scripts/setup-fonts.sh
    success "Fonts installed"
  else
    warn "Font installer script not found or not executable"
  fi
}

# Deploy dotfiles via Stow
deploy_dotfiles(){
  log "Deploying dotfiles with Stow..."
  stow -R emacs
  success "Dotfiles deployed"
}

main(){
  local os=$(detect_os)
  log "Detected OS: ${os}"

  install_deps "$os"
  install_fonts
  deploy_dotfiles

  success "Bootstrap complete! Launch Emacs to finish remaining setup."
}

main
