module Picker exposing (Model, Msg, init, subscriptions, update, view)

import Color.Hsva exposing (Hsva)
import Html as H exposing (Html)
import Picker.Alpha as Alpha
import Picker.Hue as Hue
import Picker.Internal as Internal
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


update : Msg -> Model -> Hsva -> ( Hsva, Model )
update msg model color =
    case msg of
        Hue hueMsg ->
            Hue.update hueMsg model.hue color
                |> Tuple.mapSecond (mapHue model)

        SaturationValue saturationValueMsg ->
            SaturationValue.update saturationValueMsg model.saturationValue color
                |> Tuple.mapSecond (mapSaturationValue model)

        Alpha alphaMsg ->
            Alpha.update alphaMsg model.alpha color
                |> Tuple.mapSecond (mapAlpha model)


mapHue : Model -> Hue.Model -> Model
mapHue model hue =
    { model | hue = hue }


mapSaturationValue : Model -> SaturationValue.Model -> Model
mapSaturationValue model saturationValue =
    { model | saturationValue = saturationValue }


mapAlpha : Model -> Alpha.Model -> Model
mapAlpha model alpha =
    { model | alpha = alpha }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Hue.subscriptions model.hue |> Sub.map Hue
        , SaturationValue.subscriptions model.saturationValue |> Sub.map SaturationValue
        , Alpha.subscriptions model.alpha |> Sub.map Alpha
        ]


view : Model -> Hsva -> Html Msg
view model color =
    H.div [ Internal.styles.class .picker ]
        [ Hue.view model.hue color |> H.map Hue
        , SaturationValue.view model.saturationValue color |> H.map SaturationValue
        , Alpha.view model.alpha color |> H.map Alpha
        ]
