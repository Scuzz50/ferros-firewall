IFACE ?= eth0

.PHONY: all run clean

all: target/ferros_firewall_ebpf.o

target/ferros_firewall_ebpf.o: ebpf/src/lib.rs
	cargo +nightly build --release \
		-Z build-std=core \
		--manifest-path ebpf/Cargo.toml \
		--target bpfel-unknown-none \
		--target-dir target/bpf
	cd target/bpf/bpfel-unknown-none/release && \
	llvm-ar x libferros_firewall_ebpf.a && \
	mv ferros_firewall_ebpf.o ../../../../target/ferros_firewall_ebpf.o

run: all
	cd userspace && cargo run --release -- $(IFACE)

clean:
	rm -rf target
