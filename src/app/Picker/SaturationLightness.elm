module Picker.SaturationLightness exposing (Model, Msg, init, subscriptions, update, view)

import Basics
import Browser.Events exposing (onMouseUp)
import Color exposing (Hsva, HsvaRecord, fromHsva, hsva, hsvaToRgba, rgbaToCss)
import Html exposing (Html, div)
import Html.Attributes
import Html.Events exposing (on)
import Json.Decode as D
import Picker.Styles exposing (styles)
import Svg as S exposing (..)
import Svg.Attributes as A exposing (..)



---- Model ----


type alias Model =
    Bool


init : Model
init =
    False



---- UPDATE ----


type Msg
    = MouseDown MouseDownPosition
    | MouseMove MouseMovePosition
    | MouseUp


type alias MouseDownPosition =
    { svgX : Int
    , svgY : Int
    , svgWidth : Int
    , svgHeight : Int
    }


type alias MouseMovePosition =
    { containerX : Int
    , containerY : Int
    , containerWidth : Int
    , containerHeight : Int
    , svgWidth : Int
    , svgHeight : Int
    }


update : Hsva -> Msg -> Model -> ( Model, Hsva )
update color msg model =
    case msg of
        MouseDown position ->
            ( True, updateColorMouseDown position color )

        MouseMove position ->
            case model of
                True ->
                    ( True, updateColorMouseMove position color )

                False ->
                    ( False, color )

        MouseUp ->
            ( False, color )


updateColorMouseDown : MouseDownPosition -> Hsva -> Hsva
updateColorMouseDown { svgX, svgY, svgWidth, svgHeight } color =
    let
        hsvaRecord =
            fromHsva color
    in
    hsva
        { hsvaRecord
            | saturation = toFloat svgX / toFloat svgWidth
            , value = 1.0 - toFloat svgY / toFloat svgHeight
        }


updateColorMouseMove : MouseMovePosition -> Hsva -> Hsva
updateColorMouseMove { containerX, containerY, containerWidth, containerHeight, svgWidth, svgHeight } color =
    let
        xOffset =
            toFloat (svgWidth - containerWidth) / 2 + toFloat containerX

        yOffset =
            toFloat (svgHeight - containerHeight) / 2 + toFloat containerY

        hsvaRecord =
            fromHsva color
    in
    hsva
        { hsvaRecord
            | saturation = xOffset / toFloat svgWidth
            , value = 1.0 - yOffset / toFloat svgHeight
        }



---- SUBSCRIPTIONS ----


subscriptions : Sub Msg
subscriptions =
    onMouseUp <| D.succeed MouseUp



---- VIEW ----


view : Hsva -> Model -> Html Msg
view color model =
    let
        alpha =
            color |> fromHsva |> .alpha

        hue =
            color |> fromHsva |> .hue

        saturation =
            color |> fromHsva |> .saturation

        value =
            color |> fromHsva |> .value

        svgOpacity =
            alpha |> String.fromFloat

        gradientColor =
            HsvaRecord hue 1.0 1.0 1.0 |> hsva |> hsvaToRgba |> rgbaToCss

        knobTopPercent =
            String.fromFloat ((1.0 - value) * 100) ++ "%"

        knobLeftPercent =
            String.fromFloat (saturation * 100) ++ "%"
    in
    div
        (case model of
            True ->
                [ styles.class .dragContainer, onMouseMove MouseMove ]

            False ->
                [ styles.class .dragContainer ]
        )
        [ div [ styles.class .checkerboard, onMouseDown MouseDown ]
            [ div [ styles.class .knob, Html.Attributes.style "top" knobTopPercent, Html.Attributes.style "left" knobLeftPercent ] []
            , svg [ height "100%", width "100%", opacity svgOpacity ]
                [ defs []
                    [ linearGradient [ id "gradient-to-black", x1 "0%", x2 "0%", y1 "0%", y2 "100%" ]
                        [ stop [ offset "0%", stopColor "white" ] []
                        , stop [ offset "100%", stopColor "black" ] []
                        ]
                    , linearGradient [ id "gradient-to-color", x1 "0%", x2 "100%", y1 "0%", y2 "0%" ]
                        [ stop [ offset "0%", stopColor "white" ] []
                        , stop [ offset "100%", stopColor gradientColor ] []
                        ]
                    , rect [ id "gradient-to-black-rect", width "100%", height "100%", fill "url(#gradient-to-black)" ] []
                    , rect [ id "gradient-to-color-rect", width "100%", height "100%", fill "url(#gradient-to-color)" ] []
                    , S.filter [ id "gradient-multiply", x "0%", y "0%", width "100%", height "100%", colorInterpolationFilters "sRGB" ]
                        [ feImage [ width "100%", height "100%", result "black", xlinkHref "#gradient-to-black-rect" ] []
                        , feImage [ width "100%", height "100%", result "color", xlinkHref "#gradient-to-color-rect" ] []
                        , feBlend [ in_ "black", in2 "color", mode "multiply" ] []
                        ]
                    ]
                , rect [ A.filter "url(#gradient-multiply)", x "0", y "0", width "100%", height "100%" ] []
                ]
            ]
        ]


onMouseDown : (MouseDownPosition -> Msg) -> Attribute Msg
onMouseDown =
    decodeMouseDownEvent >> on "mousedown"


onMouseMove : (MouseMovePosition -> Msg) -> Attribute Msg
onMouseMove =
    decodeMouseMoveEvent >> on "mousemove"


decodeMouseDownEvent : (MouseDownPosition -> Msg) -> D.Decoder Msg
decodeMouseDownEvent toMsg =
    D.map toMsg <|
        D.map4 MouseDownPosition
            (D.field "offsetX" D.int)
            (D.field "offsetY" D.int)
            (D.int |> D.at [ "currentTarget", "offsetWidth" ])
            (D.int |> D.at [ "currentTarget", "offsetHeight" ])


decodeMouseMoveEvent : (MouseMovePosition -> Msg) -> D.Decoder Msg
decodeMouseMoveEvent toMsg =
    D.map toMsg <|
        D.map6 MouseMovePosition
            (D.field "offsetX" D.int)
            (D.field "offsetY" D.int)
            (D.int |> D.at [ "currentTarget", "offsetWidth" ])
            (D.int |> D.at [ "currentTarget", "offsetHeight" ])
            (D.int |> D.at [ "currentTarget", "children", "0", "offsetWidth" ])
            (D.int |> D.at [ "currentTarget", "children", "0", "offsetHeight" ])
