
use aya::{Bpf, include_bytes_aligned, programs::Xdp};
use anyhow::Context;
use std::env;

#[tokio::main]
async fn main() -> Result<(), anyhow::Error> {
    let iface = env::args().nth(1).expect("No interface passed");
    let data = include_bytes_aligned!(
        "../target/ferros_firewall_ebpf.o"
    );
    let mut bpf = Bpf::load(data)?;
    let program: &mut Xdp = bpf.program_mut("firewall").unwrap().try_into()?;
    program.load()?;
    program.attach(&iface, aya::programs::XdpFlags::default())?;
    println!("eBPF program attached.");
    Ok(())
}
