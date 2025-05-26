IFACE ?= eth0

EBPF_TARGET = target/bpf/bpfel-unknown-none/release/ferros_firewall_ebpf
EBPF_OBJ = target/ferros_firewall_ebpf.o

.PHONY: all run clean

all: $(EBPF_OBJ)

$(EBPF_OBJ): ebpf/src/lib.rs
	cargo +nightly build --release \
		-Z build-std=core \
		--manifest-path ebpf/Cargo.toml \
		--target bpfel-unknown-none \
		--target-dir target/bpf
	cp $(EBPF_TARGET) $(EBPF_OBJ)

run: all
	cd userspace && cargo run --release -- $(IFACE)

clean:
	rm -rf target
