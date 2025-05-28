#!/bin/bash
set -e

# Usage: ./setup.sh [network-interface]
IFACE=${1:-eth0}

echo "📦 Installing system and eBPF build dependencies..."
sudo apt update
sudo apt install -y \
  build-essential \
  clang \
  llvm \
  llvm-15 \
  llvm-15-tools \
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
  curl \
  ca-certificates \
  linux-headers-$(uname -r)

echo "🦀 Installing Rust (if missing)..."
if ! command -v cargo &>/dev/null; then
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
fi

if [ -f "$HOME/.cargo/env" ]; then
  echo "📂 Sourcing Rust environment..."
  . "$HOME/.cargo/env"
else
  echo "❌ Rust environment not found at ~/.cargo/env"
  exit 1
fi

echo "📌 Installing required Rust targets and components..."
rustup install nightly
rustup component add rust-src --toolchain nightly

echo "📁 Building eBPF program..."
cd ebpf
cargo +nightly build \
  --release \
  -Z build-std=core \
  --target bpfel-unknown-none \
  -p ferros-ebpf

echo "🔧 Stripping and exporting eBPF binary..."
llvm-15 \
  llvm-15-tools \
  --strip-all \
  --output-format=elf64-bpf \
  target/bpfel-unknown-none/release/ferros_firewall_ebpf \
  ../target/ferros_firewall_ebpf.o

cd ..

echo "🔧 Building userspace controller..."
cargo build --release -p ferros-firewall

echo "⚙️ Installing systemd service..."
SERVICE_FILE="/etc/systemd/system/ferros-firewall.service"

sudo tee "$SERVICE_FILE" > /dev/null <<EOF
[Unit]
Description=Ferros Firewall eBPF Controller
After=network.target

[Service]
ExecStart=$(pwd)/target/release/ferros-firewall --interface $IFACE
Restart=on-failure
User=root

[Install]
WantedBy=multi-user.target
EOF

echo "🔄 Enabling and starting ferros-firewall service..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable ferros-firewall
sudo systemctl restart ferros-firewall

echo "✅ Ferros Firewall installed and running on interface: $IFACE"
