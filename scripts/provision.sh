#!/usr/bin/env bash

set -euo pipefail

# =============================================================================
# Dotfiles provisioning
# =============================================================================

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="$HOME/.local/state/dotfiles"

BASE_PACKAGES=(
    zsh
    tmux
    git
    fzf
    zoxide
    zsh-autosuggestions
    zsh-syntax-highlighting
)

mkdir -p "$STATE_DIR"

echo "==> Provisioning from: $REPO_ROOT"

# -----------------------------------------------------------------------------
# Packages
# -----------------------------------------------------------------------------

echo "==> Installing base packages..."

if (( EUID == 0 )); then
    APT=(apt-get)
else
    APT=(sudo apt-get)
fi

"${APT[@]}" apt-get update

INSTALLED_BY_DOTFILES="$STATE_DIR/base-packages"
touch "$INSTALLED_BY_DOTFILES"

for package in "${BASE_PACKAGES[@]}"; do
    if ! dpkg-query -W -f='${Status}' "$package" 2>/dev/null |
        grep -q "install ok installed"; then

        if ! grep -qx "$package" "$INSTALLED_BY_DOTFILES"; then
            echo "$package" >> "$INSTALLED_BY_DOTFILES"
        fi
    fi
done

"${APT[@]}" apt-get install -y "${BASE_PACKAGES[@]}"

# -----------------------------------------------------------------------------
# Zsh completions
# -----------------------------------------------------------------------------

ZSH_COMPLETIONS_DIR="$REPO_ROOT/zsh/zsh-completions"

if [[ ! -d "$ZSH_COMPLETIONS_DIR" ]]; then
    echo "==> Installing zsh-completions..."

    git clone \
        https://github.com/zsh-users/zsh-completions.git \
        "$ZSH_COMPLETIONS_DIR"
else
    echo "==> zsh-completions already exists"
fi

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

echo "==> Installing configuration..."

ln -sfn "$REPO_ROOT/zsh/.zshrc" "$HOME/.zshrc"

if [[ -f "$REPO_ROOT/tmux/.tmux.conf" ]]; then
    ln -sfn "$REPO_ROOT/tmux/.tmux.conf" "$HOME/.tmux.conf"
fi

# -----------------------------------------------------------------------------
# Default shell
# -----------------------------------------------------------------------------

ZSH_PATH="$(command -v zsh)"
SET_DEFAULT_SHELL=true

if [[ "${1:-}" == "--no-default-shell" ]]; then
    SET_DEFAULT_SHELL=false
fi

if [[ "$SET_DEFAULT_SHELL" == true ]]; then

    if [[ "$SHELL" != "$ZSH_PATH" ]]; then
        echo "==> Setting Zsh as default shell..."

        if ! grep -qxF "$ZSH_PATH" /etc/shells; then
            echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
        fi

        chsh -s "$ZSH_PATH"
    else
        echo "==> Zsh is already the default shell"
    fi
fi

# -----------------------------------------------------------------------------
# Finish
# -----------------------------------------------------------------------------

echo
echo "==> Provisioning complete."
echo
echo "Repository : $REPO_ROOT"
echo "Shell      : $ZSH_PATH"
echo
echo "Restart your WSL session for the new login shell to take effect."
