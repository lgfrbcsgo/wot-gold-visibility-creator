module Color.Hsva exposing
    ( Hsva
    , HsvaRecord
    , fromRecord
    , hsva
    , mapAlpha
    , mapHue
    , mapSaturation
    , mapValue
    , toCss
    , toRecord
    , toRgba
    )

import Color.Internal as Internal


type alias Hsva =
    Internal.Hsva


type alias HsvaRecord =
    Internal.HsvaRecord


hsva : Float -> Float -> Float -> Float -> Hsva
hsva =
    Internal.hsva


fromRecord : HsvaRecord -> Hsva
fromRecord =
    Internal.hsvaFromRecord


toRecord : Hsva -> HsvaRecord
toRecord =
    Internal.hsvaToRecord


toCss : Hsva -> String
toCss =
    toRecord >> Internal.convertHsvaRecordToRgba >> Internal.rgbaRecordToCss


toRgba : Hsva -> Internal.Rgba
toRgba =
    toRecord >> Internal.convertHsvaRecordToRgba >> Internal.rgbaFromRecord


mapHue : Float -> Hsva -> Hsva
mapHue hue =
    toRecord >> Internal.mapHue hue >> fromRecord


mapSaturation : Float -> Hsva -> Hsva
mapSaturation saturation =
    toRecord >> Internal.mapSaturation saturation >> fromRecord


mapValue : Float -> Hsva -> Hsva
mapValue value =
    toRecord >> Internal.mapValue value >> fromRecord


mapAlpha : Float -> Hsva -> Hsva
mapAlpha alpha =
    toRecord >> Internal.mapAlpha alpha >> fromRecord
