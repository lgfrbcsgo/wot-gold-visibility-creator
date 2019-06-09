module Picker.Hue exposing (Model, Msg, init, update, view)

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
            hueToRelativePosition hue

        ( updatedRelativePosition, updatedModel ) =
            Slider.update msg relativePosition model

        updatedHue =
            floor (updatedRelativePosition.x * 360)

        updatedColor =
            HsvaRecord updatedHue saturation value alpha |> hsva
    in
    ( updatedColor, updatedModel )


hueToRelativePosition : Int -> Slider.Position
hueToRelativePosition hue =
    Slider.Position (toFloat hue / 360) 0.5



---- VIEW ----


view : Hsva -> Model -> Html Msg
view color model =
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
            div [ styles.class .hueGradient ] []
    in
    Slider.view viewThumb viewBackground relativePosition model
