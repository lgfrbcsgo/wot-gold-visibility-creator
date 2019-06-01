port module Main exposing (main)

import Browser
import Html exposing (..)
import Html.Events exposing (..)


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
    { color : RGBA
    , worker : Worker
    , previousColors : List RGBA
    }


init : () -> ( Model, Cmd Msg )
init flags =
    ( Model (RGBA 0.0 1.0 0.0 1.0) Initial []
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
        [ button [ onClick CreatePackage ] [ text "Run" ]
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
