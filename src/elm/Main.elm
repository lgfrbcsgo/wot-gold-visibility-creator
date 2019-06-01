port module Main exposing (main)

import Browser
import Color exposing (Color, hsla, rgba, toCssString, toHsla, toRgba)
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Svg exposing (Svg, defs, linearGradient, rect, stop, svg)
import Svg.Attributes exposing (fill, height, id, offset, stopColor, style, width, x1, x2, y1, y2)


port runWorker : RGBA -> Cmd msg


port revokeBlob : String -> Cmd msg


port saveBlob : { blobUrl : String, fileName : String } -> Cmd msg


port getPackage : (Package -> msg) -> Sub msg



---- MODEL ----


type alias RGBA =
    { red : Float
    , green : Float
    , blue : Float
    , alpha : Float
    }


type alias Package =
    { color : RGBA
    , blobUrl : String
    }


type Worker
    = Initial
    | Running
    | Done Package


type alias Model =
    { color : Color
    , worker : Worker
    , previousColors : List RGBA
    }


init : () -> ( Model, Cmd Msg )
init flags =
    ( Model (rgba 1.0 1.0 0.0 1.0) Initial []
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = CreatePackage
    | GotPackage Package


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CreatePackage ->
            createPackage model

        GotPackage package ->
            ( { model | worker = Done package }
            , savePackage package
            )


createPackage : Model -> ( Model, Cmd Msg )
createPackage model =
    case model.worker of
        Initial ->
            ( { model | worker = Running }
            , runWorker (toRgba model.color)
            )

        Running ->
            ( model, Cmd.none )

        Done { color, blobUrl } ->
            ( Model model.color Running (color :: model.previousColors)
            , Cmd.batch
                [ revokeBlob blobUrl
                , runWorker (toRgba model.color)
                ]
            )


savePackage : Package -> Cmd Msg
savePackage package =
    saveBlob
        { blobUrl = package.blobUrl
        , fileName = "goldvisibility.color.wotmod"
        }



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    getPackage GotPackage



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick CreatePackage ] [ text "Run" ]
        , renderGradient model.color
        ]


renderGradient : Color -> Html Msg
renderGradient color =
    let
        { hue } =
            toHsla color
    in
    svg [ width "500", height "500" ]
        [ defs []
            [ linearGradient [ id "toBlack", x1 "0%", x2 "0%", y1 "0%", y2 "100%" ]
                [ stop [ offset "0%", stopColor "white" ] []
                , stop [ offset "100%", stopColor "black" ] []
                ]
            , linearGradient [ id "toHue", x1 "0%", x2 "100%", y1 "0%", y2 "0%" ]
                [ stop [ offset "0%", stopColor "white" ] []
                , stop [ offset "100%", stopColor <| toCssString <| hsla hue 1.0 0.5 1.0 ] []
                ]
            ]
        , rect [ width "100%", height "100%", fill "url(#toBlack)" ] []
        , rect [ width "100%", height "100%", fill "url(#toHue)", style "mix-blend-mode: multiply" ] []
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = init
        , update = update
        , subscriptions = subscriptions
        }
