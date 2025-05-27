#!/bin/bash
set -e

# Optional interface arg
IFACE=${1:-eth0}

echo "📦 Installing system dependencies..."
sudo apt update
sudo apt install -y \
  build-essential \
  clang \
  llvm-18 \
  llvm-18-dev \
  libclang-18-dev \
  libpolly-18-dev \
  libelf-dev \
  libbpf-dev \
  libssl-dev \
  pkg-config \
  zlib1g-dev \
  make \
  git \
  curl \
  jq \
  ca-certificates

# Symlink fallback if versioned binaries missing
[[ ! -f /usr/bin/llvm-ar ]] && sudo ln -s /usr/lib/llvm-18/bin/llvm-ar /usr/bin/llvm-ar
[[ ! -f /usr/bin/llvm-strip ]] && sudo ln -s /usr/lib/llvm-18/bin/llvm-strip /usr/bin/llvm-strip

echo "🦀 Installing Rust nightly + rust-src..."
if ! command -v rustup &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi
. "$HOME/.cargo/env"
rustup install nightly
rustup component add rust-src --toolchain nightly

echo "📁 Setting Cargo network config for git-fetch-with-cli..."
mkdir -p ~/.cargo
cat <<EOF > ~/.cargo/config.toml
[net]
git-fetch-with-cli = true
EOF

echo "🔨 Building and running firewall on $IFACE..."
cargo +nightly build --release \
  -Z build-std=core \
  --manifest-path ebpf/Cargo.toml \
  --target bpfel-unknown-none \
  --target-dir target/bpf

cp target/bpf/bpfel-unknown-none/release/libferros_firewall_ebpf.so target/ferros_firewall_ebpf.o

cd userspace
cargo build --release
cd ..
sudo ./target/release/ferros-userspace "$IFACE"
