module Picker.SaturationLightness exposing (Model, Msg, init, subscriptions, update, view)

import Basics
import Browser.Events exposing (onMouseUp)
import Color exposing (Hsva, convertHsvaToRgba, sanitizeHsva, toCssColor)
import Html exposing (Html, div)
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
    = MouseDown MousePosition
    | MouseMove MousePosition
    | MouseUp


type alias MousePosition =
    { x : Int
    , y : Int
    , width : Int
    , height : Int
    }


update : Hsva -> Msg -> Model -> ( Model, Hsva )
update color msg model =
    case msg of
        MouseDown position ->
            ( True, updateColor position color )

        MouseMove position ->
            case model of
                True ->
                    ( True, updateColor position color )

                False ->
                    ( False, color )

        MouseUp ->
            ( False, color )


updateColor : MousePosition -> Hsva -> Hsva
updateColor { x, y, width, height } color =
    { color
        | saturation = toFloat x / toFloat width
        , value = 1.0 - (toFloat y / toFloat height)
    }
        |> sanitizeHsva



---- SUBSCRIPTIONS ----


subscriptions : Sub Msg
subscriptions =
    onMouseUp <| D.succeed MouseUp



---- VIEW ----


view : Hsva -> Model -> Html Msg
view color model =
    let
        svgOpacity =
            String.fromFloat color.alpha

        gradientColor =
            Hsva color.hue 1.0 1.0 1.0 |> convertHsvaToRgba |> toCssColor
    in
    div
        (case model of
            True ->
                [ styles.class .checkerboard, onMouseMove MouseMove ]

            False ->
                [ styles.class .checkerboard, onMouseDown MouseDown ]
        )
        [ svg [ height "200px", width "500px", opacity svgOpacity ]
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


onMouseDown : (MousePosition -> Msg) -> Attribute Msg
onMouseDown =
    decodeMouseEvent >> on "mousedown"


onMouseMove : (MousePosition -> Msg) -> Attribute Msg
onMouseMove =
    decodeMouseEvent >> on "mousemove"


decodeMouseEvent : (MousePosition -> Msg) -> D.Decoder Msg
decodeMouseEvent toMsg =
    D.map toMsg <|
        D.map4 MousePosition
            (D.field "offsetX" D.int)
            (D.field "offsetY" D.int)
            (D.field "offsetWidth" D.int |> D.at [ "currentTarget" ])
            (D.field "offsetHeight" D.int |> D.at [ "currentTarget" ])
