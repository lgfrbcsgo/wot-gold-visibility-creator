use wasm_bindgen::prelude::*;

mod create;

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
    fn r(this: &ColorOptions) -> u8;

    #[wasm_bindgen(method, getter)]
    fn g(this: &ColorOptions) -> u8;

    #[wasm_bindgen(method, getter)]
    fn b(this: &ColorOptions) -> u8;

    #[wasm_bindgen(method, getter)]
    fn alpha(this: &ColorOptions) -> f32;
}

impl From<ColorOptions> for create::ColorOptions {
    fn from(color: ColorOptions) -> Self {
        create::ColorOptions {
            r: color.r(),
            g: color.g(),
            b: color.b(),
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

impl From<ImageData> for create::ImageData {
    fn from(image_data: ImageData) -> Self {
        create::ImageData {
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

impl From<TextureOptions> for create::TextureOptions {
    fn from(texture: TextureOptions) -> Self {
        create::TextureOptions {
            path: texture.path(),
            image_data: create::ImageData::from(texture.image_data())
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

impl From<PackageOptions> for create::PackageOptions {
    fn from(package: PackageOptions) -> Self {
        create::PackageOptions {
            color: create::ColorOptions::from(package.color()),
            forward: create::TextureOptions::from(package.forward()),
            deferred: create::TextureOptions::from(package.deferred())
        }
    }
}

#[wasm_bindgen]
pub fn create_package(options: PackageOptions) -> Vec<u8> {
    use_panic_hook();
    create::create_package(create::PackageOptions::from(options)).unwrap_throw()
}
