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


validValue : Fuzzer Float
validValue =
    floatRange 0 1


conversion : String -> Hsv -> Rgb -> Test
conversion name { hue, saturation, value } { red, green, blue } =
    let
        hueFloat =
            toFloat hue / 360

        redFloat =
            toFloat red / 255

        greenFloat =
            toFloat green / 255

        blueFloat =
            toFloat blue / 255
    in
    describe ("Converts " ++ name)
        [ fuzz validValue "from Hsva to Rgba." <|
            \alpha ->
                Color.hsva hueFloat saturation value alpha
                    |> Color.toRgba
                    |> Expect.all
                        [ .red >> Expect.within (Absolute maxRoundingError) redFloat
                        , .green >> Expect.within (Absolute maxRoundingError) greenFloat
                        , .blue >> Expect.within (Absolute maxRoundingError) blueFloat
                        , .alpha >> Expect.within (Absolute 0) alpha
                        ]
        , fuzz validValue "from Rgba to Hsva." <|
            \alpha ->
                Color.rgba redFloat greenFloat blueFloat alpha
                    |> Color.toHsva
                    |> Expect.all
                        [ .hue >> Expect.within (Absolute maxRoundingError) hueFloat
                        , .saturation >> Expect.within (Absolute maxRoundingError) saturation
                        , .value >> Expect.within (Absolute maxRoundingError) value
                        , .alpha >> Expect.within (Absolute 0) alpha
                        ]
        , fuzz validValue "from Hsva to Hsva." <|
            \alpha ->
                Color.hsva hueFloat saturation value alpha
                    |> Color.toHsva
                    |> Expect.equal (Color.HsvaRecord hueFloat saturation value alpha)
        , fuzz validValue "from Rgba to Rgba." <|
            \alpha ->
                Color.rgba redFloat greenFloat blueFloat alpha
                    |> Color.toRgba
                    |> Expect.equal (Color.RgbaRecord redFloat greenFloat blueFloat alpha)
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
        , fuzz3 validValue validValue validValue "Conversion from Rgba to Hsva is within valid range." <|
            \red green blue ->
                Color.rgba red green blue 1
                    |> Color.toHsva
                    |> Expect.all
                        [ .hue >> Expect.atLeast 0
                        , .hue >> Expect.atMost 1
                        , .saturation >> Expect.atLeast 0
                        , .saturation >> Expect.atMost 1
                        , .value >> Expect.atLeast 0
                        , .value >> Expect.atMost 1
                        ]
        , fuzz3 validValue validValue validValue "Conversion from Hsva to Rgba is within valid range." <|
            \hue saturation value ->
                Color.hsva hue saturation value 1
                    |> Color.toRgba
                    |> Expect.all
                        [ .red >> Expect.atLeast 0
                        , .red >> Expect.atMost 1
                        , .green >> Expect.atLeast 0
                        , .green >> Expect.atMost 1
                        , .blue >> Expect.atLeast 0
                        , .blue >> Expect.atMost 1
                        ]
        ]
