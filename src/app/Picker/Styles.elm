module Picker.Styles exposing (styles)

import CssModules exposing (css)


styles =
    css "./Picker/Styles.css"
        { picker = "picker"
        , slider = "slider"
        , matrix = "matrix"
        , checkerboard = "checkerboard"
        , fill = "fill"
        , saturationValueBackground = "saturation-value-background"
        , saturationValueBackgroundHack = "saturation-value-background-hack"
        , background = "background"
        , thumb = "thumb"
        , hueGradient = "hue-gradient"
        , whiteGradient = "white-gradient"
        , blackGradient = "black-gradient"
        }
