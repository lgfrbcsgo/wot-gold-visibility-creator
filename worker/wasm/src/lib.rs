use wasm_bindgen::prelude::*;

mod create;
use create::{ImageData, Color, Texture};

#[macro_use]
extern crate error_chain;

#[cfg(feature = "wee_alloc")]
#[global_allocator]
static ALLOC: wee_alloc::WeeAlloc = wee_alloc::WeeAlloc::INIT;


pub fn use_panic_hook() {
    #[cfg(feature = "console_error_panic_hook")]
    console_error_panic_hook::set_once();
}


#[wasm_bindgen]
pub fn create_package(
    r: u8, g: u8, b: u8, alpha: f32,
    forward_data: Vec<u8>, forward_height: u32, forward_width: u32, forward_path: &str,
    deferred_data: Vec<u8>, deferred_height: u32, deferred_width: u32, deferred_path: &str
) -> Vec<u8> {

    use_panic_hook();

    create::create_package(
        &Color { r, g, b, alpha },
        Texture {
            image_data: ImageData {
                data: forward_data,
                height: forward_height,
                width: forward_width
            },
            path: forward_path
        },
        Texture {
            image_data: ImageData {
                data: deferred_data,
                height: deferred_height,
                width: deferred_width
            },
            path: deferred_path
        }
    ).unwrap_throw()
}



