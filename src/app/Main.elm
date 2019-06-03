port module Main exposing (main)

import Browser
import Color exposing (..)
import CssModules exposing (css)
import Html exposing (..)
import Html.Events exposing (..)
import Json.Decode as D
import Json.Encode as E
import Picker as P


port startWorker : E.Value -> Cmd msg


port finishedModPackage : (D.Value -> msg) -> Sub msg



---- MODEL ----


type alias Package =
    { color : RgbaRecord
    , blobUrl : String
    }


type alias Model =
    { color : Hsva
    , picker : P.Model
    , running : Bool
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model (hsva (HsvaRecord 360 1.0 1.0 0.5)) P.init False
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = CreateModPackage
    | FinishedModPackage
    | Picker P.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CreateModPackage ->
            ( { model | running = True }
            , createModPackage model.color
            )

        FinishedModPackage ->
            ( { model | running = False }
            , Cmd.none
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


createModPackage : Hsva -> Cmd msg
createModPackage =
    hsvaToRgba >> encodeRgba >> startWorker


encodeRgba : Rgba -> E.Value
encodeRgba color =
    let
        { red, green, blue, alpha } =
            fromRgba color
    in
    E.object
        [ ( "red", E.int red )
        , ( "green", E.int green )
        , ( "blue", E.int blue )
        , ( "alpha", E.float alpha )
        ]



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ P.subscriptions |> Sub.map Picker
        , always FinishedModPackage |> finishedModPackage
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
        [ button [ styles.class .btn, styles.class .btnBlue, onClick CreateModPackage ] [ text "Run" ]
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
