module Picker.Shared exposing (matrixInput, sliderInput, styles)

import Color exposing (..)
import CssModules exposing (css)
import Html exposing (Attribute, Html, div)
import Slider


styles =
    css "./Picker/Shared.css"
        { picker = "picker"
        , checkerboard = "checkerboard"
        , hueGradient = "hue-gradient"
        }


baseStyles =
    css "./Picker/Shared.css"
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
    div attributes
        [ Slider.view
            (viewThumb [ baseStyles.class .thumb ] color)
            (viewBackground [ baseStyles.class .background ] color)
            (toPosition color)
            sliderModel
            |> Html.map toMsg
        ]
