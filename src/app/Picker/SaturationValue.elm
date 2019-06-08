module Picker.SaturationValue exposing (Model, Msg, init, update, view)

import Basics
import Color exposing (..)
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Json.Decode as Decode
import Picker.Styles exposing (styles)
import Svg exposing (..)
import Svg.Attributes exposing (..)



---- Model ----


type alias Size =
    { width : Float, height : Float }


type alias Position =
    { x : Float, y : Float }


type alias DragContext =
    { startSize : Size
    , relStartPosition : Position
    , absStartPosition : Position
    }


type Model
    = Dragging DragContext
    | ThumbClicked
    | Resting


init : Model
init =
    Resting



---- UPDATE ----


type Msg
    = ThumbClick
    | DragStart DragContext
    | Drag Position
    | DragEnd


update : Msg -> Hsva -> Model -> ( Hsva, Model )
update msg color model =
    case msg of
        ThumbClick ->
            ( color, ThumbClicked )

        DragStart dragContext ->
            let
                size =
                    dragContext.startSize

                relPosition =
                    case model of
                        ThumbClicked ->
                            colorToRelPosition dragContext.startSize color

                        _ ->
                            dragContext.relStartPosition
            in
            ( relPositionToColor size relPosition color, Dragging { dragContext | relStartPosition = relPosition } )

        Drag absPosition ->
            case model of
                Dragging dragContext ->
                    let
                        size =
                            dragContext.startSize

                        relPosition =
                            absToRelPosition absPosition dragContext
                    in
                    ( relPositionToColor size relPosition color, Dragging dragContext )

                _ ->
                    ( color, model )

        DragEnd ->
            ( color, Resting )


absToRelPosition : Position -> DragContext -> Position
absToRelPosition absPosition dragContext =
    let
        { absStartPosition, relStartPosition } =
            dragContext

        xDiff =
            absPosition.x - absStartPosition.x

        yDiff =
            absPosition.y - absStartPosition.y

        x =
            xDiff + relStartPosition.x

        y =
            yDiff + relStartPosition.y
    in
    Position x y


relPositionToColor : Size -> Position -> Hsva -> Hsva
relPositionToColor size relPosition color =
    let
        { width, height } =
            size

        { x, y } =
            relPosition

        { hue, alpha } =
            fromHsva color

        saturation =
            x / width

        value =
            1 - y / height
    in
    HsvaRecord hue saturation value alpha |> hsva


colorToRelPosition : Size -> Hsva -> Position
colorToRelPosition size color =
    let
        { saturation, value } =
            fromHsva color

        x =
            size.width * saturation

        y =
            size.height * (1 - value)
    in
    Position x y



---- VIEW ----


view : Hsva -> Model -> Html Msg
view color model =
    let
        { hue, saturation, value, alpha } =
            fromHsva color

        svgOpacity =
            alpha |> String.fromFloat

        gradientColor =
            HsvaRecord hue 1 1 1 |> hsva |> hsvaToRgba |> rgbaToCss

        backgroundListeners =
            case model of
                Dragging _ ->
                    []

                _ ->
                    [ Html.Events.on "pointerdown" <|
                        succeedOnPrimary <|
                            Decode.map DragStart <|
                                Decode.map3 DragContext decodeSize decodeRelativePosition decodeAbsolutePosition
                    ]

        thumbTop =
            String.fromFloat ((1 - value) * 100) ++ "%"

        thumbLeft =
            String.fromFloat (saturation * 100) ++ "%"

        thumbBackground =
            HsvaRecord hue saturation value 1 |> hsva |> hsvaToRgba |> rgbaToCss

        thumbListeners =
            case model of
                Dragging _ ->
                    []

                _ ->
                    [ Html.Events.on "pointerdown" <|
                        succeedOnPrimary <|
                            Decode.succeed ThumbClick
                    ]

        windowListeners =
            case model of
                Dragging _ ->
                    [ Html.Events.on "pointermove" <|
                        succeedOnPrimary <|
                            Decode.map Drag decodeAbsolutePosition
                    , Html.Events.on "pointerup" <|
                        succeedOnPrimary <|
                            Decode.succeed DragEnd
                    ]

                ThumbClicked ->
                    [ Html.Events.on "pointerup" <|
                        succeedOnPrimary <|
                            Decode.succeed DragEnd
                    ]

                Resting ->
                    []
    in
    Html.node "window-event-proxy"
        windowListeners
        [ Html.div
            (backgroundListeners
                ++ [ styles.class .checkerboard
                   , styles.class .dragContainer
                   ]
            )
            [ Html.div
                (thumbListeners
                    ++ [ styles.class .thumb
                       , Html.Attributes.style "top" thumbTop
                       , Html.Attributes.style "left" thumbLeft
                       , Html.Attributes.style "backgroundColor" thumbBackground
                       ]
                )
                []
            , svg [ height "100%", width "100%", opacity svgOpacity ]
                [ defs []
                    [ linearGradient [ id "gradient-to-black", x1 "0%", x2 "0%", y1 "0%", y2 "100%" ]
                        [ stop [ offset "0%", stopColor "white" ] []
                        , stop [ offset "100%", stopColor "black" ] []
                        ]
                    , linearGradient [ id "gradient-to-color", x1 "0%", x2 "100%", y1 "0%", y2 "0%" ]
                        [ stop [ offset "0%", stopColor "white" ] []
                        , stop [ offset "100%", stopColor gradientColor ] []
                        ]
                    , rect [ id "gradient-to-black-rect", width "100%", height "100%", fill "url(#gradient-to-black)" ] []
                    , rect [ id "gradient-to-color-rect", width "100%", height "100%", fill "url(#gradient-to-color)" ] []
                    , Svg.filter [ id "gradient-multiply", x "0%", y "0%", width "100%", height "100%", colorInterpolationFilters "sRGB" ]
                        [ feImage [ width "100%", height "100%", result "black", xlinkHref "#gradient-to-black-rect" ] []
                        , feImage [ width "100%", height "100%", result "color", xlinkHref "#gradient-to-color-rect" ] []
                        , feBlend [ in_ "black", in2 "color", mode "multiply" ] []
                        ]
                    ]
                , rect [ Svg.Attributes.filter "url(#gradient-multiply)", x "0", y "0", width "100%", height "100%" ] []
                ]
            ]
        ]


succeedOnPrimary : Decode.Decoder a -> Decode.Decoder a
succeedOnPrimary decoder =
    decodeIsPrimary
        |> Decode.andThen
            (\isPrimary ->
                if isPrimary then
                    decoder

                else
                    Decode.fail "is not primary pointer"
            )


decodeIsPrimary : Decode.Decoder Bool
decodeIsPrimary =
    Decode.field "isPrimary" Decode.bool


decodeAbsolutePosition : Decode.Decoder Position
decodeAbsolutePosition =
    Decode.map2 Position
        (Decode.field "pageX" Decode.float)
        (Decode.field "pageY" Decode.float)


decodeRelativePosition : Decode.Decoder Position
decodeRelativePosition =
    Decode.map2 Position
        (Decode.field "offsetX" Decode.float)
        (Decode.field "offsetY" Decode.float)


decodeSize : Decode.Decoder Size
decodeSize =
    Decode.map2 Size
        (Decode.float |> Decode.at [ "currentTarget", "offsetWidth" ])
        (Decode.float |> Decode.at [ "currentTarget", "offsetHeight" ])
