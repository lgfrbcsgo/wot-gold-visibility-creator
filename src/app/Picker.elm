module Picker exposing (renderPicker)

import Color exposing (Hsva)
import Html exposing (Html)
import Picker.SaturationLightness exposing (..)


renderPicker : Hsva -> (Hsva -> msg) -> Html msg
renderPicker =
    renderSaturationLightnessPicker
