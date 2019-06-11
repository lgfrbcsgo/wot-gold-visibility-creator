module Picker exposing (Model, Msg, init, subscriptions, update, view)

import Color exposing (..)
import Html exposing (Html, div)
import Picker.Alpha as Alpha
import Picker.Hue as Hue
import Picker.SaturationValue as SaturationValue


type alias Model =
    { hue : Hue.Model
    , saturationValue : SaturationValue.Model
    , alpha : Alpha.Model
    }


init : Model
init =
    { hue = Hue.init
    , saturationValue = SaturationValue.init
    , alpha = Alpha.init
    }


type Msg
    = Hue Hue.Msg
    | SaturationValue SaturationValue.Msg
    | Alpha Alpha.Msg


update : Msg -> Hsva -> Model -> ( Hsva, Model )
update msg color model =
    case msg of
        Hue hueMsg ->
            let
                ( updatedColor, updatedModel ) =
                    Hue.update hueMsg color model.hue
            in
            ( updatedColor, { model | hue = updatedModel } )

        SaturationValue saturationValueMsg ->
            let
                ( updatedColor, updatedModel ) =
                    SaturationValue.update saturationValueMsg color model.saturationValue
            in
            ( updatedColor, { model | saturationValue = updatedModel } )

        Alpha alphaMsg ->
            let
                ( updatedColor, updatedModel ) =
                    Alpha.update alphaMsg color model.alpha
            in
            ( updatedColor, { model | alpha = updatedModel } )


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Sub.map Hue <| Hue.subscriptions model.hue
        , Sub.map SaturationValue <| SaturationValue.subscriptions model.saturationValue
        , Sub.map Alpha <| Alpha.subscriptions model.alpha
        ]


view : Hsva -> Model -> Html Msg
view color model =
    div []
        [ Html.map Hue <| Hue.view color model.hue
        , Html.map SaturationValue <| SaturationValue.view color model.saturationValue
        , Html.map Alpha <| Alpha.view color model.alpha
        ]
