build:
	cargo +nightly build --release --target bpfel-unknown-none -Z build-std=core -p ferros-ebpf
	llvm-objcopy --strip-all --output-format=elf64-bpf \
		target/bpfel-unknown-none/release/ferros-ebpf \
		target/bpfel-unknown-none/release/ferros-ebpf.o

run: build
	cargo run -p ferros-loader -- --iface eth0
