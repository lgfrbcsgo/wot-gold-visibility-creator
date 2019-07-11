use wasm_bindgen::prelude::*;

mod creator;
use creator::*;


#[macro_use]
extern crate error_chain;

#[cfg(feature = "wee_alloc")]
#[global_allocator]
static ALLOC: wee_alloc::WeeAlloc = wee_alloc::WeeAlloc::INIT;

pub fn set_panic_hook() {
    #[cfg(feature = "console_error_panic_hook")]
    console_error_panic_hook::set_once();
}


#[wasm_bindgen]
pub fn create(red: u8, green: u8, blue: u8, alpha: f32, data: Vec<u8>, height: u32, width: u32) -> Vec<u8> {
    set_panic_hook();

    let color = Color {
        red, green, blue, alpha
    };

    let image_data = ImageData {
        data, height, width
    };

    create_texture(&image_data, &color).unwrap_throw()
}
