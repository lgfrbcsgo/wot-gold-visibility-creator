module Picker.Alpha exposing (Model, Msg, init, subscriptions, update, view)

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
            alphaToRelativePosition alpha

        ( updatedRelativePosition, updatedModel ) =
            Slider.update msg relativePosition model

        updatedColor =
            HsvaRecord hue saturation value updatedRelativePosition.x |> hsva
    in
    ( updatedColor, Model updatedModel )


alphaToRelativePosition : Float -> Slider.Position
alphaToRelativePosition alpha =
    Slider.Position alpha 0.5



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions (Model model) =
    Slider.subscriptions model |> Sub.map Msg



---- VIEW ----


view : Hsva -> Model -> Html Msg
view color (Model model) =
    let
        { hue, saturation, value, alpha } =
            fromHsva color

        relativePosition =
            alphaToRelativePosition alpha

        gradientColor =
            HsvaRecord hue saturation value 1 |> hsva |> hsvaToRgba |> rgbaToCss

        gradient =
            "linear-gradient(to right, transparent, " ++ gradientColor ++ ")"

        thumbBackgroundColor =
            color |> hsvaToRgba |> rgbaToCss

        viewThumb =
            div [ styles.class .checkerboard, style "backgroundColor" thumbBackgroundColor ]
                []

        viewBackground =
            div [ styles.class .checkerboard, style "background" gradient ]
                []
    in
    slider Msg viewThumb viewBackground relativePosition model
