module Color.Internal exposing
    ( Hsva
    , HsvaRecord
    , Rgba
    , RgbaRecord
    , convertHsvaRecordToRgba
    , convertRgbaRecordToHsva
    , hsva
    , hsvaFromRecord
    , hsvaToRecord
    , mapAlpha
    , mapBlue
    , mapGreen
    , mapHue
    , mapRed
    , mapSaturation
    , mapValue
    , rgba
    , rgbaFromRecord
    , rgbaRecordToCss
    , rgbaToRecord
    )


type Hsva
    = Hsva HsvaRecord


type Rgba
    = Rgba RgbaRecord


type alias RgbaRecord =
    { red : Float
    , green : Float
    , blue : Float
    , alpha : Float
    }


type alias HsvaRecord =
    { hue : Float
    , saturation : Float
    , value : Float
    , alpha : Float
    }


rgba : Float -> Float -> Float -> Float -> Rgba
rgba red green blue alpha =
    Rgba
        { red = clamp red
        , green = clamp green
        , blue = clamp blue
        , alpha = clamp alpha
        }


hsva : Float -> Float -> Float -> Float -> Hsva
hsva hue saturation value alpha =
    Hsva
        { hue = clamp hue
        , saturation = clamp saturation
        , value = clamp value
        , alpha = clamp alpha
        }


rgbaFromRecord : RgbaRecord -> Rgba
rgbaFromRecord { red, green, blue, alpha } =
    rgba red green blue alpha


hsvaFromRecord : HsvaRecord -> Hsva
hsvaFromRecord { hue, saturation, value, alpha } =
    hsva hue saturation value alpha


rgbaToRecord : Rgba -> RgbaRecord
rgbaToRecord (Rgba record) =
    record


hsvaToRecord : Hsva -> HsvaRecord
hsvaToRecord (Hsva record) =
    record


rgbaRecordToCss : RgbaRecord -> String
rgbaRecordToCss { red, green, blue, alpha } =
    "rgba("
        ++ String.fromInt (round (red * 255))
        ++ ","
        ++ String.fromInt (round (green * 255))
        ++ ","
        ++ String.fromInt (round (blue * 255))
        ++ ","
        ++ String.fromFloat alpha
        ++ ")"


convertRgbaRecordToHsva : RgbaRecord -> HsvaRecord
convertRgbaRecordToHsva { red, green, blue, alpha } =
    let
        r =
            red

        g =
            green

        b =
            blue

        cMax =
            r |> max g |> max b

        cMin =
            r |> min g |> min b

        c =
            cMax - cMin

        h =
            if c == 0.0 then
                0.0

            else if cMax == r then
                60 * fModBy ((g - b) / c) 6

            else if cMax == g then
                60 * ((b - r) / c + 2)

            else
                60 * ((r - g) / c + 4)

        s =
            if cMax == 0.0 then
                0.0

            else
                c / cMax
    in
    { hue = h / 360
    , saturation = s
    , value = cMax
    , alpha = alpha
    }


convertHsvaRecordToRgba : HsvaRecord -> RgbaRecord
convertHsvaRecordToRgba { hue, saturation, value, alpha } =
    let
        h =
            hue * 360

        c =
            value * saturation

        x =
            c * (1 - abs (fModBy (h / 60) 2 - 1))

        m =
            value - c

        ( r, g, b ) =
            if h < 60 then
                ( c, x, 0 )

            else if h < 120 then
                ( x, c, 0 )

            else if h < 180 then
                ( 0, c, x )

            else if h < 240 then
                ( 0, x, c )

            else if h < 300 then
                ( x, 0, c )

            else
                ( c, 0, x )
    in
    { red = r + m
    , green = g + m
    , blue = b + m
    , alpha = alpha
    }


mapRed : Float -> { a | red : Float } -> { a | red : Float }
mapRed red color =
    { color | red = red }


mapGreen : Float -> { a | green : Float } -> { a | green : Float }
mapGreen green color =
    { color | green = green }


mapBlue : Float -> { a | blue : Float } -> { a | blue : Float }
mapBlue blue color =
    { color | blue = blue }


mapHue : Float -> { a | hue : Float } -> { a | hue : Float }
mapHue hue color =
    { color | hue = hue }


mapSaturation : Float -> { a | saturation : Float } -> { a | saturation : Float }
mapSaturation saturation color =
    { color | saturation = saturation }


mapValue : Float -> { a | value : Float } -> { a | value : Float }
mapValue value color =
    { color | value = value }


mapAlpha : Float -> { a | alpha : Float } -> { a | alpha : Float }
mapAlpha alpha color =
    { color | alpha = alpha }


fModBy : Float -> Int -> Float
fModBy f n =
    let
        integer =
            floor f
    in
    toFloat (modBy n integer) + f - toFloat integer


clamp : Float -> Float
clamp value =
    value |> min 1 |> max 0
