module Picker.SaturationLightness exposing (renderSaturationLightnessPicker)

import Color exposing (..)
import Html exposing (Html, div)
import Html.Events exposing (on)
import Json.Decode as D
import Picker.Styles exposing (styles)
import Svg as S exposing (..)
import Svg.Attributes as A exposing (..)


type alias ClickPosition =
    { offsetX : Int
    , offsetY : Int
    , width : Int
    , height : Int
    }


renderSaturationLightnessPicker : Hsva -> (Hsva -> msg) -> Html msg
renderSaturationLightnessPicker ({ hue, alpha } as color) msg =
    let
        gradientColor =
            Hsva hue 1.0 1.0 1.0 |> fromHsva
    in
    div [ styles.class .checkerboard, handleClick color msg ]
        [ svg [ height "200px", width "500px", opacity <| String.fromFloat alpha ]
            [ defs []
                [ linearGradient [ id "gradient-to-black", x1 "0%", x2 "0%", y1 "0%", y2 "100%" ]
                    [ stop [ offset "0%", stopColor "white" ] []
                    , stop [ offset "100%", stopColor "black" ] []
                    ]
                , linearGradient [ id "gradient-to-color", x1 "0%", x2 "100%", y1 "0%", y2 "0%" ]
                    [ stop [ offset "0%", stopColor "white" ] []
                    , stop [ offset "100%", stopColor <| toCssColor gradientColor ] []
                    ]
                , rect [ id "gradient-to-black-rect", width "100%", height "100%", fill "url(#gradient-to-black)" ] []
                , rect [ id "gradient-to-color-rect", width "100%", height "100%", fill "url(#gradient-to-color)" ] []
                , S.filter [ id "gradient-multiply", x "0%", y "0%", width "100%", height "100%", colorInterpolationFilters "sRGB" ]
                    [ feImage [ width "100%", height "100%", result "black", xlinkHref "#gradient-to-black-rect" ] []
                    , feImage [ width "100%", height "100%", result "color", xlinkHref "#gradient-to-color-rect" ] []
                    , feBlend [ in_ "black", in2 "color", mode "multiply" ] []
                    ]
                ]
            , rect [ A.filter "url(#gradient-multiply)", x "0", y "0", width "100%", height "100%" ] []
            ]
        ]


handleClick : Hsva -> (Hsva -> msg) -> Attribute msg
handleClick color msg =
    on "mousedown" <|
        D.map msg <|
            D.map (updateColor color) <|
                D.map4 ClickPosition
                    (D.field "offsetX" D.int)
                    (D.field "offsetY" D.int)
                    (D.field "offsetWidth" D.int |> D.at [ "currentTarget" ])
                    (D.field "offsetHeight" D.int |> D.at [ "currentTarget" ])


updateColor : Hsva -> ClickPosition -> Hsva
updateColor { hue, alpha } position =
    let
        { offsetX, offsetY, width, height } =
            position
    in
    Hsva hue (toFloat offsetX / toFloat width) (1.0 - (toFloat offsetY / toFloat height)) alpha
