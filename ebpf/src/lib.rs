#![no_std]
#![no_main]

use aya_bpf::{
    bindings::xdp_action,
    macros::xdp,
    programs::XdpContext,
};

#[xdp(name = "firewall")]
pub fn firewall(ctx: XdpContext) -> u32 {
    match try_firewall(&ctx) {
        Ok(ret) => ret,
        Err(_) => xdp_action::XDP_ABORTED,
    }
}

fn try_firewall(_ctx: &XdpContext) -> Result<u32, ()> {
    // ✅ Replace this with real filtering logic later
    Ok(xdp_action::XDP_PASS)
}

#[panic_handler]
fn panic(_: &core::panic::PanicInfo) -> ! {
    // ⛔️ `asm!` is unstable — replace with safe infinite loop for now
    loop {}
}
