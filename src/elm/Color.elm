module Color exposing (HSVA, RGBA, toHSVA, toRGBA)


type alias RGBA =
    { red : Int
    , green : Int
    , blue : Int
    , alpha : Float
    }


type alias HSVA =
    { hue : Int
    , saturation : Float
    , value : Float
    , alpha : Float
    }


fModBy : Float -> Int -> Float
fModBy f n =
    let
        integer =
            floor f
    in
    toFloat (modBy integer n) + f - toFloat integer


toHSVA : RGBA -> HSVA
toHSVA { red, green, blue, alpha } =
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
            if cMax == r then
                60 * fModBy ((g - b) / c) 6

            else if cMax == g then
                60 * ((b - r) / c + 2)

            else if cMax == b then
                60 * ((r - g) / c + 4)

            else
                0.0

        s =
            if cMax == 0.0 then
                0.0

            else
                c / cMax
    in
    HSVA (floor h) s cMax alpha


toRGBA : HSVA -> RGBA
toRGBA { hue, saturation, value, alpha } =
    let
        c =
            value * saturation

        x =
            c * (1 - abs (fModBy (toFloat hue / 60) 2 - 1))

        m =
            value - c

        ( r, g, b ) =
            if hue < 60 then
                ( c, x, 0 )

            else if hue < 120 then
                ( x, c, 0 )

            else if hue < 180 then
                ( 0, c, x )

            else if hue < 240 then
                ( 0, x, c )

            else if hue < 300 then
                ( x, 0, c )

            else
                ( c, 0, x )
    in
    RGBA
        (floor (r + m) * 255)
        (floor (g + m) * 255)
        (floor (b + m) * 255)
        alpha
