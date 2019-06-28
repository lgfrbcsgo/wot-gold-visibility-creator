module Picker.Styles exposing (styles)

import CssModules exposing (css)


styles =
    css "./Picker/Styles.css"
        { picker = "picker"
        , slider = "slider"
        , matrix = "matrix"
        , background = "background"
        , thumb = "thumb"
        , checkerboard = "checkerboard"
        , hueGradient = "hue-gradient"
        , blackGradient = "black-gradient"
        }
