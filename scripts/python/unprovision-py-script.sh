#!/usr/bin/env bash

set -euo pipefail

# =============================================================================
# Temporary uv removal script 
# =============================================================================

if command -v uv &> /dev/null; then
    echo "==> Uninstalling uv ..."
    uv cache clean

    rm -rf "$(uv python dir)"
    rm -rf "$(uv tool dir)"

    rm -f ~/.local/bin/uv ~/.local/bin/uvx

    echo 
    echo "Done"
else
    echo "uv is not installed"
fi
