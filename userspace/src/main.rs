use aya::{include_bytes_aligned, Ebpf};
use aya::programs::Xdp;
use anyhow::{Context, Result};
use std::env;

fn main() -> Result<()> {
    let iface = env::args().nth(1).context("No interface given")?;
    let mut bpf = Ebpf::load_file("target/ferros_firewall_ebpf.o")
        .context("Loading eBPF object file")?;

    let program: &mut Xdp = bpf.program_mut("firewall").unwrap().try_into()?;
    program.load()?;
    program.attach(&iface, aya::programs::XdpFlags::default())?;

    println!("✅ eBPF firewall attached to {}", iface);
    Ok(())
}
