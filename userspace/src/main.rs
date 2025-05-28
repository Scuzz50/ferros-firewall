use std::env;

fn main() {
    let args: Vec<String> = env::args().collect();
    let iface = args.get(1).cloned().unwrap_or_else(|| "eth0".to_string());
    println!("🚀 Running Ferros Firewall on interface: {}", iface);
    // TODO: Load the eBPF program and attach
}
