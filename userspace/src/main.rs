use aya::Ebpf;
use aya::programs::Xdp;
use anyhow::{Context, Result};
use std::env;
use std::path::PathBuf;

fn main() -> Result<()> {
    let iface = env::args().nth(1).context("No interface given")?;

    let mut elf_path = PathBuf::from(env!("CARGO_MANIFEST_DIR"));
    elf_path.push("../target/ferros_firewall_ebpf.o");

    let mut bpf = Ebpf::load_file(&elf_path).context("Loading eBPF object file")?;

    let program: &mut Xdp = bpf.program_mut("firewall").unwrap().try_into()?;
    program.load()?;
    program.attach(&iface, aya::programs::XdpFlags::default())?;

    println!("✅ eBPF firewall attached to {}", iface);
    Ok(())
}
