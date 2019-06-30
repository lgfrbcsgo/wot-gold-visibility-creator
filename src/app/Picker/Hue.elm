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
    = Msg Slider.Msg


update : Msg -> Hsva -> Model -> ( Hsva, Model )
update (Msg msg) color (Model model) =
    let
        { hue, saturation, value, alpha } =
            fromHsva color

        relativePosition =
            hueToRelativePosition hue

        ( updatedRelativePosition, updatedModel ) =
            Slider.update msg relativePosition model

        updatedHue =
            floor (updatedRelativePosition.x * 360)

        updatedColor =
            HsvaRecord updatedHue saturation value alpha |> hsva
    in
    ( updatedColor, Model updatedModel )


hueToRelativePosition : Int -> Slider.Position
hueToRelativePosition hue =
    Slider.Position (toFloat hue / 360) 0.5



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions (Model model) =
    Slider.subscriptions model |> Sub.map Msg



---- VIEW ----


view : Hsva -> Model -> Html Msg
view color (Model model) =
    let
        { hue } =
            fromHsva color

        relativePosition =
            hueToRelativePosition hue

        thumbBackground =
            HsvaRecord hue 1 1 1 |> hsva |> hsvaToRgba |> rgbaToCss

        viewThumb =
            div [ style "backgroundColor" thumbBackground ]
                []

        viewBackground =
            div [ styles.class .hueGradient ]
                []
    in
    slider Msg viewThumb viewBackground relativePosition model
