module ColorTest exposing (conversions)

import Color.Hsva as Hsva exposing (Hsva, hsva)
import Color.Rgba as Rgba exposing (Rgba, rgba)
import Expect exposing (FloatingPointTolerance(..))
import Fuzz exposing (..)
import Test exposing (..)


type alias Rgb =
    { red : Int, green : Int, blue : Int }


type alias Hsv =
    { hue : Int, saturation : Float, value : Float }


maxRoundingError : FloatingPointTolerance
maxRoundingError =
    Absolute 1


noRoundingError : FloatingPointTolerance
noRoundingError =
    Absolute 0


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
                hsva hueFloat saturation value alpha
                    |> Hsva.toRgba
                    |> Rgba.toRecord
                    |> Expect.all
                        [ .red >> Expect.within maxRoundingError redFloat
                        , .green >> Expect.within maxRoundingError greenFloat
                        , .blue >> Expect.within maxRoundingError blueFloat
                        , .alpha >> Expect.within noRoundingError alpha
                        ]
        , fuzz validValue "from Rgba to Hsva." <|
            \alpha ->
                rgba redFloat greenFloat blueFloat alpha
                    |> Rgba.toHsva
                    |> Hsva.toRecord
                    |> Expect.all
                        [ .hue >> Expect.within maxRoundingError hueFloat
                        , .saturation >> Expect.within maxRoundingError saturation
                        , .value >> Expect.within maxRoundingError value
                        , .alpha >> Expect.within noRoundingError alpha
                        ]
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
                rgba red green blue 1
                    |> Rgba.toHsva
                    |> Hsva.toRecord
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
                hsva hue saturation value 1
                    |> Hsva.toRgba
                    |> Rgba.toRecord
                    |> Expect.all
                        [ .red >> Expect.atLeast 0
                        , .red >> Expect.atMost 1
                        , .green >> Expect.atLeast 0
                        , .green >> Expect.atMost 1
                        , .blue >> Expect.atLeast 0
                        , .blue >> Expect.atMost 1
                        ]
        , fuzz3 validValue validValue validValue "Conversion from Rgba to Rgba via Hsva has no effect." <|
            \red green blue ->
                rgba red green blue 1
                    |> Rgba.toHsva
                    |> Hsva.toRgba
                    |> Rgba.toRecord
                    |> Expect.all
                        [ .red >> Expect.within maxRoundingError red
                        , .green >> Expect.within maxRoundingError green
                        , .blue >> Expect.within maxRoundingError blue
                        , .alpha >> Expect.within noRoundingError 1
                        ]
        ]
