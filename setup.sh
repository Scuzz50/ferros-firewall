#!/bin/bash
set -e

IFACE=${1:-eth0}

echo "📦 Installing system dependencies..."
sudo apt update
sudo apt install -y \
  build-essential \
  clang \
  llvm-18 \
  libclang-18-dev \
  libpolly-18-dev \
  libelf-dev \
  pkg-config \
  zlib1g-dev \
  libssl-dev \
  gcc-multilib \
  linux-headers-$(uname -r) \
  make \
  git \
  curl \
  jq \
  ca-certificates

echo "🔗 Creating symlinks for llvm tools..."
sudo ln -sf /usr/lib/llvm-18/bin/llvm-ar /usr/local/bin/llvm-ar-18
sudo ln -sf /usr/lib/llvm-18/bin/llvm-objcopy /usr/local/bin/llvm-objcopy-18

echo "🦀 Installing Rust if missing..."
if ! command -v cargo &>/dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

echo "📦 Installing Rust nightly + rust-src..."
rustup install nightly
rustup component add rust-src --toolchain nightly

echo "📁 Sourcing Rust environment..."
source "$HOME/.cargo/env"

echo "📁 Setting Cargo network config for git-fetch-with-cli..."
mkdir -p .cargo
cat <<EOF > .cargo/config.toml
[net]
git-fetch-with-cli = true
EOF

echo "🔨 Building and running firewall on ${IFACE}..."
make run IFACE=${IFACE}
