module Picker exposing (Model, Msg, init, update, view)

import Picker.SaturationValue as SaturationValue


type alias Model =
    SaturationValue.Model


init =
    SaturationValue.init


type alias Msg =
    SaturationValue.Msg


update =
    SaturationValue.update


view =
    SaturationValue.view
