use wasm_bindgen::prelude::*;
use image::dxt::{DXTEncoder, DXTVariant};
use ddsfile::{Dds, D3DFormat};
use zip::{ZipWriter, CompressionMethod};
use zip::write::{FileOptions};
use std::io::{Cursor, Write};


// When the `wee_alloc` feature is enabled, use `wee_alloc` as the global allocator.
#[cfg(feature = "wee_alloc")]
#[global_allocator]
static ALLOC: wee_alloc::WeeAlloc = wee_alloc::WeeAlloc::INIT;


pub fn set_panic_hook() {
    // When the `console_error_panic_hook` feature is enabled, we can call the
    // `set_panic_hook` function to get better error messages if we ever panic.
    #[cfg(feature = "console_error_panic_hook")]
        console_error_panic_hook::set_once();
}


#[wasm_bindgen]
pub fn create_package(r: u8, g: u8, b: u8, alpha: f32,
                      mut forward_bitmap: Vec<u8>, forward_height: u32, forward_width: u32, forward_path: &str,
                      mut deferred_bitmap: Vec<u8>, deferred_height: u32, deferred_width: u32, deferred_path: &str) -> Vec<u8> {
    set_panic_hook();

    let mut buffer: Vec<u8> = Vec::new();
    let mut cursor = Cursor::new(buffer);
    let mut zip = ZipWriter::new(cursor);

    let options = FileOptions::default().compression_method(CompressionMethod::Stored);

    let mut forward_texture = create_texture(forward_bitmap, forward_height, forward_width, r, g, b, alpha);
    zip.start_file(forward_path, options).unwrap_throw();
    zip.write(forward_texture.as_mut()).unwrap_throw();

    let mut deferred_texture = create_texture(deferred_bitmap, deferred_height, deferred_width, r, g, b, alpha);
    zip.start_file(deferred_path, options).unwrap_throw();
    zip.write(deferred_texture.as_mut()).unwrap_throw();

    let cursor = zip.finish().unwrap_throw();

    return cursor.into_inner();
}


fn create_texture(mut bitmap: Vec<u8>, height: u32, width: u32, r: u8, g: u8, b: u8, alpha: f32) -> Vec<u8> {
    for index in 0..bitmap.len() {
        bitmap[index] = match index % 4 {
            0 => r,
            1 => g,
            2 => b,
            _ => (bitmap[index] as f32 * alpha) as u8,
        };
    }

    return encode_dds(bitmap, height, width);
}



fn encode_dds(bitmap: Vec<u8>, height: u32, width: u32) -> Vec<u8> {
    let mut dds = Dds::new_d3d(height, width, Option::None, D3DFormat::DXT5, Option::None, Option::None)
        .unwrap_throw();

    let layer = dds.get_mut_data(0).unwrap_throw();

    let encoder = DXTEncoder::new(layer);
    encoder.encode(&bitmap, width, height, DXTVariant::DXT5).unwrap_throw();

    let mut output: Vec<u8> = Vec::new();
    dds.write(&mut output).unwrap_throw();

    return output;
}


