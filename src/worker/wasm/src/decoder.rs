use image::ImageDecoder;
use image::png::PNGDecoder;

use crate::errors::Result;
use crate::structs::ImageData;

pub fn decode_resource(data: Vec<u8>) -> Result<ImageData> {
    let decoder = PNGDecoder::new(data.as_slice())?;
    let (width, height) = decoder.dimensions();
    let data = decoder.read_image()?;

    let image_data = ImageData {
        data,
        width: width as u32,
        height: height as u32
    };

    Ok(image_data)
}