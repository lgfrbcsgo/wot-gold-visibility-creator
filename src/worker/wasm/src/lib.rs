use wasm_bindgen::prelude::*;

mod creator;

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

impl From<JsColor> for creator::Color {
    fn from(color: JsColor) -> Self {
        creator::Color {
            red: color.red(),
            green: color.green(),
            blue: color.blue(),
            alpha: color.alpha()
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

impl From<JsImageData> for creator::ImageData {
    fn from(image_data: JsImageData) -> Self {
        creator::ImageData {
            data: image_data.data(),
            height: image_data.height(),
            width: image_data.width()
        }
    }
}

#[wasm_bindgen]
extern "C" {
    pub type JsTextureOptions;

    #[wasm_bindgen(method, getter)]
    fn path(this: &JsTextureOptions) -> String;

    #[wasm_bindgen(method, getter = imageData)]
    fn image_data(this: &JsTextureOptions) -> JsImageData;
}

impl From<JsTextureOptions> for creator::TextureOptions {
    fn from(texture: JsTextureOptions) -> Self {
        creator::TextureOptions {
            path: texture.path(),
            image_data: texture.image_data().into()
        }
    }
}

#[wasm_bindgen]
extern "C" {
    pub type JsPackageOptions;

    #[wasm_bindgen(method, getter)]
    fn color(this: &JsPackageOptions) -> JsColor;

    #[wasm_bindgen(method, getter)]
    fn forward(this: &JsPackageOptions) -> JsTextureOptions;

    #[wasm_bindgen(method, getter)]
    fn deferred(this: &JsPackageOptions) -> JsTextureOptions;
}

impl From<JsPackageOptions> for creator::PackageOptions {
    fn from(package: JsPackageOptions) -> Self {
        creator::PackageOptions {
            color: package.color().into(),
            forward: package.forward().into(),
            deferred: package.deferred().into()
        }
    }
}

#[wasm_bindgen]
pub fn create_package(options: JsPackageOptions) -> Vec<u8> {
    use_panic_hook();
    creator::create_package(options.into()).unwrap_throw()
}
