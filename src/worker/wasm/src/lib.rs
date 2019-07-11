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


// ---- JS imports ----


#[wasm_bindgen]
extern "C" {
    pub type JsColor;

    #[wasm_bindgen(method, getter)]
    fn red(this: &JsColor) -> u8;

    #[wasm_bindgen(method, getter)]
    fn green(this: &JsColor) -> u8;

    #[wasm_bindgen(method, getter)]
    fn blue(this: &JsColor) -> u8;

    #[wasm_bindgen(method, getter)]
    fn alpha(this: &JsColor) -> f32;
}

impl Into<Color> for JsColor {
    fn into(self) -> Color {
        Color {
            red: self.red(),
            green: self.green(),
            blue: self.blue(),
            alpha: self.alpha()
        }
    }
}


// ---- Rust exports ----


#[wasm_bindgen]
pub fn create(color: JsColor, data: Vec<u8>, height: u32, width: u32) -> Vec<u8> {
    set_panic_hook();

    let image_data = ImageData {
        data, height, width
    };

    create_texture(&image_data, &color.into())
        .unwrap_throw()
}
