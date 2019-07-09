module ColorTest exposing (conversions)

import Color
import Expect exposing (FloatingPointTolerance(..))
import Fuzz exposing (..)
import Test exposing (..)


type alias Rgb =
    { red : Int, green : Int, blue : Int }


type alias Hsv =
    { hue : Int, saturation : Float, value : Float }


maxRoundingError : Float
maxRoundingError =
    0.002


conversion : String -> Hsv -> Rgb -> Test
conversion name { hue, saturation, value } { red, green, blue } =
    describe ("Converts " ++ name)
        [ fuzz (floatRange 0 1) "from Hsva to Rgba" <|
            \alpha ->
                Color.hsva hue saturation value alpha
                    |> Color.toRgba
                    |> Expect.equal (Color.RgbaRecord red green blue alpha)
        , fuzz (floatRange 0 1) "from Rgba to Hsva" <|
            \alpha ->
                Color.rgba red green blue alpha
                    |> Color.toHsva
                    |> Expect.all
                        [ .hue >> Expect.equal hue
                        , .saturation >> Expect.within (Absolute maxRoundingError) saturation
                        , .value >> Expect.within (Absolute maxRoundingError) value
                        , .alpha >> Expect.within (Absolute 0) alpha
                        ]
        , fuzz (floatRange 0 1) "from Hsva to Hsva" <|
            \alpha ->
                Color.hsva hue saturation value alpha
                    |> Color.toHsva
                    |> Expect.equal (Color.HsvaRecord hue saturation value alpha)
        , fuzz (floatRange 0 1) "from Rgba to Rgba" <|
            \alpha ->
                Color.rgba red green blue alpha
                    |> Color.toRgba
                    |> Expect.equal (Color.RgbaRecord red green blue alpha)
        ]


conversions : Test
conversions =
    describe "Conversions"
        [ conversion "Black" (Hsv 0 0 0) (Rgb 0 0 0)
        , conversion "White" (Hsv 0 0 1) (Rgb 255 255 255)
        , conversion "Red" (Hsv 0 1 1) (Rgb 255 0 0)
        , conversion "Lime" (Hsv 120 1 1) (Rgb 0 255 0)
        , conversion "Blue" (Hsv 240 1 1) (Rgb 0 0 255)
        , conversion "Yellow" (Hsv 60 1 1) (Rgb 255 255 0)
        , conversion "Cyan" (Hsv 180 1 1) (Rgb 0 255 255)
        , conversion "Magenta" (Hsv 300 1 1) (Rgb 255 0 255)
        , conversion "Silver" (Hsv 0 0 0.75) (Rgb 191 191 191)
        , conversion "Gray" (Hsv 0 0 0.5) (Rgb 128 128 128)
        , conversion "Maroon" (Hsv 0 1 0.5) (Rgb 128 0 0)
        , conversion "Olive" (Hsv 60 1 0.5) (Rgb 128 128 0)
        , conversion "Green" (Hsv 120 1 0.5) (Rgb 0 128 0)
        , conversion "Purple" (Hsv 300 1 0.5) (Rgb 128 0 128)
        , conversion "Teal" (Hsv 180 1 0.5) (Rgb 0 128 128)
        , conversion "Navy" (Hsv 240 1 0.5) (Rgb 0 0 128)
        ]
