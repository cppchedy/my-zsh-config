#!/usr/bin/env bash

set -euo pipefail

# =============================================================================
# C++ development environment provisioning
# =============================================================================

echo "==> Installing C++ development tools..."

sudo apt-get update

sudo apt-get install -y \
    build-essential \
    cmake \
    ninja-build \
    ccache \
    clang \
    clangd \
    clang-format \
    clang-tidy \
    gdb

echo
echo "==> C++ development tools installed."
