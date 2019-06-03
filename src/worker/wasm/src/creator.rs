use std::io::{Write, Cursor};
use std::borrow::Cow;
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


pub struct Color {
    pub red: u8,
    pub green: u8,
    pub blue: u8,
    pub alpha: f32
}

pub struct ImageData {
    pub data: Vec<u8>,
    pub height: u32,
    pub width: u32
}

impl ImageData {
    pub fn map_data(&self, map: impl Fn(&Vec<u8>) -> Vec<u8>) -> ImageData {
        ImageData {
            width: self.width,
            height: self.height,
            data: map(&self.data)
        }
    }
}

pub struct TextureConfig {
    pub image_data: ImageData,
    pub package_path: String
}

pub fn create_package(texture_configs: &Vec<TextureConfig>, color: &Color) -> CreateResult<Vec<u8>> {
    let buffer: Vec<u8> = Vec::new();
    let cursor = Cursor::new(buffer);
    let mut zip = ZipWriter::new(cursor);

    let zip_options = FileOptions::default().compression_method(CompressionMethod::Stored);

    for TextureConfig { image_data, package_path } in texture_configs {
        let texture = encode_dds(&image_data.map_data(|data| create_texture_data(color, data)))?;
        zip.start_file(Cow::from(package_path), zip_options)?;
        zip.write(&texture)?;
    }

    let cursor = zip.finish()?;
    Ok(cursor.into_inner())
}

fn create_texture_data(color: &Color, data: &Vec<u8>) -> Vec<u8> {
    let Color { red, green, blue, alpha } = color;

    data
        .iter()
        .enumerate()
        .map(|(index, value)| (match index % 4 {
            0 => *red,
            1 => *green,
            2 => *blue,
            _ => (*alpha * *value as f32) as u8,
        }))
        .collect::<Vec<u8>>()
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