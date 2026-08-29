#!/usr/bin/env bash

set -euo pipefail

# =============================================================================
# Dotfiles unprovisioning
#
# Removes only resources managed by the provisioning scripts.
# =============================================================================

REPO_ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
STATE_DIR="$HOME/.local/state/dotfiles"

echo "==> Unprovisioning dotfiles environment"
echo "    Repository: $REPO_ROOT"
echo

# -----------------------------------------------------------------------------
# Helpers
# -----------------------------------------------------------------------------

remove_symlink() {
    local target="$1"
    local expected="$2"

    if [[ -L "$target" ]]; then
        local actual
        actual="$(readlink -f "$target")"

        if [[ "$actual" == "$expected" ]]; then
            echo "==> Removing symlink: $target"
            rm "$target"
        else
            echo "!! Keeping unrelated symlink: $target"
            echo "   Points to: $actual"
        fi
    elif [[ -e "$target" ]]; then
        echo "!! Keeping existing file: $target"
    fi
}

remove_package() {
    local package="$1"

    if dpkg-query -W -f='${Status}' "$package" 2>/dev/null |
        grep -q "install ok installed"; then
        echo "==> Removing package: $package"
        sudo apt-get remove -y "$package"
    fi
}

remove_recorded_packages() {
    local state_file="$1"

    if [[ ! -f "$state_file" ]]; then
        return
    fi

    while IFS= read -r package; do
        [[ -z "$package" ]] && continue
        remove_package "$package"
    done < "$state_file"

    rm -f "$state_file"
}

# -----------------------------------------------------------------------------
# Configuration
# -----------------------------------------------------------------------------

remove_symlink \
    "$HOME/.zshrc" \
    "$REPO_ROOT/zsh/.zshrc"

remove_symlink \
    "$HOME/.tmux.conf" \
    "$REPO_ROOT/tmux/.tmux.conf"

# -----------------------------------------------------------------------------
# Zsh completion dependency
# -----------------------------------------------------------------------------

ZSH_COMPLETIONS_DIR="$REPO_ROOT/zsh/zsh-completions"

if [[ -d "$ZSH_COMPLETIONS_DIR/.git" ]]; then
    echo "==> Removing zsh-completions clone"
    rm -rf "$ZSH_COMPLETIONS_DIR"
elif [[ -e "$ZSH_COMPLETIONS_DIR" ]]; then
    echo "!! Keeping $ZSH_COMPLETIONS_DIR"
    echo "   It does not look like a Git clone."
fi

# -----------------------------------------------------------------------------
# Generated Zsh state
# -----------------------------------------------------------------------------

if [[ -f "$HOME/.zcompdump" ]]; then
    echo "==> Removing Zsh completion cache"
    rm -f "$HOME/.zcompdump"
fi

if [[ -d "$HOME/.cache/zsh" ]]; then
    echo "==> Removing Zsh cache"
    rm -rf "$HOME/.cache/zsh"
fi

# -----------------------------------------------------------------------------
# Default shell
# -----------------------------------------------------------------------------

ZSH_PATH="$(command -v zsh 2>/dev/null || true)"
BASH_PATH="$(command -v bash 2>/dev/null || true)"

if [[ -n "$ZSH_PATH" &&
      "$SHELL" == "$ZSH_PATH" &&
      -n "$BASH_PATH" ]]; then

    echo "==> Restoring Bash as default shell"
    chsh -s "$BASH_PATH"
fi

# -----------------------------------------------------------------------------
# Packages
# -----------------------------------------------------------------------------

echo "==> Removing packages installed by dotfiles..."

remove_recorded_packages "$STATE_DIR/dev-packages"
remove_recorded_packages "$STATE_DIR/base-packages"

# -----------------------------------------------------------------------------
# State
# -----------------------------------------------------------------------------

if [[ -d "$STATE_DIR" ]] && [[ -z "$(ls -A "$STATE_DIR")" ]]; then
    rmdir "$STATE_DIR"
fi

echo
echo "==> Unprovisioning complete."
echo "    Restart WSL to start a clean shell."
