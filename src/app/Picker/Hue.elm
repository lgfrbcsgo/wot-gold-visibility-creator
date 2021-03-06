module Picker.Hue exposing (Model, Msg, init, subscriptions, update, view)

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
    let
        updatedHue =
            relativePosition.x
    in
    color |> Hsva.mapHue updatedHue


colorToRelativePosition : Hsva -> Slider.Position
colorToRelativePosition color =
    let
        { hue } =
            color |> Hsva.toRecord
    in
    Slider.Position hue 0.5



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
            color
                |> Hsva.mapSaturation 1
                |> Hsva.mapValue 1
                |> Hsva.mapAlpha 1
                |> Hsva.toCss
    in
    H.div (extraAttributes ++ [ HA.style "backgroundColor" backgroundColor ])
        []


viewBackground : List (Attribute Slider.Msg) -> Hsva -> Html Slider.Msg
viewBackground extraAttributes _ =
    H.div (extraAttributes ++ [ Internal.styles.class .hueGradient ])
        []
