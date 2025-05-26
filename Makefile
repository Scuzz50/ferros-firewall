IFACE ?= eth0

EBPF_TARGET = target/bpfel-unknown-none/release/ferros_firewall_ebpf
EBPF_OBJ = target/ferros_firewall_ebpf.o

.PHONY: all run clean

all: $(EBPF_OBJ)

$(EBPF_OBJ): ebpf/src/lib.rs
	cd ebpf && \
	cargo +nightly build --release --target bpfel-unknown-none -Z build-std=core
	llvm-objcopy \
		--strip-all \
		--output-format=elf64-bpf \
		ebpf/$(EBPF_TARGET) \
		$(EBPF_OBJ)

run: all
	cd userspace && cargo run --release -- $(IFACE)

clean:
	cargo clean
