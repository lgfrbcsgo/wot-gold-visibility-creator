error_chain! {
    types {
        CreateError, CreateErrorKind, CreateResultExt, CreateResult;
    }

    links {
    }

    foreign_links {
        DdsFile(::ddsfile::Error);
        Image(::image::ImageError);
        Zip(::zip::result::ZipError);
        IO(::std::io::Error);
    }

    errors {
    }
}