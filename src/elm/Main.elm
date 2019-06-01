port module Main exposing (main)

import Browser
import Color exposing (Color, hsla, rgba, toCssString, toHsla, toRgba)
import CssModules exposing (css)
import Html exposing (..)
import Html.Events exposing (..)
import Svg
import Svg.Attributes


port runWorker : RGBA -> Cmd msg


port revokeBlob : String -> Cmd msg


port saveBlob : { blobUrl : String, fileName : String } -> Cmd msg


port getPackage : (Package -> msg) -> Sub msg


styles =
    css "./Main.css"
        { colorPickerContainer = "color-picker-container"
        }



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
    ( Model (rgba 1.0 1.0 0.0 0.5) Initial []
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
        { hue, alpha } =
            toHsla color
    in
    div
        [ styles.class .colorPickerContainer ]
        [ Svg.svg
            [ Svg.Attributes.width "100%"
            , Svg.Attributes.height "100%"
            , Svg.Attributes.opacity <| String.fromFloat alpha
            ]
            [ Svg.defs []
                [ Svg.linearGradient
                    [ Svg.Attributes.id "toBlack"
                    , Svg.Attributes.x1 "0%"
                    , Svg.Attributes.x2 "0%"
                    , Svg.Attributes.y1 "0%"
                    , Svg.Attributes.y2 "100%"
                    ]
                    [ Svg.stop
                        [ Svg.Attributes.offset "0%"
                        , Svg.Attributes.stopColor "white"
                        ]
                        []
                    , Svg.stop
                        [ Svg.Attributes.offset "100%"
                        , Svg.Attributes.stopColor "black"
                        ]
                        []
                    ]
                , Svg.linearGradient
                    [ Svg.Attributes.id "toHue"
                    , Svg.Attributes.x1 "0%"
                    , Svg.Attributes.x2 "100%"
                    , Svg.Attributes.y1 "0%"
                    , Svg.Attributes.y2 "0%"
                    ]
                    [ Svg.stop
                        [ Svg.Attributes.offset "0%"
                        , Svg.Attributes.stopColor "white"
                        ]
                        []
                    , Svg.stop
                        [ Svg.Attributes.offset "100%"
                        , Svg.Attributes.stopColor <| toCssString <| hsla hue 1.0 0.5 1.0
                        ]
                        []
                    ]
                ]
            , Svg.rect
                [ Svg.Attributes.width "100%"
                , Svg.Attributes.height "100%"
                , Svg.Attributes.fill "url(#toBlack)"
                ]
                []
            , Svg.rect
                [ Svg.Attributes.width "100%"
                , Svg.Attributes.height "100%"
                , Svg.Attributes.fill "url(#toHue)"
                , Svg.Attributes.style "mix-blend-mode: multiply"
                ]
                []
            ]
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
