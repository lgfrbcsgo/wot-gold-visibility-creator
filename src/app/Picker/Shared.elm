module Picker.Shared exposing (matrix, slider, styles)

import CssModules exposing (css)
import Html exposing (Html, div)
import Html.Attributes exposing (class)
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


matrix =
    base (baseStyles.toString .matrix)


slider =
    base (baseStyles.toString .slider)


base : String -> (Slider.Msg -> msg) -> Html Slider.Msg -> Html Slider.Msg -> Slider.Position -> Slider.Model -> Html msg
base className toMsg viewThumb viewBackground sliderPosition sliderModel =
    div [ class className ]
        [ Slider.view
            (div [ baseStyles.class .thumb ]
                [ viewThumb ]
            )
            (div [ baseStyles.class .background ]
                [ viewBackground ]
            )
            sliderPosition
            sliderModel
            |> Html.map toMsg
        ]
