port module Main exposing (main)

import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)


port startCreator : Color -> Cmd msg


port revokeBlob : String -> Cmd msg


port saveBlob : { blobUrl : String, fileName : String } -> Cmd msg


port getPackage : (Package -> msg) -> Sub msg



---- MODEL ----


type alias Color =
    { r : Int
    , g : Int
    , b : Int
    , alpha : Float
    }


type alias Package =
    { color : Color
    , blobUrl : String
    }


type Worker
    = Initial
    | Running
    | Done Package


type alias Model =
    { color : Color
    , worker : Worker
    , previousColors : List Color
    }


init : () -> ( Model, Cmd Msg )
init flags =
    ( { color =
            { r = 255
            , g = 0
            , b = 255
            , alpha = 1
            }
      , worker = Initial
      , previousColors = []
      }
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
            , startCreator model.color
            )

        Running ->
            ( model, Cmd.none )

        Done { color, blobUrl } ->
            ( { color = model.color
              , worker = Running
              , previousColors = color :: model.previousColors
              }
            , Cmd.batch
                [ revokeBlob blobUrl
                , startCreator model.color
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
