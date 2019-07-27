module Color.Rgba exposing
    ( Rgba
    , RgbaRecord
    , fromRecord
    , mapAlpha
    , mapBlue
    , mapGreen
    , mapRed
    , rgba
    , toCss
    , toHsva
    , toRecord
    )

import Color.Internal as Internal


type alias Rgba =
    Internal.Rgba


type alias RgbaRecord =
    Internal.RgbaRecord


rgba : Float -> Float -> Float -> Float -> Rgba
rgba =
    Internal.rgba


fromRecord : RgbaRecord -> Rgba
fromRecord =
    Internal.rgbaFromRecord


toRecord : Rgba -> RgbaRecord
toRecord =
    Internal.rgbaToRecord


toCss : Rgba -> String
toCss =
    toRecord >> Internal.rgbaRecordToCss


toHsva : Rgba -> Internal.Hsva
toHsva =
    toRecord >> Internal.convertRgbaRecordToHsva >> Internal.hsvaFromRecord


mapRed : Float -> Rgba -> Rgba
mapRed red =
    toRecord >> Internal.mapRed red >> fromRecord


mapGreen : Float -> Rgba -> Rgba
mapGreen green =
    toRecord >> Internal.mapGreen green >> fromRecord


mapBlue : Float -> Rgba -> Rgba
mapBlue blue =
    toRecord >> Internal.mapBlue blue >> fromRecord


mapAlpha : Float -> Rgba -> Rgba
mapAlpha alpha =
    toRecord >> Internal.mapAlpha alpha >> fromRecord
