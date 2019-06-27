module Picker exposing (Model, Msg, init, subscriptions, update, view)

import Color exposing (..)
import Html exposing (Html, div)
import Picker.Alpha as Alpha
import Picker.Hue as Hue
import Picker.SaturationValue as SaturationValue
import Picker.Styles exposing (styles)


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
            Hue.update hueMsg color model.hue
                |> Tuple.mapSecond (\updatedModel -> { model | hue = updatedModel })

        SaturationValue saturationValueMsg ->
            SaturationValue.update saturationValueMsg color model.saturationValue
                |> Tuple.mapSecond (\updatedModel -> { model | saturationValue = updatedModel })

        Alpha alphaMsg ->
            Alpha.update alphaMsg color model.alpha
                |> Tuple.mapSecond (\updatedModel -> { model | alpha = updatedModel })


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Hue.subscriptions model.hue |> Sub.map Hue
        , SaturationValue.subscriptions model.saturationValue |> Sub.map SaturationValue
        , Alpha.subscriptions model.alpha |> Sub.map Alpha
        ]


view : Hsva -> Model -> Html Msg
view color model =
    div [ styles.class .picker ]
        [ Hue.view color model.hue |> Html.map Hue
        , SaturationValue.view color model.saturationValue |> Html.map SaturationValue
        , Alpha.view color model.alpha |> Html.map Alpha
        ]
