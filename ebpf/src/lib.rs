#![no_std]
#![no_main]

use aya_ebpf::{
    macros::map,
    macros::xdp,
    maps::HashMap,
    programs::XdpContext,
};

#[map(name = "BLOCKED_IPS")]
static mut BLOCKED_IPS: HashMap<u32, u8> = HashMap::<u32, u8>::with_max_entries(1024, 0);

#[xdp(name = "firewall")]
pub fn firewall(ctx: XdpContext) -> u32 {
    match try_firewall(ctx) {
        Ok(ret) => ret,
        Err(_) => xdp_action::XDP_PASS,
    }
}

fn try_firewall(_ctx: XdpContext) -> Result<u32, ()> {
    let ip: u32 = 0x0a000001; // Placeholder IP 10.0.0.1
    unsafe {
        if BLOCKED_IPS.get(&ip).is_some() {
            return Ok(xdp_action::XDP_DROP);
        }
    }
    Ok(xdp_action::XDP_PASS)
}

#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    loop {}
}

mod xdp_action {
    pub const XDP_ABORTED: u32 = 0;
    pub const XDP_DROP: u32 = 1;
    pub const XDP_PASS: u32 = 2;
    pub const XDP_TX: u32 = 3;
    pub const XDP_REDIRECT: u32 = 4;
}
