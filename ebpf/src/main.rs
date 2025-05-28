#![no_std]
#![no_main]

use aya_bpf::{macros::xdp, programs::XdpContext};

#[xdp(name = "ferros_firewall")]
pub fn ferros_firewall(ctx: XdpContext) -> u32 {
    match try_ferros_firewall(ctx) {
        Ok(ret) => ret,
        Err(_) => xdp_action::XDP_ABORTED,
    }
}

fn try_ferros_firewall(_ctx: XdpContext) -> Result<u32, ()> {
    Ok(xdp_action::XDP_PASS)
}

mod xdp_action {
    pub const XDP_ABORTED: u32 = 0;
    pub const XDP_DROP: u32 = 1;
    pub const XDP_PASS: u32 = 2;
}
