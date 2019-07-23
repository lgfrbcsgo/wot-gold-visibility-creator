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

import Parser exposing (Parser)


type alias Hsva =
    Color HsvaRecord


type alias Rgba =
    Color RgbaRecord


type Color a
    = Rgba RgbaRecord
    | Hsva HsvaRecord


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
rgba =
    constructRgba


hsva : Float -> Float -> Float -> Float -> Hsva
hsva =
    constructHsva


constructRgba : Float -> Float -> Float -> Float -> Color unrestricted
constructRgba red green blue alpha =
    Rgba
        { red = red |> min 1 |> max 0
        , green = green |> min 1 |> max 0
        , blue = blue |> min 1 |> max 0
        , alpha = alpha |> min 1 |> max 0
        }


constructHsva : Float -> Float -> Float -> Float -> Color unrestricted
constructHsva hue saturation value alpha =
    Hsva
        { hue = hue |> min 1 |> max 0
        , saturation = saturation |> min 1 |> max 0
        , value = value |> min 1 |> max 0
        , alpha = alpha |> min 1 |> max 0
        }


rgbaToHsva : RgbaRecord -> HsvaRecord
rgbaToHsva { red, green, blue, alpha } =
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


hsvaToRgba : HsvaRecord -> RgbaRecord
hsvaToRgba { hue, saturation, value, alpha } =
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


toHsva : Color any -> HsvaRecord
toHsva color =
    case color of
        Hsva hsvaRecord ->
            hsvaRecord

        Rgba rgbaRecord ->
            rgbaToHsva rgbaRecord


toRgba : Color any -> RgbaRecord
toRgba color =
    case color of
        Hsva hsvaRecord ->
            hsvaToRgba hsvaRecord

        Rgba rgbaRecord ->
            rgbaRecord


toCss : Color any -> String
toCss color =
    let
        { red, green, blue, alpha } =
            toRgba color
    in
    "rgba("
        ++ String.fromInt (round (red * 255))
        ++ ","
        ++ String.fromInt (round (green * 255))
        ++ ","
        ++ String.fromInt (round (blue * 255))
        ++ ","
        ++ String.fromFloat alpha
        ++ ")"


mapRed : Float -> Color { a | red : Float } -> Color { a | red : Float }
mapRed red color =
    case color of
        Rgba { green, blue, alpha } ->
            constructRgba red green blue alpha

        _ ->
            color


mapGreen : Float -> Color { a | green : Float } -> Color { a | green : Float }
mapGreen green color =
    case color of
        Rgba { red, blue, alpha } ->
            constructRgba red green blue alpha

        _ ->
            color


mapBlue : Float -> Color { a | blue : Float } -> Color { a | blue : Float }
mapBlue blue color =
    case color of
        Rgba { red, green, alpha } ->
            constructRgba red green blue alpha

        _ ->
            color


mapHue : Float -> Color { a | hue : Float } -> Color { a | hue : Float }
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


colorParser : Parser (Color unrestricted)
colorParser =
    Parser.succeed (constructRgba 1 1 1 1)


rgbaParser : Parser Rgba
rgbaParser =
    Parser.succeed (rgba 1 1 1 1)


hsvaParser : Parser Hsva
hsvaParser =
    Parser.succeed (hsva 1 1 1 1)
