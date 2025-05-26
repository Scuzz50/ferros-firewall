IFACE ?= eth0

EBPF_TARGET = ebpf/target/bpfel-unknown-none/release/ferros_firewall_ebpf.o
EBPF_OBJ = target/ferros_firewall_ebpf.o

.PHONY: all run clean

all: $(EBPF_OBJ)

$(EBPF_OBJ): ebpf/src/lib.rs
	cargo +nightly build --release --target bpfel-unknown-none -Z build-std=core --manifest-path ebpf/Cargo.toml
	cp $(EBPF_TARGET) $(EBPF_OBJ)

run: all
	cd userspace && cargo run --release -- $(IFACE)

clean:
	cargo clean
