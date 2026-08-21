#!/usr/bin/env bash

set -euo pipefail

# =============================================================================
# Dotfiles provisioning
# =============================================================================

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"

echo "==> Provisioning from: $REPO_ROOT"

# -----------------------------------------------------------------------------
# Packages
# -----------------------------------------------------------------------------

echo "==> Installing packages..."

sudo apt-get update

sudo apt-get install -y \
    zsh \
    tmux \
    git \
    fzf \
    zoxide \
    zsh-autosuggestions \
    zsh-syntax-highlighting

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

if [[ "$SHELL" != "$ZSH_PATH" ]]; then
    echo "==> Setting Zsh as default shell..."

    if ! grep -qxF "$ZSH_PATH" /etc/shells; then
        echo "$ZSH_PATH" | sudo tee -a /etc/shells >/dev/null
    fi

    chsh -s "$ZSH_PATH"
else
    echo "==> Zsh is already the default shell"
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
