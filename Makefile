BPF_TARGET = target/bpf/bpfel-unknown-none/release
EBPF_OBJECT = $(BPF_TARGET)/libferros_firewall_ebpf.so
US_TARGET = target/release/ferros-userspace

all:
	cargo +nightly build --release --target bpfel-unknown-none -Z build-std=core --manifest-path ebpf/Cargo.toml --target-dir target/bpf
	cp $(EBPF_OBJECT) target/ferros_firewall_ebpf.o
	cargo build --release --manifest-path userspace/Cargo.toml

run: all
	cd userspace && cargo run --release -- $(IFACE)
