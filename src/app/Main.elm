port module Main exposing (main)

import Browser
import Color exposing (..)
import CssModules exposing (css)
import Html exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Json.Encode as Encode
import Picker as Picker
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
    ( Model (hsva (HsvaRecord 360 1 1 1)) Picker.init False
    , Random.generate RandomColor randomColor
    )


randomColor : Random.Generator Hsva
randomColor =
    Random.map hsva <|
        Random.map4 HsvaRecord
            (Random.int 0 360)
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

        RandomColor color ->
            ( { model | color = color }
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
subscriptions model =
    Sub.batch
        [ always FinishedModPackage |> finishedModPackage
        , Sub.map Picker <| Picker.subscriptions model.picker
        ]



---- STYLES ----


styles =
    css "./Main.css"
        { picker = "picker"
        }



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ div [ styles.class .picker ] [ Picker.view model.color model.picker |> map Picker ]
        , button [ onClick CreateModPackage ] [ text "Run" ]
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
