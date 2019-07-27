port module Main exposing (main)

import Browser
import Color.Hsva as Hsva exposing (Hsva, hsva)
import Color.Rgba as Rgba exposing (Rgba, RgbaRecord)
import CssModules exposing (css)
import Html as H exposing (Html)
import Html.Events as HE
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
        (Random.float 0.3 1)
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


createModPackage : Hsva -> Cmd msg
createModPackage =
    Hsva.toRgba >> encodeRgba >> startWorker


encodeRgba : Rgba -> Encode.Value
encodeRgba color =
    let
        { red, green, blue, alpha } =
            color |> Rgba.toRecord
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
        H.text "Running..."

    else
        H.div []
            [ H.h1 []
                [ H.text "Gold Visibility Creator"
                ]
            , H.div [ styles.class .picker ]
                [ Picker.view picker color |> H.map Picker
                ]
            , H.button [ styles.class .button, HE.onClick CreateModPackage ]
                [ H.text "Create"
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
