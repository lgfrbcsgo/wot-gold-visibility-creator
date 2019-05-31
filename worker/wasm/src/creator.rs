use std::io::{Write, Cursor};

use ddsfile::{Dds, D3DFormat};

use image::dxt::{DXTEncoder, DXTVariant};

use zip::{ZipWriter, CompressionMethod};
use zip::write::FileOptions;

pub mod errors {
    error_chain! {
        types {
            CreateError, CreateErrorKind, CreateResultExt, CreateResult;
        }
        links {}
        foreign_links {
            DdsFile(::ddsfile::Error);
            Image(::image::ImageError);
            Zip(::zip::result::ZipError);
            IO(::std::io::Error);
        }
        errors {}
    }
}
use errors::CreateResult;

pub struct ColorOptions {
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

pub struct TextureOptions {
    pub image_data: ImageData,
    pub path: String
}

pub struct PackageOptions {
    pub color: ColorOptions,
    pub forward: TextureOptions,
    pub deferred: TextureOptions
}

pub fn create_package(options: PackageOptions) -> CreateResult<Vec<u8>> {

    let buffer: Vec<u8> = Vec::new();
    let cursor = Cursor::new(buffer);
    let mut zip = ZipWriter::new(cursor);

    let zip_options = FileOptions::default().compression_method(CompressionMethod::Stored);

    let forward_texture = create_texture(&options.color, options.forward.image_data)?;
    zip.start_file(options.forward.path, zip_options)?;
    zip.write(&forward_texture)?;

    let deferred_texture = create_texture(&options.color, options.deferred.image_data)?;
    zip.start_file(options.deferred.path, zip_options)?;
    zip.write(&deferred_texture)?;

    let cursor = zip.finish()?;

    Ok(cursor.into_inner())
}

fn create_texture(color: &ColorOptions, mut image_data: ImageData) -> CreateResult<Vec<u8>> {
    let ColorOptions { r, g, b, alpha } = color;

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