#!/usr/bin/env bash

set -euo pipefail

# =============================================================================
# C++ development environment provisioning
# =============================================================================

STATE_DIR="$HOME/.local/state/dotfiles"

DEV_PACKAGES=(
    build-essential
    cmake
    ninja-build
    ccache
    clang
    clangd
    clang-format
    clang-tidy
    gdb
    pipx
)

mkdir -p "$STATE_DIR"

echo "==> Installing C++ development tools..."

if (( EUID == 0 )); then
    APT=(apt-get)
else
    APT=(sudo apt-get)
fi

"${APT[@]}" apt-get update

INSTALLED_BY_DOTFILES="$STATE_DIR/dev-packages"
touch "$INSTALLED_BY_DOTFILES"

for package in "${DEV_PACKAGES[@]}"; do
    if ! dpkg-query -W -f='${Status}' "$package" 2>/dev/null |
        grep -q "install ok installed"; then

        if ! grep -qx "$package" "$INSTALLED_BY_DOTFILES"; then
            echo "$package" >> "$INSTALLED_BY_DOTFILES"
        fi
    fi
done

"${APT[@]}" apt-get install -y "${DEV_PACKAGES[@]}"

# -----------------------------------------------------------------------------
# Conan
# -----------------------------------------------------------------------------

CONAN_STATE="$STATE_DIR/conan"

if ! command -v conan >/dev/null 2>&1; then
    echo "==> Installing Conan..."
    pipx install conan
    touch "$CONAN_STATE"
else
    echo "==> Conan is already installed"
fi

pipx ensurepath

echo
echo "==> C++ development tools installed."
