module Color exposing
    ( Hsva
    , HsvaRecord
    , Rgba
    , RgbaRecord
    , fromHsva
    , fromRgba
    , hsva
    , hsvaToRgba
    , rgba
    , rgbaToCss
    , rgbaToHsva
    )


type alias RgbaRecord =
    { red : Int
    , green : Int
    , blue : Int
    , alpha : Float
    }


type alias HsvaRecord =
    { hue : Int
    , saturation : Float
    , value : Float
    , alpha : Float
    }


type Rgba
    = Rgba RgbaRecord


type Hsva
    = Hsva HsvaRecord


rgba : RgbaRecord -> Rgba
rgba { red, green, blue, alpha } =
    Rgba
        { red = red |> min 255 |> max 0
        , green = green |> min 255 |> max 0
        , blue = blue |> min 255 |> max 0
        , alpha = alpha |> min 1.0 |> max 0.0
        }


fromRgba : Rgba -> RgbaRecord
fromRgba (Rgba record) =
    record


hsva : HsvaRecord -> Hsva
hsva { hue, saturation, value, alpha } =
    Hsva
        { hue = hue
        , saturation = saturation |> min 1.0 |> max 0.0
        , value = value |> min 1.0 |> max 0.0
        , alpha = alpha |> min 1.0 |> max 0.0
        }


fromHsva : Hsva -> HsvaRecord
fromHsva (Hsva record) =
    record


rgbaToHsva : Rgba -> Hsva
rgbaToHsva (Rgba { red, green, blue, alpha }) =
    let
        r =
            toFloat red / 255

        g =
            toFloat green / 255

        b =
            toFloat blue / 255

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
    Hsva (HsvaRecord (round h) s cMax alpha)


hsvaToRgba : Hsva -> Rgba
hsvaToRgba (Hsva { hue, saturation, value, alpha }) =
    let
        h =
            modBy 360 hue

        c =
            value * saturation

        x =
            c * (1 - abs (fModBy (toFloat h / 60) 2 - 1))

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
    Rgba
        (RgbaRecord
            (round ((r + m) * 255))
            (round ((g + m) * 255))
            (round ((b + m) * 255))
            alpha
        )


rgbaToCss : Rgba -> String
rgbaToCss (Rgba { red, green, blue, alpha }) =
    "rgba("
        ++ String.fromInt red
        ++ ","
        ++ String.fromInt green
        ++ ","
        ++ String.fromInt blue
        ++ ","
        ++ String.fromFloat alpha
        ++ ")"


fModBy : Float -> Int -> Float
fModBy f n =
    let
        integer =
            floor f
    in
    toFloat (modBy n integer) + f - toFloat integer
