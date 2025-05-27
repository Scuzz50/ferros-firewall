#![no_std]
#![no_main]

use aya_ebpf::bindings::xdp_action;
use aya_ebpf::programs::XdpContext;
use aya_ebpf_macros::xdp;

#[xdp(name = "firewall")]
pub fn firewall(ctx: XdpContext) -> u32 {
    match try_firewall(&ctx) {
        Ok(ret) => ret,
        Err(_) => xdp_action::XDP_ABORTED,
    }
}

fn try_firewall(_ctx: &XdpContext) -> Result<u32, ()> {
    Ok(xdp_action::XDP_PASS)
}

#[panic_handler]
fn panic(_: &core::panic::PanicInfo) -> ! {
    loop {}
}
