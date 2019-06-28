module Picker.Styles exposing (styles)

import CssModules exposing (css)


styles =
    css "./Picker/Styles.css"
        { picker = "picker"
        , slider = "slider"
        , matrix = "matrix"
        , checkerboard = "checkerboard"
        , fill = "fill"
        , background = "background"
        , thumb = "thumb"
        , hueGradient = "hue-gradient"
        , blackGradient = "black-gradient"
        }
