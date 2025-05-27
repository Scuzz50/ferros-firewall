#!/bin/bash
set -e

IFACE=${1:-eth0}
sudo apt update
sudo apt install -y clang llvm-18 llvm-objcopy-18 llvm-ar-18 libclang-dev     libelf-dev build-essential zlib1g-dev libssl-dev pkg-config git curl jq     linux-headers-$(uname -r)

if ! command -v cargo &>/dev/null; then
    curl https://sh.rustup.rs -sSf | sh -s -- -y
    source "$HOME/.cargo/env"
fi

source "$HOME/.cargo/env"
rustup install nightly
rustup component add rust-src --toolchain nightly
cargo install bpf-linker --no-default-features || true

echo "📁 Setting Cargo network config for git-fetch-with-cli..."
mkdir -p $HOME/.cargo
echo '[net]
git-fetch-with-cli = true' > $HOME/.cargo/config.toml

make run IFACE=${IFACE}
