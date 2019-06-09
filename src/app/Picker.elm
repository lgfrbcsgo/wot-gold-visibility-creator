module Picker exposing (Model, Msg, init, update, view)

import Color exposing (..)
import Html exposing (Html, div)
import Picker.Hue as Hue
import Picker.SaturationValue as SaturationValue


type alias Model =
    { saturationValue : SaturationValue.Model
    , hue : Hue.Model
    }


init : Model
init =
    { saturationValue = SaturationValue.init
    , hue = Hue.init
    }


type Msg
    = SaturationValue SaturationValue.Msg
    | Hue Hue.Msg


update : Msg -> Hsva -> Model -> ( Hsva, Model )
update msg color model =
    case msg of
        SaturationValue saturationValueMsg ->
            let
                ( updatedColor, updatedModel ) =
                    SaturationValue.update saturationValueMsg color model.saturationValue
            in
            ( updatedColor, { model | saturationValue = updatedModel } )

        Hue hueMsg ->
            let
                ( updatedColor, updatedModel ) =
                    Hue.update hueMsg color model.hue
            in
            ( updatedColor, { model | hue = updatedModel } )


view : Hsva -> Model -> Html Msg
view color model =
    div []
        [ Html.map SaturationValue <| SaturationValue.view color model.saturationValue
        , Html.map Hue <| Hue.view color model.hue
        ]
