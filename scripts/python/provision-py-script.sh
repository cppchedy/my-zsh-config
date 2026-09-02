#!/usr/bin/env bash

set -euo pipefail

# =============================================================================
# Python development environment provisioning
# Only uv for now
# TODO: 
# - design a unified arch for non-apt installed tools
# - uv only for standard python project - add conda
#   for ML work
# =============================================================================


# Assume curl is already installed
# TODO: test for curl, install if missing and clean up
echo "==> installing Python development tools..."

curl -LsSf https://astral.sh/uv/install.sh | sh

export PATH="${HOME}/.local/bin:${PATH}"

if command -v uv &> /dev/null; then
    echo "==> Success: $(uv --version) installed."
else
    echo "==> Error: uv installation failed or is not in PATH." >&2
    exit 1
fi

echo
echo "==> Python development tools installed."
