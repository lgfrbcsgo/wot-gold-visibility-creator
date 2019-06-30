module Picker.SaturationValue exposing (Model, Msg, init, subscriptions, update, view)

import Basics
import Color exposing (..)
import Html exposing (Html, div)
import Html.Attributes exposing (style)
import Picker.Shared exposing (matrix, styles)
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
            saturationValueToRelativePosition saturation value

        ( updatedRelativePosition, updatedModel ) =
            Slider.update msg relativePosition model

        updatedColor =
            HsvaRecord hue updatedRelativePosition.x (1 - updatedRelativePosition.y) alpha |> hsva
    in
    ( updatedColor, Model updatedModel )


saturationValueToRelativePosition : Float -> Float -> Slider.Position
saturationValueToRelativePosition saturation value =
    Slider.Position saturation (1 - value)



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions (Model model) =
    Slider.subscriptions model |> Sub.map Msg



---- VIEW ----


view : Hsva -> Model -> Html Msg
view color (Model model) =
    let
        { hue, saturation, value } =
            fromHsva color

        relativePosition =
            saturationValueToRelativePosition saturation value

        gradientColor =
            HsvaRecord hue 1 1 1 |> hsva |> hsvaToRgba |> rgbaToCss

        gradient =
            "linear-gradient(to top, black, transparent), linear-gradient(to right, white, transparent), " ++ gradientColor

        thumbBackgroundColor =
            HsvaRecord hue saturation value 1 |> hsva |> hsvaToRgba |> rgbaToCss

        viewThumb =
            div [ style "backgroundColor" thumbBackgroundColor ]
                []

        viewBackground =
            div [ style "background" gradient ]
                []
    in
    matrix Msg viewThumb viewBackground relativePosition model
