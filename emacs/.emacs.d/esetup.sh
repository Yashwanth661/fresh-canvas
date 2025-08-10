#!/bin/bash

# Clone Elpaca
if [ ! -d "$HOME/.emacs.d/elpaca" ]; then
    git clone https://github.com/progfolio/elpaca.git "$HOME/.emacs.d/elpaca/repos/elpaca"
fi

# Check if Emacs is available; if not, instruct the user to install it
if ! command -v emacs &> /dev/null; then
    echo "Emacs is not installed. Please install Emacs to continue."
    exit 1
fi

# Run Emacs in batch mode to set up Elpaca and load the init file
emacs --batch -l "$HOME/.emacs.d/init.el"

# Provide feedback to the user
echo "Setup complete!"

