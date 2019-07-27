module Picker.Internal exposing (matrixInput, sliderInput, styles)

import Color.Hsva exposing (Hsva)
import CssModules exposing (css)
import Html as H exposing (Attribute, Html)
import Slider


styles =
    css "./Picker/Styles.css"
        { picker = "picker"
        , checkerboard = "checkerboard"
        , hueGradient = "hue-gradient"
        , canvas = "canvas"
        }


baseStyles =
    css "./Picker/Styles.css"
        { slider = "slider"
        , matrix = "matrix"
        , background = "background"
        , thumb = "thumb"
        }


matrixInput =
    base [ baseStyles.class .matrix ]


sliderInput =
    base [ baseStyles.class .slider ]


base :
    List (Attribute msg)
    -> (Slider.Msg -> msg)
    -> (Hsva -> Slider.Position)
    -> (List (Attribute Slider.Msg) -> Hsva -> Html Slider.Msg)
    -> (List (Attribute Slider.Msg) -> Hsva -> Html Slider.Msg)
    -> Slider.Model
    -> Hsva
    -> Html msg
base attributes toMsg toPosition viewThumb viewBackground sliderModel color =
    H.div attributes
        [ Slider.view
            (viewThumb [ baseStyles.class .thumb ] color)
            (viewBackground [ baseStyles.class .background ] color)
            (toPosition color)
            sliderModel
            |> H.map toMsg
        ]
