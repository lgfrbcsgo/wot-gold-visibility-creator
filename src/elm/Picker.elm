module Picker exposing (renderPicker)

import Color exposing (Color)
import Html exposing (Html)
import Picker.SaturationLightness exposing (..)


renderPicker : Color -> (Color -> msg) -> Html msg
renderPicker =
    renderSaturationLightnessPicker
