module Picker.Styles exposing (styles)

import CssModules exposing (css)


styles =
    css "./Picker/Styles.css"
        { checkerboard = "checkerboard"
        , thumb = "thumb"
        , hueGradient = "hue-gradient"
        , slider = "slider"
        , sliderWrapper = "slider-wrapper"
        , matrixWrapper = "matrix-wrapper"
        , whiteGradient = "white-gradient"
        , blackGradient = "black-gradient"
        }
