module Picker.SaturationValue exposing (Model, Msg, init, subscriptions, update, view)

import Basics
import Color exposing (..)
import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Picker.Shared exposing (matrix)
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
        updatedSaturation =
            relativePosition.x

        updatedValue =
            1 - relativePosition.y
    in
    color
        |> mapSaturation updatedSaturation
        |> mapValue updatedValue


colorToRelativePosition : Hsva -> Slider.Position
colorToRelativePosition color =
    let
        { saturation, value } =
            color |> toHsva
    in
    Slider.Position saturation (1 - value)



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
            color
                |> mapSaturation 1
                |> mapValue 1
                |> mapAlpha 1
                |> toCss

        gradient =
            "linear-gradient(to top, black, transparent), linear-gradient(to right, white, transparent), " ++ gradientColor

        thumbBackgroundColor =
            color |> mapAlpha 1 |> toCss

        viewThumb =
            div [ style "backgroundColor" thumbBackgroundColor ]
                []

        viewBackground =
            div [ style "background" gradient ]
                []
    in
    matrix Slider viewThumb viewBackground relativePosition model
