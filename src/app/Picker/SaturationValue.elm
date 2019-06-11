module Picker.SaturationValue exposing (Model, Msg, init, subscriptions, update, view)

import Basics
import Color exposing (..)
import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Picker.Styles exposing (styles)
import Slider



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



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions =
    Slider.subscriptions



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
            div [ styles.class .thumb, style "backgroundColor" thumbBackground ] []

        viewBackground =
            div [ style "height" "10rem", style "width" "100%", style "backgroundColor" gradientColor ]
                [ div [ styles.class .whiteGradient, style "height" "100%", style "width" "100%" ]
                    [ div [ styles.class .blackGradient, style "height" "100%", style "width" "100%" ]
                        []
                    ]
                ]
    in
    div [ styles.class .matrixWrapper ]
        [ Slider.view viewThumb viewBackground relativePosition model
        ]
