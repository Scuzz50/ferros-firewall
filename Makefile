# Makefile for ferros-firewall (eBPF build with cargo)

EBPF_DIR := ebpf
TARGET := target/ferros_firewall_ebpf.o
IFACE ?= eth0

.PHONY: all clean install run

all: $(TARGET)

$(TARGET):
	@echo "🔨 Building eBPF program with cargo..."
	cd $(EBPF_DIR) && \
	cargo +nightly build --release --target bpfel-unknown-none -Z build-std=core
	mkdir -p target
	cp $(EBPF_DIR)/target/bpfel-unknown-none/release/ferros_firewall_ebpf.o $(TARGET)

clean:
	@echo "🧹 Cleaning build artifacts..."
	cargo clean
	rm -rf target

install:
	@echo "🚀 Installing systemd service..."
	sudo cp ferros-firewall.service /etc/systemd/system/ferros-firewall.service
	sudo systemctl daemon-reexec
	sudo systemctl enable ferros-firewall.service
	sudo systemctl restart ferros-firewall.service

run:
	@echo "⚙️ Running userspace controller..."
	sudo ./target/release/ferros-firewall --interface $(IFACE)
