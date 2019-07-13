module Picker.Alpha exposing (Model, Msg, init, subscriptions, update, view)

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


view : Hsva -> Model -> Html Msg
view color (Model model) =
    let
        relativePosition =
            colorToRelativePosition color

        gradientColor =
            color |> mapAlpha 1 |> toCss

        gradient =
            "linear-gradient(to right, transparent, " ++ gradientColor ++ ")"

        thumbBackgroundColor =
            color |> toCss

        viewThumb =
            div [ styles.class .checkerboard, style "backgroundColor" thumbBackgroundColor ]
                []

        viewBackground =
            div [ styles.class .checkerboard, style "background" gradient ]
                []
    in
    sliderInput Slider viewThumb viewBackground relativePosition model
