#!/bin/bash
set -e

IFACE=${1:-eth0}

echo "📦 Installing build dependencies..."
sudo apt update
sudo apt install -y build-essential clang llvm libclang-dev     libelf-dev zlib1g-dev libssl-dev pkg-config make git curl jq     linux-headers-$(uname -r)

echo "🦀 Installing Rust if missing..."
if ! command -v cargo &> /dev/null; then
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
fi

echo "🧱 Adding bpfel target..."
rustup target add bpfel-unknown-none

echo "🔧 Building eBPF and attaching to ${IFACE}..."
make run
