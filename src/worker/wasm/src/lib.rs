use wasm_bindgen::prelude::*;

mod decoder;
use decoder::*;

mod encoder;
use encoder::*;

mod structs;
use structs::*;

mod errors;

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

#[wasm_bindgen]
extern "C" {
    pub type JsImageData;

    #[wasm_bindgen(method, getter)]
    fn data(this: &JsImageData) -> Vec<u8>;

    #[wasm_bindgen(method, getter)]
    fn height(this: &JsImageData) -> u32;

    #[wasm_bindgen(method, getter)]
    fn width(this: &JsImageData) -> u32;
}

impl Into<ImageData> for JsImageData {
    fn into(self) -> ImageData {
        ImageData {
            data: self.data(),
            height: self.height(),
            width: self.width()
        }
    }
}


// ---- Rust exports ----


#[wasm_bindgen]
pub struct RustImageData {
    image_data: ImageData
}

#[wasm_bindgen]
impl RustImageData {
    fn new(image_data: ImageData) -> Self {
        RustImageData {image_data}
    }

    #[wasm_bindgen(getter)]
    pub fn height(&self) -> u32 {
        self.image_data.height
    }

    #[wasm_bindgen(getter)]
    pub fn width(&self) -> u32 {
        self.image_data.width
    }

    #[wasm_bindgen(getter)]
    pub fn data(&self) -> Vec<u8> {
        self.image_data.data.clone()
    }
}


#[wasm_bindgen]
pub fn encode(image_data: JsImageData, color: JsColor) -> Vec<u8> {
    set_panic_hook();
    encode_texture(image_data.into(), &color.into())
        .unwrap_throw()
}

#[wasm_bindgen]
pub fn decode(data: Vec<u8>) -> RustImageData {
    set_panic_hook();
    RustImageData::new(decode_resource(data)
        .unwrap_throw())
}
