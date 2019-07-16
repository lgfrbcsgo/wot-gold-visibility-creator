port module Main exposing (main)

import Browser
import Color exposing (..)
import CssModules exposing (css)
import Html exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Json.Encode as Encode
import Picker
import Random


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
    ( Model (hsva 360 1 1 1) Picker.init False
    , Random.generate RandomColor randomColor
    )


randomColor : Random.Generator Hsva
randomColor =
    Random.map4 hsva
        (Random.float 0 1)
        (Random.float 0.5 1)
        (Random.float 0.65 1)
        (Random.float 1 1)



---- UPDATE ----


type Msg
    = CreateModPackage
    | FinishedModPackage
    | Picker Picker.Msg
    | RandomColor Hsva


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        RandomColor color ->
            ( { model | color = color }
            , Cmd.none
            )

        Picker pickerMsg ->
            let
                ( updatedColor, updatedPickerModel ) =
                    Picker.update pickerMsg model.picker model.color
            in
            ( { model
                | color = updatedColor
                , picker = updatedPickerModel
              }
            , Cmd.none
            )

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


createModPackage : Color any -> Cmd msg
createModPackage =
    encodeRgba >> startWorker


encodeRgba : Color any -> Encode.Value
encodeRgba color =
    let
        { red, green, blue, alpha } =
            color |> toRgba
    in
    Encode.object
        [ ( "red", red * 255 |> round |> Encode.int )
        , ( "green", green * 255 |> round |> Encode.int )
        , ( "blue", blue * 255 |> round |> Encode.int )
        , ( "alpha", alpha |> Encode.float )
        ]



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions { picker } =
    Sub.batch
        [ always FinishedModPackage |> finishedModPackage
        , Sub.map Picker <| Picker.subscriptions picker
        ]



---- STYLES ----


styles =
    css "./Main.css"
        { picker = "picker"
        , button = "button"
        }



---- VIEW ----


view : Model -> Html Msg
view { picker, color, running } =
    if running then
        text "Running..."

    else
        div []
            [ div [ styles.class .picker ]
                [ Picker.view picker color |> map Picker
                ]
            , button [ styles.class .button, onClick CreateModPackage ]
                [ text "Run"
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
