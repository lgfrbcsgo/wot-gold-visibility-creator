module ColorTest exposing (basisColorConversions, maxRoundingError, noRoundingError)

import Color
import Expect exposing (FloatingPointTolerance(..))
import Fuzz exposing (..)
import Test exposing (..)


maxRoundingError =
    0.002


noRoundingError =
    0


basisColorConversions : Test
basisColorConversions =
    describe "Basic color conversions"
        [ describe "Color.toRgba"
            [ fuzz (floatRange 0 1) "converts Black from Hsva to Rgba" <|
                \alpha ->
                    Color.hsva 0 0 0 alpha
                        |> Color.toRgba
                        |> Expect.equal (Color.RgbaRecord 0 0 0 alpha)
            , fuzz (floatRange 0 1) "converts White from Hsva to Rgba" <|
                \alpha ->
                    Color.hsva 0 0 1 alpha
                        |> Color.toRgba
                        |> Expect.equal (Color.RgbaRecord 255 255 255 alpha)
            , fuzz (floatRange 0 1) "converts Red from Hsva to Rgba" <|
                \alpha ->
                    Color.hsva 0 1 1 alpha
                        |> Color.toRgba
                        |> Expect.equal (Color.RgbaRecord 255 0 0 alpha)
            , fuzz (floatRange 0 1) "converts Lime from Hsva to Rgba" <|
                \alpha ->
                    Color.hsva 120 1 1 alpha
                        |> Color.toRgba
                        |> Expect.equal (Color.RgbaRecord 0 255 0 alpha)
            , fuzz (floatRange 0 1) "converts Blue from Hsva to Rgba" <|
                \alpha ->
                    Color.hsva 240 1 1 alpha
                        |> Color.toRgba
                        |> Expect.equal (Color.RgbaRecord 0 0 255 alpha)
            , fuzz (floatRange 0 1) "converts Yellow from Hsva to Rgba" <|
                \alpha ->
                    Color.hsva 60 1 1 alpha
                        |> Color.toRgba
                        |> Expect.equal (Color.RgbaRecord 255 255 0 alpha)
            , fuzz (floatRange 0 1) "converts Cyan from Hsva to Rgba" <|
                \alpha ->
                    Color.hsva 180 1 1 alpha
                        |> Color.toRgba
                        |> Expect.equal (Color.RgbaRecord 0 255 255 alpha)
            , fuzz (floatRange 0 1) "converts Magenta from Hsva to Rgba" <|
                \alpha ->
                    Color.hsva 300 1 1 alpha
                        |> Color.toRgba
                        |> Expect.equal (Color.RgbaRecord 255 0 255 alpha)
            , fuzz (floatRange 0 1) "converts Silver from Hsva to Rgba" <|
                \alpha ->
                    Color.hsva 0 0 0.75 alpha
                        |> Color.toRgba
                        |> Expect.equal (Color.RgbaRecord 191 191 191 alpha)
            , fuzz (floatRange 0 1) "converts Gray from Hsva to Rgba" <|
                \alpha ->
                    Color.hsva 0 0 0.5 alpha
                        |> Color.toRgba
                        |> Expect.equal (Color.RgbaRecord 128 128 128 alpha)
            , fuzz (floatRange 0 1) "converts Maroon from Hsva to Rgba" <|
                \alpha ->
                    Color.hsva 0 1 0.5 alpha
                        |> Color.toRgba
                        |> Expect.equal (Color.RgbaRecord 128 0 0 alpha)
            , fuzz (floatRange 0 1) "converts Olive from Hsva to Rgba" <|
                \alpha ->
                    Color.hsva 60 1 0.5 alpha
                        |> Color.toRgba
                        |> Expect.equal (Color.RgbaRecord 128 128 0 alpha)
            , fuzz (floatRange 0 1) "converts Green from Hsva to Rgba" <|
                \alpha ->
                    Color.hsva 120 1 0.5 alpha
                        |> Color.toRgba
                        |> Expect.equal (Color.RgbaRecord 0 128 0 alpha)
            , fuzz (floatRange 0 1) "converts Purple from Hsva to Rgba" <|
                \alpha ->
                    Color.hsva 300 1 0.5 alpha
                        |> Color.toRgba
                        |> Expect.equal (Color.RgbaRecord 128 0 128 alpha)
            , fuzz (floatRange 0 1) "converts Teal from Hsva to Rgba" <|
                \alpha ->
                    Color.hsva 180 1 0.5 alpha
                        |> Color.toRgba
                        |> Expect.equal (Color.RgbaRecord 0 128 128 alpha)
            , fuzz (floatRange 0 1) "converts Navy from Hsva to Rgba" <|
                \alpha ->
                    Color.hsva 240 1 0.5 alpha
                        |> Color.toRgba
                        |> Expect.equal (Color.RgbaRecord 0 0 128 alpha)
            ]
        , describe "Color.toHsva"
            [ fuzz (floatRange 0 1) "converts Black from Rgba to Hsva" <|
                \alpha ->
                    Color.rgba 0 0 0 alpha
                        |> Color.toHsva
                        |> Expect.all
                            [ .hue >> Expect.equal 0
                            , .saturation >> Expect.within (Absolute maxRoundingError) 0
                            , .value >> Expect.within (Absolute maxRoundingError) 0
                            , .alpha >> Expect.within (Absolute noRoundingError) alpha
                            ]
            , fuzz (floatRange 0 1) "converts White from Rgba to Hsva" <|
                \alpha ->
                    Color.rgba 255 255 255 alpha
                        |> Color.toHsva
                        |> Expect.all
                            [ .hue >> Expect.equal 0
                            , .saturation >> Expect.within (Absolute maxRoundingError) 0
                            , .value >> Expect.within (Absolute maxRoundingError) 1
                            , .alpha >> Expect.within (Absolute noRoundingError) alpha
                            ]
            , fuzz (floatRange 0 1) "converts Red from Rgba to Hsva" <|
                \alpha ->
                    Color.rgba 255 0 0 alpha
                        |> Color.toHsva
                        |> Expect.all
                            [ .hue >> Expect.equal 0
                            , .saturation >> Expect.within (Absolute maxRoundingError) 1
                            , .value >> Expect.within (Absolute maxRoundingError) 1
                            , .alpha >> Expect.within (Absolute noRoundingError) alpha
                            ]
            , fuzz (floatRange 0 1) "converts Lime from Rgba to Hsva" <|
                \alpha ->
                    Color.rgba 0 255 0 alpha
                        |> Color.toHsva
                        |> Expect.all
                            [ .hue >> Expect.equal 120
                            , .saturation >> Expect.within (Absolute maxRoundingError) 1
                            , .value >> Expect.within (Absolute maxRoundingError) 1
                            , .alpha >> Expect.within (Absolute noRoundingError) alpha
                            ]
            , fuzz (floatRange 0 1) "converts Blue from Rgba to Hsva" <|
                \alpha ->
                    Color.rgba 0 0 255 alpha
                        |> Color.toHsva
                        |> Expect.all
                            [ .hue >> Expect.equal 240
                            , .saturation >> Expect.within (Absolute maxRoundingError) 1
                            , .value >> Expect.within (Absolute maxRoundingError) 1
                            , .alpha >> Expect.within (Absolute noRoundingError) alpha
                            ]
            , fuzz (floatRange 0 1) "converts Yellow from Rgba to Hsva" <|
                \alpha ->
                    Color.rgba 255 255 0 alpha
                        |> Color.toHsva
                        |> Expect.all
                            [ .hue >> Expect.equal 60
                            , .saturation >> Expect.within (Absolute maxRoundingError) 1
                            , .value >> Expect.within (Absolute maxRoundingError) 1
                            , .alpha >> Expect.within (Absolute noRoundingError) alpha
                            ]
            , fuzz (floatRange 0 1) "converts Cyan from Rgba to Hsva" <|
                \alpha ->
                    Color.rgba 0 255 255 alpha
                        |> Color.toHsva
                        |> Expect.all
                            [ .hue >> Expect.equal 180
                            , .saturation >> Expect.within (Absolute maxRoundingError) 1
                            , .value >> Expect.within (Absolute maxRoundingError) 1
                            , .alpha >> Expect.within (Absolute noRoundingError) alpha
                            ]
            , fuzz (floatRange 0 1) "converts Magenta from Rgba to Hsva" <|
                \alpha ->
                    Color.rgba 255 0 255 alpha
                        |> Color.toHsva
                        |> Expect.all
                            [ .hue >> Expect.equal 300
                            , .saturation >> Expect.within (Absolute maxRoundingError) 1
                            , .value >> Expect.within (Absolute maxRoundingError) 1
                            , .alpha >> Expect.within (Absolute noRoundingError) alpha
                            ]
            , fuzz (floatRange 0 1) "converts Silver from Rgba to Hsva" <|
                \alpha ->
                    Color.rgba 191 191 191 alpha
                        |> Color.toHsva
                        |> Expect.all
                            [ .hue >> Expect.equal 0
                            , .saturation >> Expect.within (Absolute maxRoundingError) 0
                            , .value >> Expect.within (Absolute maxRoundingError) 0.75
                            , .alpha >> Expect.within (Absolute noRoundingError) alpha
                            ]
            , fuzz (floatRange 0 1) "converts Gray from Rgba to Hsva" <|
                \alpha ->
                    Color.rgba 128 128 128 alpha
                        |> Color.toHsva
                        |> Expect.all
                            [ .hue >> Expect.equal 0
                            , .saturation >> Expect.within (Absolute maxRoundingError) 0
                            , .value >> Expect.within (Absolute maxRoundingError) 0.5
                            , .alpha >> Expect.within (Absolute noRoundingError) alpha
                            ]
            , fuzz (floatRange 0 1) "converts Maroon from Rgba to Hsva" <|
                \alpha ->
                    Color.rgba 128 0 0 alpha
                        |> Color.toHsva
                        |> Expect.all
                            [ .hue >> Expect.equal 0
                            , .saturation >> Expect.within (Absolute maxRoundingError) 1
                            , .value >> Expect.within (Absolute maxRoundingError) 0.5
                            , .alpha >> Expect.within (Absolute noRoundingError) alpha
                            ]
            , fuzz (floatRange 0 1) "converts Olive from Rgba to Hsva" <|
                \alpha ->
                    Color.rgba 128 128 0 alpha
                        |> Color.toHsva
                        |> Expect.all
                            [ .hue >> Expect.equal 60
                            , .saturation >> Expect.within (Absolute maxRoundingError) 1
                            , .value >> Expect.within (Absolute maxRoundingError) 0.5
                            , .alpha >> Expect.within (Absolute noRoundingError) alpha
                            ]
            , fuzz (floatRange 0 1) "converts Green from Rgba to Hsva" <|
                \alpha ->
                    Color.rgba 0 128 0 alpha
                        |> Color.toHsva
                        |> Expect.all
                            [ .hue >> Expect.equal 120
                            , .saturation >> Expect.within (Absolute maxRoundingError) 1
                            , .value >> Expect.within (Absolute maxRoundingError) 0.5
                            , .alpha >> Expect.within (Absolute noRoundingError) alpha
                            ]
            , fuzz (floatRange 0 1) "converts Purple from Rgba to Hsva" <|
                \alpha ->
                    Color.rgba 128 0 128 alpha
                        |> Color.toHsva
                        |> Expect.all
                            [ .hue >> Expect.equal 300
                            , .saturation >> Expect.within (Absolute maxRoundingError) 1
                            , .value >> Expect.within (Absolute maxRoundingError) 0.5
                            , .alpha >> Expect.within (Absolute noRoundingError) alpha
                            ]
            , fuzz (floatRange 0 1) "converts Teal from Rgba to Hsva" <|
                \alpha ->
                    Color.rgba 0 128 128 alpha
                        |> Color.toHsva
                        |> Expect.all
                            [ .hue >> Expect.equal 180
                            , .saturation >> Expect.within (Absolute maxRoundingError) 1
                            , .value >> Expect.within (Absolute maxRoundingError) 0.5
                            , .alpha >> Expect.within (Absolute noRoundingError) alpha
                            ]
            , fuzz (floatRange 0 1) "converts Navy from Rgba to Hsva" <|
                \alpha ->
                    Color.rgba 0 0 128 alpha
                        |> Color.toHsva
                        |> Expect.all
                            [ .hue >> Expect.equal 240
                            , .saturation >> Expect.within (Absolute maxRoundingError) 1
                            , .value >> Expect.within (Absolute maxRoundingError) 0.5
                            , .alpha >> Expect.within (Absolute noRoundingError) alpha
                            ]
            ]
        ]
