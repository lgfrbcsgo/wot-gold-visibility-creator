module Picker.Alpha exposing (Model, Msg, init, subscriptions, update, view)

import Basics
import Color exposing (..)
import Html exposing (Attribute, Html, div)
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


update : Msg -> Model -> Hsva -> ( Hsva, Model )
update (Slider msg) (Model model) color =
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
    color |> mapAlpha relativePosition.x


colorToRelativePosition : Hsva -> Slider.Position
colorToRelativePosition color =
    let
        { alpha } =
            color |> toHsva
    in
    Slider.Position alpha 0.5



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions (Model model) =
    Slider.subscriptions model |> Sub.map Slider



---- VIEW ----


view : Model -> Hsva -> Html Msg
view (Model model) color =
    sliderInput Slider colorToRelativePosition viewThumb viewBackground model color


viewThumb : List (Attribute Slider.Msg) -> Hsva -> Html Slider.Msg
viewThumb extraAttributes color =
    let
        backgroundColor =
            color |> toCss
    in
    div (extraAttributes ++ [ styles.class .checkerboard, style "backgroundColor" backgroundColor ])
        []


viewBackground : List (Attribute Slider.Msg) -> Hsva -> Html Slider.Msg
viewBackground extraAttributes color =
    let
        gradientColor =
            color |> mapAlpha 1 |> toCss

        gradient =
            "linear-gradient(to right, transparent, " ++ gradientColor ++ ")"
    in
    div (extraAttributes ++ [ styles.class .checkerboard, style "background" gradient ])
        []
