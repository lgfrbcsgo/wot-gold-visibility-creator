use ddsfile::{Dds, D3DFormat};
use image::dxt::{DXTEncoder, DXTVariant};


pub mod errors {
    error_chain! {
        types {
            CreateError, CreateErrorKind, CreateResultExt, CreateResult;
        }
        links {}
        foreign_links {
            DdsFile(::ddsfile::Error);
            Image(::image::ImageError);
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


pub fn create_texture(mut image_data: ImageData, color: &Color) -> CreateResult<Vec<u8>> {
    replace_color_information(color, &mut image_data.data);
    encode_dds(&image_data)
}

fn replace_color_information(color: &Color, data: &mut Vec<u8>) {
    let Color { red, green, blue, alpha } = color;

    for index in 0..data.len() {
        data[index] = match index % 4 {
            0 => *red,
            1 => *green,
            2 => *blue,
            _ => (data[index] as f32 * *alpha) as u8,
        };
    }
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
