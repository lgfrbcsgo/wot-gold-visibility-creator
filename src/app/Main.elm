port module Main exposing (main)

import Browser
import Color exposing (..)
import CssModules exposing (css)
import Html exposing (..)
import Html.Events exposing (..)
import Picker exposing (..)


styles =
    css "./Main.css"
        { btn = "btn"
        , btnBlue = "btn-blue"
        }


port runWorker : Rgba -> Cmd msg


port revokeBlob : String -> Cmd msg


port saveBlob : { blobUrl : String, fileName : String } -> Cmd msg


port getPackage : (Package -> msg) -> Sub msg



---- MODEL ----


type alias Package =
    { color : Rgba
    , blobUrl : String
    }


type Worker
    = Initial
    | Running
    | Done Package


type alias Model =
    { color : Hsva
    , worker : Worker
    , previousColors : List Rgba
    }


init : () -> ( Model, Cmd Msg )
init flags =
    ( Model (Hsva 360 1.0 1.0 0.5) Initial []
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = CreatePackage
    | GotPackage Package
    | GotColor Hsva


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CreatePackage ->
            createPackage model

        GotPackage package ->
            ( { model | worker = Done package }
            , savePackage package
            )

        GotColor color ->
            ( { model | color = color }
            , Cmd.none
            )


createPackage : Model -> ( Model, Cmd Msg )
createPackage model =
    case model.worker of
        Initial ->
            ( { model | worker = Running }
            , runWorker <| convertHsvaToRgba model.color
            )

        Running ->
            ( model, Cmd.none )

        Done { color, blobUrl } ->
            ( Model model.color Running (color :: model.previousColors)
            , Cmd.batch
                [ revokeBlob blobUrl
                , runWorker <| convertHsvaToRgba model.color
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
        [ button [ styles.class .btn, styles.class .btnBlue, onClick CreatePackage ] [ text "Run" ]
        , renderPicker model.color GotColor
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
