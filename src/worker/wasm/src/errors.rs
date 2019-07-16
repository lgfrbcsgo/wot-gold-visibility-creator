error_chain! {
    types {
        Error, ErrorKind, ResultExt, Result;
    }
    links {}
    foreign_links {
        DdsFile(::ddsfile::Error);
        Image(::image::ImageError);
    }
    errors {}
}