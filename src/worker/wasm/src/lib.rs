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


// JS imports


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

#[wasm_bindgen]
extern "C" {
    pub type JsTextureConfig;

    #[wasm_bindgen(method, getter = packagePath)]
    fn package_path(this: &JsTextureConfig) -> String;

    #[wasm_bindgen(method, getter = imageData)]
    fn image_data(this: &JsTextureConfig) -> JsImageData;
}

impl Into<TextureConfig> for JsTextureConfig {
    fn into(self) -> TextureConfig {
        TextureConfig {
            package_path: self.package_path(),
            image_data: self.image_data().into()
        }
    }
}

#[wasm_bindgen]
extern "C" {
    pub type JsTextureConfigArray;

    #[wasm_bindgen(method, structural, indexing_getter)]
    fn get(this: &JsTextureConfigArray, index: u32) -> JsTextureConfig;

    #[wasm_bindgen(method, getter)]
    fn length(this: &JsTextureConfigArray) -> u32;
}

impl Into<Vec<TextureConfig>> for JsTextureConfigArray {
    fn into(self) -> Vec<TextureConfig> {
        let range = 0..self.length();
        range
            .map(|index| self.get(index).into())
            .collect::<Vec<TextureConfig>>()
    }
}

// Rust exports


#[wasm_bindgen]
struct WasmCreatorWorker {
    texture_configs: Vec<TextureConfig>
}

#[wasm_bindgen]
impl WasmCreatorWorker {
    #[wasm_bindgen(constructor)]
    pub fn new(textures: JsTextureConfigArray) -> WasmCreatorWorker {
        set_panic_hook();
        WasmCreatorWorker {
            texture_configs: textures.into()
        }
    }

    pub fn create(&self, color: JsColor) -> Vec<u8> {
        set_panic_hook();
        create_package(&self.texture_configs, &color.into())
            .unwrap_throw()
    }
}
