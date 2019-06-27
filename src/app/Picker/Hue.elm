module Picker.Hue exposing (Model, Msg, init, subscriptions, update, view)

import Basics
import Color exposing (..)
import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Picker.Styles exposing (styles)
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
            div [ styles.class .thumb, style "backgroundColor" thumbBackground ] []

        viewBackground =
            div [ styles.class .hueGradient, styles.class .fill, styles.class .background ] []
    in
    div [ styles.class .slider ]
        [ Slider.view viewThumb viewBackground relativePosition model
        ]
        |> Html.map Msg
