port module Main exposing (main)

import Browser
import Color exposing (..)
import Html exposing (..)
import Html.Events exposing (..)
import Picker.SaturationLightness exposing (..)
import Styles exposing (..)


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
    { color : Rgba
    , worker : Worker
    , previousColors : List Rgba
    }


init : () -> ( Model, Cmd Msg )
init flags =
    ( Model (Rgba 255 100 0 1.0) Initial []
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = CreatePackage
    | GotPackage Package
    | GotColor Rgba


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
            ( model, Cmd.none )


createPackage : Model -> ( Model, Cmd Msg )
createPackage model =
    case model.worker of
        Initial ->
            ( { model | worker = Running }
            , runWorker model.color
            )

        Running ->
            ( model, Cmd.none )

        Done { color, blobUrl } ->
            ( Model model.color Running (color :: model.previousColors)
            , Cmd.batch
                [ revokeBlob blobUrl
                , runWorker model.color
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
        , renderSaturationLightnessPicker (fromRgba model.color) (\color -> toRgba color |> GotColor)
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
