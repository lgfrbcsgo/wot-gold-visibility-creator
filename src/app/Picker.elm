module Picker exposing (Model, Msg, init, subscriptions, update, view)

import Picker.SaturationValue as SaturationValue


type alias Model =
    SaturationValue.Model


init =
    SaturationValue.init


type alias Msg =
    SaturationValue.Msg


update =
    SaturationValue.update


subscriptions =
    SaturationValue.subscriptions


view =
    SaturationValue.view
