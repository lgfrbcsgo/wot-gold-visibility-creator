module Picker.Styles exposing (styles)

import CssModules exposing (css)


styles =
    css "./Picker/Styles.css"
        { checkerboard = "checkerboard"
        , dragContainer = "drag-container"
        , thumb = "thumb"
        }
