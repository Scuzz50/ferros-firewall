use aya::programs::Xdp;
use aya::{Bpf, include_bytes_aligned};
use anyhow::Context;

#[tokio::main]
async fn main() -> Result<(), anyhow::Error> {
    let iface = std::env::args().nth(1).expect("No interface provided");
    let mut bpf = Bpf::load_file("../target/ferros_firewall_ebpf.o").context("Loading eBPF object file")?;

    let program: &mut Xdp = bpf.program_mut("firewall").unwrap().try_into()?;
    program.load()?;
    program.attach(&iface, aya::programs::XdpFlags::default())?;

    println!("eBPF program loaded on {}", iface);
    Ok(())
}
