#!/usr/bin/env bash

set -euo pipefail

# ===============================================================================
# Qt 6 installation script
# ===============================================================================

STATE_DIR="$HOME/.local/state/dotfiles"

QT6_BASE_PACKAGES=(
  qt6-base-dev 
  qt6-tools-dev 
  qt6-tools-dev-tools
)

mkdir -p "$STATE_DIR"

echo "==> Installing Qt 6 base packages ..."

if (( EUID == 0 )); then
    APT=(apt-get)
else
    APT=(sudo apt-get)
fi

"${APT[@]}" update

# Packages installed via apt-get are recorded in dev-packages
INSTALLED_BY_DOTFILES="$STATE_DIR/dev-packages"
touch "$INSTALLED_BY_DOTFILES"

for package in "${QT6_BASE_PACKAGES[@]}"; do
    if ! dpkg-query -W -f='${Status}' "$package" 2>/dev/null |
        grep -q "install ok installed"; then 

        if ! grep -qx "$package" "$INSTALLED_BY_DOTFILES"; then 
            echo "$package" >> "$INSTALLED_BY_DOTFILES"
        fi

    fi
done

"${APT[@]}" install "${QT6_BASE_PACKAGES[@]}"

echo 
echo "==> Qt 6 base packages installed."
