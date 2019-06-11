module Picker.Alpha exposing (Model, Msg, init, subscriptions, update, view)

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
            alphaToRelativePosition alpha

        ( updatedRelativePosition, updatedModel ) =
            Slider.update msg relativePosition model

        updatedColor =
            HsvaRecord hue saturation value updatedRelativePosition.x |> hsva
    in
    ( updatedColor, updatedModel )


alphaToRelativePosition : Float -> Slider.Position
alphaToRelativePosition alpha =
    Slider.Position alpha 0.5



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions =
    Slider.subscriptions



---- VIEW ----


view : Hsva -> Model -> Html Msg
view color model =
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
                    [ style "backgroundColor" (color |> hsvaToRgba |> rgbaToCss)
                    , style "height" "100%"
                    , style "width" "100%"
                    ]
                    []
                ]

        viewBackground =
            div [ styles.class .checkerboard ]
                [ div [ styles.class .slider, style "background" gradient ] []
                ]
    in
    div [ styles.class .sliderWrapper ]
        [ Slider.view viewThumb viewBackground relativePosition model
        ]
