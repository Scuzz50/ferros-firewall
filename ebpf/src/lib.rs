#![no_std]
#![no_main]

use aya_ebpf::{
    macros::map,
    maps::HashMap,
    macros::xdp,
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

fn try_firewall(ctx: XdpContext) -> Result<u32, ()> {
    let ip = ctx.data().ok_or(())?;
    unsafe {
        if BLOCKED_IPS.get(&ip).is_some() {
            return Ok(xdp_action::XDP_DROP);
        }
    }
    Ok(xdp_action::XDP_PASS)
}

mod xdp_action {
    pub const XDP_ABORTED: u32 = 0;
    pub const XDP_DROP: u32 = 1;
    pub const XDP_PASS: u32 = 2;
    pub const XDP_TX: u32 = 3;
    pub const XDP_REDIRECT: u32 = 4;
}
