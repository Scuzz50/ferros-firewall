#![no_std]
#![no_main]

use aya_bpf::{macros::xdp, programs::{XdpContext, XdpResult, XdpAction}};

#[xdp(name = "ferros_blocker")]
pub fn ferros_blocker(_ctx: XdpContext) -> XdpResult {
    Ok(XdpAction::Pass)
}

#[panic_handler]
fn panic(_info: &core::panic::PanicInfo) -> ! {
    core::arch::asm!("ud2", options(noreturn))
}
