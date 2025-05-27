#!/bin/bash
set -e

# Usage: ./setup.sh [network-interface]
IFACE=${1:-eth0}

echo "📦 Installing build dependencies..."
sudo apt update
sudo apt install -y \
  build-essential \
  clang \
  llvm \
  libclang-dev \
  libelf-dev \
  libbpf-dev \
  zlib1g-dev \
  libssl-dev \
  pkg-config \
  gcc-multilib \
  make \
  git \
  jq \
  ca-certificates \
  curl \
  linux-headers-$(uname -r)

echo "🦀 Installing Rust (if missing)..."
if ! command -v cargo >/dev/null 2>&1; then
    curl https://sh.rustup.rs -sSf | sh -s -- -y
fi

# Source Rust environment for current shell
if [ -f "$HOME/.cargo/env" ]; then
    echo "📂 Sourcing Rust environment..."
    . "$HOME/.cargo/env"
else
    echo "❌ Rust environment not found at ~/.cargo/env"
    exit 1
fi

echo "🧰 Installing aya-tool..."
cargo install --git https://github.com/aya-rs/aya --package aya-tool

echo "✅ Setup complete. You can now build the firewall with aya-tool."
