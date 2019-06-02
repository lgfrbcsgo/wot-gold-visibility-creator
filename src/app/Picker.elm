module Picker exposing (Model, Msg, init, subscriptions, update, view)

import Picker.SaturationLightness as SL


type alias Model =
    SL.Model


init =
    SL.init


type alias Msg =
    SL.Msg


update =
    SL.update


subscriptions =
    SL.subscriptions


view =
    SL.view
