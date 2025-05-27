
#![no_std]
#![no_main]

use aya_ebpf::{bindings::xdp_action, macros::map, macros::xdp, maps::HashMap, programs::XdpContext};

#[map(name = "BLOCKED_IPS")]
static mut BLOCKED_IPS: HashMap<u32, u32> = HashMap::<u32, u32>::with_max_entries(1024, 0);

#[xdp(name = "firewall")]
pub fn firewall(ctx: XdpContext) -> u32 {
    match try_firewall(ctx) {
        Ok(ret) => ret,
        Err(_) => xdp_action::XDP_PASS,
    }
}

fn try_firewall(ctx: XdpContext) -> Result<u32, ()> {
    let ip = u32::from_be_bytes([0, 0, 0, 0]); // Dummy logic
    unsafe {
        if BLOCKED_IPS.get(&ip).is_some() {
            return Ok(xdp_action::XDP_DROP);
        }
    }
    Ok(xdp_action::XDP_PASS)
}

#[panic_handler]
fn panic(_: &core::panic::PanicInfo) -> ! {
    core::arch::asm!("ud2", options(noreturn))
}
