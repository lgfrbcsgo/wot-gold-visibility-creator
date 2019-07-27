module Picker.Alpha exposing (Model, Msg, init, subscriptions, update, view)

import Basics
import Color.Hsva as Hsva exposing (Hsva)
import Html as H exposing (Attribute, Html)
import Html.Attributes as HA
import Picker.Internal as Internal
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
    color |> Hsva.mapAlpha relativePosition.x


colorToRelativePosition : Hsva -> Slider.Position
colorToRelativePosition color =
    let
        { alpha } =
            color |> Hsva.toRecord
    in
    Slider.Position alpha 0.5



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions (Model model) =
    Slider.subscriptions model |> Sub.map Slider



---- VIEW ----


view : Model -> Hsva -> Html Msg
view (Model model) color =
    Internal.sliderInput Slider colorToRelativePosition viewThumb viewBackground model color


viewThumb : List (Attribute Slider.Msg) -> Hsva -> Html Slider.Msg
viewThumb extraAttributes color =
    let
        backgroundColor =
            color |> Hsva.toCss
    in
    H.div (extraAttributes ++ [ Internal.styles.class .checkerboard, HA.style "backgroundColor" backgroundColor ])
        []


viewBackground : List (Attribute Slider.Msg) -> Hsva -> Html Slider.Msg
viewBackground extraAttributes color =
    let
        gradientColor =
            color |> Hsva.mapAlpha 1 |> Hsva.toCss

        gradient =
            "linear-gradient(to right, transparent, " ++ gradientColor ++ ")"
    in
    H.div (extraAttributes ++ [ Internal.styles.class .checkerboard, HA.style "background" gradient ])
        []
