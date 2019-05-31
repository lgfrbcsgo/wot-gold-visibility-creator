use std::io::{Write, Cursor};

use ddsfile::{Dds, D3DFormat};

use image::dxt::{DXTEncoder, DXTVariant};

use zip::{ZipWriter, CompressionMethod};
use zip::write::FileOptions;

pub mod errors;
use errors::CreateResult;


pub struct Color {
    pub r: u8,
    pub g: u8,
    pub b: u8,
    pub alpha: f32
}


pub struct ImageData {
    pub data: Vec<u8>,
    pub height: u32,
    pub width: u32
}


pub struct Texture<'a> {
    pub image_data: ImageData,
    pub path: &'a str
}


pub fn create_package(
    color: &Color,
    forward_texture: Texture,
    deferred_texture: Texture
) -> CreateResult<Vec<u8>> {

    let mut buffer: Vec<u8> = Vec::new();
    let mut cursor = Cursor::new(buffer);
    let mut zip = ZipWriter::new(cursor);

    let options = FileOptions::default().compression_method(CompressionMethod::Stored);

    let mut forward_texture_data = create_texture(color, forward_texture.image_data)?;
    zip.start_file(forward_texture.path, options)?;
    zip.write(&forward_texture_data)?;

    let mut deferred_texture_data = create_texture(color, deferred_texture.image_data)?;
    zip.start_file(deferred_texture.path, options)?;
    zip.write(&deferred_texture_data)?;

    let cursor = zip.finish()?;

    Ok(cursor.into_inner())
}


pub fn create_texture(color: &Color, mut image_data: ImageData) -> CreateResult<Vec<u8>> {
    let Color { r, g, b, alpha } = color;

    for index in 0..image_data.data.len() {
        image_data.data[index] = match index % 4 {
            0 => *r,
            1 => *g,
            2 => *b,
            _ => (image_data.data[index] as f32 * *alpha) as u8,
        };
    }

    encode_dds(&image_data)
}


fn encode_dds(image_data: &ImageData) -> CreateResult<Vec<u8>> {
    let ImageData { data, height, width } = image_data;

    let mut dds = Dds::new_d3d(*height, *width, Option::None, D3DFormat::DXT5, Option::None, Option::None)?;

    let layer = dds.get_mut_data(0)?;

    let encoder = DXTEncoder::new(layer);
    encoder.encode(data, *width, *height, DXTVariant::DXT5)?;

    let mut output: Vec<u8> = Vec::new();
    dds.write(&mut output)?;

    Ok(output)
}