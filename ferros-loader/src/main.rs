use aya::{Bpf, programs::Xdp};
use aya::util::online_cpus;
use clap::Parser;
use std::{fs, net::Ipv4Addr};
use tokio::signal;

#[derive(Parser)]
struct Opts {
    #[arg(short, long, default_value = "eth0")]
    iface: String,
}

#[tokio::main]
async fn main() -> Result<(), anyhow::Error> {
    let opts = Opts::parse();
    let mut bpf = Bpf::load_file("target/bpfel-unknown-none/release/ferros-ebpf")?;
    let program: &mut Xdp = bpf.program_mut("ferros_blocker")?.try_into()?;
    program.load()?;
    program.attach(&opts.iface, aya::programs::XdpFlags::default())?;

    println!("✅ Attached ferros_blocker to {}", opts.iface);
    signal::ctrl_c().await?;
    println!("❌ Exiting, detaching...");
    Ok(())
}
