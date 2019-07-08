module Color exposing
    ( Color
    , Hsva
    , HsvaRecord
    , Rgba
    , RgbaRecord
    , hsva
    , mapAlpha
    , mapBlue
    , mapGreen
    , mapHue
    , mapRed
    , mapSaturation
    , mapValue
    , rgba
    , toCss
    , toHsva
    , toRgba
    )


type alias Hsva =
    Color HsvaRecord


type alias Rgba =
    Color RgbaRecord


type Color a
    = Rgba RgbaRecord
    | Hsva HsvaRecord


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


rgba : Int -> Int -> Int -> Float -> Rgba
rgba =
    constructRgba


hsva : Int -> Float -> Float -> Float -> Hsva
hsva =
    constructHsva


constructRgba : Int -> Int -> Int -> Float -> Color a
constructRgba red green blue alpha =
    Rgba
        { red = red |> min 255 |> max 0
        , green = green |> min 255 |> max 0
        , blue = blue |> min 255 |> max 0
        , alpha = alpha |> min 1.0 |> max 0.0
        }


constructHsva : Int -> Float -> Float -> Float -> Color a
constructHsva hue saturation value alpha =
    Hsva
        { hue = hue
        , saturation = saturation |> min 1.0 |> max 0.0
        , value = value |> min 1.0 |> max 0.0
        , alpha = alpha |> min 1.0 |> max 0.0
        }


rgbaToHsva : RgbaRecord -> HsvaRecord
rgbaToHsva { red, green, blue, alpha } =
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
    { hue = round h
    , saturation = s
    , value = cMax
    , alpha = alpha
    }


hsvaToRgba : HsvaRecord -> RgbaRecord
hsvaToRgba { hue, saturation, value, alpha } =
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
    { red = round ((r + m) * 255)
    , green = round ((g + m) * 255)
    , blue = round ((b + m) * 255)
    , alpha = alpha
    }


toHsva : Color a -> HsvaRecord
toHsva color =
    case color of
        Hsva hsvaRecord ->
            hsvaRecord

        Rgba rgbaRecord ->
            rgbaToHsva rgbaRecord


toRgba : Color a -> RgbaRecord
toRgba color =
    case color of
        Hsva hsvaRecord ->
            hsvaToRgba hsvaRecord

        Rgba rgbaRecord ->
            rgbaRecord


toCss : Color a -> String
toCss color =
    let
        { red, green, blue, alpha } =
            toRgba color
    in
    "rgba("
        ++ String.fromInt red
        ++ ","
        ++ String.fromInt green
        ++ ","
        ++ String.fromInt blue
        ++ ","
        ++ String.fromFloat alpha
        ++ ")"


mapRed : Int -> Color { a | red : Int } -> Color { a | red : Int }
mapRed red color =
    case color of
        Rgba { green, blue, alpha } ->
            constructRgba red green blue alpha

        _ ->
            color


mapGreen : Int -> Color { a | green : Int } -> Color { a | green : Int }
mapGreen green color =
    case color of
        Rgba { red, blue, alpha } ->
            constructRgba red green blue alpha

        _ ->
            color


mapBlue : Int -> Color { a | blue : Int } -> Color { a | blue : Int }
mapBlue blue color =
    case color of
        Rgba { red, green, alpha } ->
            constructRgba red green blue alpha

        _ ->
            color


mapHue : Int -> Color { a | hue : Int } -> Color { a | hue : Int }
mapHue hue color =
    case color of
        Hsva { saturation, value, alpha } ->
            constructHsva hue saturation value alpha

        _ ->
            color


mapSaturation : Float -> Color { a | saturation : Float } -> Color { a | saturation : Float }
mapSaturation saturation color =
    case color of
        Hsva { hue, value, alpha } ->
            constructHsva hue saturation value alpha

        _ ->
            color


mapValue : Float -> Color { a | value : Float } -> Color { a | value : Float }
mapValue value color =
    case color of
        Hsva { hue, saturation, alpha } ->
            constructHsva hue saturation value alpha

        _ ->
            color


mapAlpha : Float -> Color { a | alpha : Float } -> Color { a | alpha : Float }
mapAlpha alpha color =
    case color of
        Hsva { hue, saturation, value } ->
            constructHsva hue saturation value alpha

        Rgba { red, green, blue } ->
            constructRgba red green blue alpha


fModBy : Float -> Int -> Float
fModBy f n =
    let
        integer =
            floor f
    in
    toFloat (modBy n integer) + f - toFloat integer
