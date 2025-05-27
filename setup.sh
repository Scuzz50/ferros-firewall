#!/bin/bash
set -e

IFACE=${1:-eth0}

echo "📦 Installing system dependencies..."
sudo apt update
sudo apt install -y clang llvm llvm-dev libclang-dev libelf-dev build-essential pkg-config   linux-headers-$(uname -r) git curl zlib1g-dev libssl-dev llvm-14 llvm-14-dev   libclang-14-dev gcc-multilib jq llvm-ar llvm-strip

echo "🦀 Installing Rust toolchain..."
if ! command -v cargo &>/dev/null; then
  curl https://sh.rustup.rs -sSf | sh -s -- -y
  source $HOME/.cargo/env
fi

source $HOME/.cargo/env
rustup install nightly
rustup component add rust-src --toolchain nightly

echo "🔨 Building eBPF and userspace..."
make run IFACE=$IFACE
