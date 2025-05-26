#!/bin/bash
set -e

IFACE=${1:-eth0}

echo "📦 Installing base build dependencies..."
sudo apt update
sudo apt install -y \
  build-essential \
  clang \
  llvm \
  libelf-dev \
  zlib1g-dev \
  libssl-dev \
  pkg-config \
  make \
  git \
  curl \
  jq \
  software-properties-common \
  gnupg \
  lsb-release \
  linux-headers-$(uname -r)

echo "➕ Adding LLVM APT repository for version 19..."
wget https://apt.llvm.org/llvm.sh
chmod +x llvm.sh
sudo ./llvm.sh 19

echo "🔧 Installing LLVM 19 toolchain..."
sudo apt install -y llvm-19-dev libclang-19-dev libpolly-19-dev

echo "🔧 Installing bpftool and bindgen..."
sudo apt install -y bpftool libclang-dev
cargo install bindgen || true

echo "🦀 Installing Rust if missing..."
if ! command -v cargo &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

echo "📦 Installing nightly + rust-src..."
rustup install nightly
rustup component add rust-src --toolchain nightly

echo "🔧 Installing bpf-linker..."
cargo install bpf-linker --no-default-features || true

echo "💡 Sourcing Rust environment..."
source "$HOME/.cargo/env"

echo "📁 Setting Cargo network config for git-fetch-with-cli..."
mkdir -p ~/.cargo
echo '[net]' > ~/.cargo/config.toml
echo 'git-fetch-with-cli = true' >> ~/.cargo/config.toml

echo "🔨 Building and running firewall on ${IFACE}..."
make run IFACE=${IFACE}
