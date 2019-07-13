module Picker.Hue exposing (Model, Msg, init, subscriptions, update, view)

import Basics
import Color exposing (..)
import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Picker.Shared exposing (sliderInput, styles)
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
        updatedHue =
            relativePosition.x
    in
    color |> mapHue updatedHue


colorToRelativePosition : Hsva -> Slider.Position
colorToRelativePosition color =
    let
        { hue } =
            color |> toHsva
    in
    Slider.Position hue 0.5



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions (Model model) =
    Slider.subscriptions model |> Sub.map Slider



---- VIEW ----


view : Hsva -> Model -> Html Msg
view color (Model model) =
    let
        relativePosition =
            colorToRelativePosition color

        thumbBackground =
            color
                |> mapSaturation 1
                |> mapValue 1
                |> mapAlpha 1
                |> toCss

        viewThumb =
            div [ style "backgroundColor" thumbBackground ]
                []

        viewBackground =
            div [ styles.class .hueGradient ]
                []
    in
    sliderInput Slider viewThumb viewBackground relativePosition model
