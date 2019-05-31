port module Main exposing (main)

import Browser
import Html exposing (Html, button, div, text)
import Html.Events exposing (onClick)
import Json.Encode as E


port run : E.Value -> Cmd msg



---- MODEL ----


type alias Model =
    {}


init : ( Model, Cmd Msg )
init =
    ( {}, Cmd.none )



---- UPDATE ----


type Msg
    = Run


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Run ->
            ( model
            , run
                (E.object
                    [ ( "r", E.int 255 )
                    , ( "g", E.int 0 )
                    , ( "b", E.int 255 )
                    , ( "alpha", E.float 1 )
                    ]
                )
            )



---- VIEW ----


view : Model -> Html Msg
view model =
    div []
        [ button [ onClick Run ] [ text "Run" ]
        ]



---- PROGRAM ----


main : Program () Model Msg
main =
    Browser.element
        { view = view
        , init = \_ -> init
        , update = update
        , subscriptions = always Sub.none
        }
