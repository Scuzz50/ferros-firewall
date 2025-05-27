#![no_std]
#![no_main]

use aya_bpf::{
    macros::xdp,
    programs::XdpContext,
};
use core::mem;

#[xdp(name = "firewall")]
pub fn firewall(ctx: XdpContext) -> u32 {
    match try_firewall(ctx) {
        Ok(ret) => ret,
        Err(_) => 2, // XDP_PASS
    }
}

fn try_firewall(_ctx: XdpContext) -> Result<u32, ()> {
    Ok(2) // XDP_PASS
}
