module Styles exposing (styles)

import CssModules exposing (css)


styles =
    css "./Main.css"
        { colorPickerContainer = "color-picker-container"
        , btn = "btn"
        , btnBlue = "btn-blue"
        }
