use aya::programs::Xdp;
use aya::Bpf;
use std::convert::TryInto;
use std::env;
use anyhow::Context;

#[tokio::main]
async fn main() -> Result<(), anyhow::Error> {
    env_logger::init();
    let iface = env::args().nth(1).unwrap_or_else(|| "eth0".to_string());
    let mut bpf = Bpf::load_file("../target/ferros_firewall_ebpf.o").context("Loading eBPF object file")?;
    let program: &mut Xdp = bpf.program_mut("firewall").unwrap().try_into()?;
    program.load()?;
    program.attach(&iface, aya::programs::XdpFlags::default())?;
    println!("✅ eBPF program attached to {}", iface);
    Ok(())
}
