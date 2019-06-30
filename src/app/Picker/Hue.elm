module Picker.Hue exposing (Model, Msg, init, subscriptions, update, view)

import Basics
import Color exposing (..)
import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Picker.Shared exposing (slider, styles)
import Slider



---- Model ----


type Model
    = Model Slider.Model


init : Model
init =
    Model Slider.init



---- UPDATE ----


type Msg
    = Slider Slider.Msg


update : Msg -> Hsva -> Model -> ( Hsva, Model )
update (Slider msg) color (Model model) =
    let
        relativePosition =
            colorToRelativePosition color

        ( updatedRelativePosition, updatedModel ) =
            Slider.update msg relativePosition model

        updatedColor =
            updateColor color updatedRelativePosition
    in
    ( updatedColor, Model updatedModel )


updateColor : Hsva -> Slider.Position -> Hsva
updateColor color relativePosition =
    let
        { saturation, value, alpha } =
            fromHsva color

        updatedHue =
            floor (relativePosition.x * 360)
    in
    HsvaRecord updatedHue saturation value alpha |> hsva


colorToRelativePosition : Hsva -> Slider.Position
colorToRelativePosition color =
    let
        { hue } =
            fromHsva color
    in
    Slider.Position (toFloat hue / 360) 0.5



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions (Model model) =
    Slider.subscriptions model |> Sub.map Slider



---- VIEW ----


view : Hsva -> Model -> Html Msg
view color (Model model) =
    let
        { hue } =
            fromHsva color

        relativePosition =
            colorToRelativePosition color

        thumbBackground =
            HsvaRecord hue 1 1 1 |> hsva |> hsvaToRgba |> rgbaToCss

        viewThumb =
            div [ style "backgroundColor" thumbBackground ]
                []

        viewBackground =
            div [ styles.class .hueGradient ]
                []
    in
    slider Slider viewThumb viewBackground relativePosition model
