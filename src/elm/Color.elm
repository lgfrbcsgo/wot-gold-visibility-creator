module Color exposing (Color, Hsva, Rgba, fromHsva, fromRgba, toCssColor, toHsva, toRgba)


type Color
    = IRgba Rgba
    | IHsva Hsva


type alias Rgba =
    { red : Int
    , green : Int
    , blue : Int
    , alpha : Float
    }


type alias Hsva =
    { hue : Int
    , saturation : Float
    , value : Float
    , alpha : Float
    }


fromRgba : Rgba -> Color
fromRgba { red, green, blue, alpha } =
    IRgba
        { red = red |> min 255 |> max 0
        , green = green |> min 255 |> max 0
        , blue = blue |> min 255 |> max 0
        , alpha = alpha |> min 1.0 |> max 0.0
        }


fromHsva : Hsva -> Color
fromHsva { hue, saturation, value, alpha } =
    IHsva
        { hue = hue
        , saturation = saturation |> min 1.0 |> max 0.0
        , value = value |> min 1.0 |> max 0.0
        , alpha = alpha |> min 1.0 |> max 0.0
        }


toCssColor : Color -> String
toCssColor color =
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


toRgba : Color -> Rgba
toRgba color =
    case color of
        IRgba rgba ->
            rgba

        IHsva hsva ->
            convertToRgba hsva


toHsva : Color -> Hsva
toHsva color =
    case color of
        IHsva hsva ->
            hsva

        IRgba rgba ->
            convertToHsva rgba


fModBy : Float -> Int -> Float
fModBy f n =
    let
        integer =
            floor f
    in
    toFloat (modBy n integer) + f - toFloat integer


convertToHsva : Rgba -> Hsva
convertToHsva { red, green, blue, alpha } =
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
    Hsva (round h) s cMax alpha


convertToRgba : Hsva -> Rgba
convertToRgba { hue, saturation, value, alpha } =
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
        (round ((r + m) * 255))
        (round ((g + m) * 255))
        (round ((b + m) * 255))
        alpha
