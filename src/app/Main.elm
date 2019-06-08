port module Main exposing (main)

import Browser
import Color exposing (..)
import CssModules exposing (css)
import Html exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Json.Encode as Encode
import Picker as Picker


port startWorker : Encode.Value -> Cmd msg


port finishedModPackage : (Decode.Value -> msg) -> Sub msg



---- MODEL ----


type alias Package =
    { color : RgbaRecord
    , blobUrl : String
    }


type alias Model =
    { color : Hsva
    , picker : Picker.Model
    , running : Bool
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model (hsva (HsvaRecord 360 1 1 1)) Picker.init False
    , Cmd.none
    )



---- UPDATE ----


type Msg
    = CreateModPackage
    | FinishedModPackage
    | Picker Picker.Msg


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        CreateModPackage ->
            case model.running of
                False ->
                    ( { model | running = True }
                    , createModPackage model.color
                    )

                True ->
                    ( model, Cmd.none )

        FinishedModPackage ->
            ( { model | running = False }
            , Cmd.none
            )

        Picker pickerMsg ->
            let
                ( updatedColor, updatedPickerModel ) =
                    Picker.update pickerMsg model.color model.picker
            in
            ( { model
                | color = updatedColor
                , picker = updatedPickerModel
              }
            , Cmd.none
            )


createModPackage : Hsva -> Cmd msg
createModPackage =
    hsvaToRgba >> encodeRgba >> startWorker


encodeRgba : Rgba -> Encode.Value
encodeRgba color =
    let
        { red, green, blue, alpha } =
            fromRgba color
    in
    Encode.object
        [ ( "red", Encode.int red )
        , ( "green", Encode.int green )
        , ( "blue", Encode.int blue )
        , ( "alpha", Encode.float alpha )
        ]



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions _ =
    always FinishedModPackage |> finishedModPackage



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
        , Picker.view model.color model.picker |> map Picker
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
