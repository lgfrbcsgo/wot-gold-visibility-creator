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
    pub type ColorOptions;

    #[wasm_bindgen(method, getter)]
    fn red(this: &ColorOptions) -> f32;

    #[wasm_bindgen(method, getter)]
    fn green(this: &ColorOptions) -> f32;

    #[wasm_bindgen(method, getter)]
    fn blue(this: &ColorOptions) -> f32;

    #[wasm_bindgen(method, getter)]
    fn alpha(this: &ColorOptions) -> f32;
}

impl From<ColorOptions> for creator::ColorOptions {
    fn from(color: ColorOptions) -> Self {
        creator::ColorOptions {
            red: color.red(),
            green: color.green(),
            blue: color.blue(),
            alpha: color.alpha()
        }
    }
}

#[wasm_bindgen]
extern "C" {
    pub type ImageData;

    #[wasm_bindgen(method, getter)]
    fn data(this: &ImageData) -> Vec<u8>;

    #[wasm_bindgen(method, getter)]
    fn height(this: &ImageData) -> u32;

    #[wasm_bindgen(method, getter)]
    fn width(this: &ImageData) -> u32;
}

impl From<ImageData> for creator::ImageData {
    fn from(image_data: ImageData) -> Self {
        creator::ImageData {
            data: image_data.data(),
            height: image_data.height(),
            width: image_data.width()
        }
    }
}

#[wasm_bindgen]
extern "C" {
    pub type TextureOptions;

    #[wasm_bindgen(method, getter)]
    fn path(this: &TextureOptions) -> String;

    #[wasm_bindgen(method, getter = imageData)]
    fn image_data(this: &TextureOptions) -> ImageData;
}

impl From<TextureOptions> for creator::TextureOptions {
    fn from(texture: TextureOptions) -> Self {
        creator::TextureOptions {
            path: texture.path(),
            image_data: texture.image_data().into()
        }
    }
}

#[wasm_bindgen]
extern "C" {
    pub type PackageOptions;

    #[wasm_bindgen(method, getter)]
    fn color(this: &PackageOptions) -> ColorOptions;

    #[wasm_bindgen(method, getter)]
    fn forward(this: &PackageOptions) -> TextureOptions;

    #[wasm_bindgen(method, getter)]
    fn deferred(this: &PackageOptions) -> TextureOptions;
}

impl From<PackageOptions> for creator::PackageOptions {
    fn from(package: PackageOptions) -> Self {
        creator::PackageOptions {
            color: package.color().into(),
            forward: package.forward().into(),
            deferred: package.deferred().into()
        }
    }
}

#[wasm_bindgen]
pub fn create_package(options: PackageOptions) -> Vec<u8> {
    use_panic_hook();
    creator::create_package(options.into()).unwrap_throw()
}
