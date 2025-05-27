
LLVM_AR ?= llvm-ar-18
OBJCOPY ?= llvm-objcopy-18

all:
	cargo +nightly build --release \
		-Z build-std=core \
		--manifest-path ebpf/Cargo.toml \
		--target bpfel-unknown-none \
		--target-dir target/bpf

target/ferros_firewall_ebpf.o: all
	cp $(find target/bpf/bpfel-unknown-none/release/ -name 'libferros_firewall_ebpf.so') target/ferros_firewall_ebpf.o

run: target/ferros_firewall_ebpf.o
	cd userspace && cargo run --release -- eth0
