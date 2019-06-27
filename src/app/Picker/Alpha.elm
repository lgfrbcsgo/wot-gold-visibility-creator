module Picker.Alpha exposing (Model, Msg, init, subscriptions, update, view)

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

        viewThumb =
            div [ styles.class .thumb, styles.class .checkerboard ]
                [ div
                    [ styles.class .fill, style "backgroundColor" (color |> hsvaToRgba |> rgbaToCss) ]
                    []
                ]

        viewBackground =
            div [ styles.class .checkerboard, styles.class .background ]
                [ div [ styles.class .fill, style "background" gradient ] []
                ]
    in
    div [ styles.class .slider ]
        [ Slider.view viewThumb viewBackground relativePosition model
        ]
        |> Html.map Msg
