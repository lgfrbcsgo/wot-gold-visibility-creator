module Picker.SaturationValue exposing (Model, Msg, init, update, view)

import Basics
import Color exposing (..)
import Html exposing (Html)
import Html.Attributes
import Picker.Styles exposing (styles)
import Slider
import Svg exposing (..)
import Svg.Attributes exposing (..)



---- Model ----


type alias Model =
    Slider.Model


init : Slider.Model
init =
    Slider.init



---- UPDATE ----


type alias Msg =
    Slider.Msg


update : Msg -> Hsva -> Model -> ( Hsva, Model )
update msg color model =
    let
        { hue, saturation, value, alpha } =
            fromHsva color

        relativePosition =
            saturationValueToRelativePosition saturation value

        ( updatedRelativePosition, updatedModel ) =
            Slider.update msg relativePosition model

        updatedColor =
            HsvaRecord hue updatedRelativePosition.x (1 - updatedRelativePosition.y) alpha |> hsva
    in
    ( updatedColor, updatedModel )


saturationValueToRelativePosition : Float -> Float -> Slider.Position
saturationValueToRelativePosition saturation value =
    Slider.Position saturation (1 - value)



---- VIEW ----


view : Hsva -> Model -> Html Msg
view color model =
    let
        { hue, saturation, value } =
            fromHsva color

        relativePosition =
            saturationValueToRelativePosition saturation value

        gradientColor =
            HsvaRecord hue 1 1 1 |> hsva |> hsvaToRgba |> rgbaToCss

        thumbBackground =
            HsvaRecord hue saturation value 1 |> hsva |> hsvaToRgba |> rgbaToCss

        viewThumb =
            Html.div [ styles.class .thumb, Html.Attributes.style "backgroundColor" thumbBackground ] []

        viewBackground =
            svg [ height "100%", width "100%" ]
                [ defs []
                    [ linearGradient [ id "gradient-to-black", x1 "0%", x2 "0%", y1 "0%", y2 "100%" ]
                        [ stop [ offset "0%", stopColor "white" ] []
                        , stop [ offset "100%", stopColor "black" ] []
                        ]
                    , linearGradient [ id "gradient-to-color", x1 "0%", x2 "100%", y1 "0%", y2 "0%" ]
                        [ stop [ offset "0%", stopColor "white" ] []
                        , stop [ offset "100%", stopColor gradientColor ] []
                        ]
                    , rect [ id "gradient-to-black-rect", width "100%", height "100%", fill "url(#gradient-to-black)" ] []
                    , rect [ id "gradient-to-color-rect", width "100%", height "100%", fill "url(#gradient-to-color)" ] []
                    , Svg.filter [ id "gradient-multiply", x "0%", y "0%", width "100%", height "100%", colorInterpolationFilters "sRGB" ]
                        [ feImage [ width "100%", height "100%", result "black", xlinkHref "#gradient-to-black-rect" ] []
                        , feImage [ width "100%", height "100%", result "color", xlinkHref "#gradient-to-color-rect" ] []
                        , feBlend [ in_ "black", in2 "color", mode "multiply" ] []
                        ]
                    ]
                , rect [ Svg.Attributes.filter "url(#gradient-multiply)", x "0", y "0", width "100%", height "100%" ] []
                ]
    in
    Html.div [ styles.class .matrixWrapper ]
        [ Slider.view viewThumb viewBackground relativePosition model
        ]
