port module Main exposing (main)

import Browser
import Color exposing (..)
import CssModules exposing (css)
import Html exposing (..)
import Html.Events exposing (..)
import Picker as P



---- PORTS ----


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
    , picker : P.Model
    , worker : Worker
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model (Hsva 360 1.0 1.0 0.5) P.init Initial
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = CreatePackage
    | GotPackage Package
    | Picker P.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CreatePackage ->
            createPackage model

        GotPackage package ->
            ( { model | worker = Done package }
            , savePackage package
            )

        Picker pickerMsg ->
            let
                ( picker, color ) =
                    P.update model.color pickerMsg model.picker
            in
            ( { model
                | color = color
                , picker = picker
              }
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

        Done { blobUrl } ->
            ( { model | worker = Running }
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
subscriptions _ =
    Sub.batch
        [ P.subscriptions |> Sub.map Picker
        , getPackage GotPackage
        ]



---- STYLES ----


styles =
    css "./Main.css"
        { btn = "btn"
        , btnBlue = "btn-blue"
        }



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ button [ styles.class .btn, styles.class .btnBlue, onClick CreatePackage ] [ text "Run" ]
        , P.view model.color model.picker |> map Picker
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
