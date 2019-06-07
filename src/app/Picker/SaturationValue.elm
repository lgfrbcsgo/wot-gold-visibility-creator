module Picker.SaturationValue exposing (Model, Msg, init, subscriptions, update, view)

import Basics
import Browser.Events
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
    { width : Int, height : Int }


type alias Position =
    { x : Int, y : Int }


type alias DragContext =
    { startSize : Size
    , relStartPosition : Position
    , absStartPosition : Position
    }


type Model
    = Dragging DragContext
    | KnobClicked
    | Resting


init : Model
init =
    Resting



---- UPDATE ----


type Msg
    = KnobClick
    | DragStart DragContext
    | Drag Position
    | DragEnd


update : Msg -> Hsva -> Model -> ( Hsva, Model )
update msg color model =
    case msg of
        KnobClick ->
            ( color, KnobClicked )

        DragStart dragContext ->
            let
                size =
                    dragContext.startSize

                relPosition =
                    case model of
                        KnobClicked ->
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
            toFloat x / toFloat width

        value =
            1 - toFloat y / toFloat height
    in
    HsvaRecord hue saturation value alpha |> hsva


colorToRelPosition : Size -> Hsva -> Position
colorToRelPosition size color =
    let
        { saturation, value } =
            fromHsva color

        x =
            toFloat size.width * saturation |> floor

        y =
            toFloat size.height * (1 - value) |> floor
    in
    Position x y



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Dragging _ ->
            Sub.batch
                [ Browser.Events.onMouseMove <| Decode.map Drag decodeAbsolutePosition
                , Browser.Events.onMouseUp <| Decode.succeed DragEnd
                ]

        KnobClicked ->
            Browser.Events.onMouseUp <| Decode.succeed DragEnd

        Resting ->
            Sub.none



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
                    [ Html.Events.on "mousedown" <|
                        Decode.map DragStart <|
                            Decode.map3 DragContext decodeSize decodeRelativePosition decodeAbsolutePosition
                    ]

        knobTop =
            String.fromFloat ((1 - value) * 100) ++ "%"

        knobLeft =
            String.fromFloat (saturation * 100) ++ "%"

        knobBackground =
            HsvaRecord hue saturation value 1 |> hsva |> hsvaToRgba |> rgbaToCss

        knobListeners =
            case model of
                Dragging _ ->
                    []

                _ ->
                    [ Html.Events.on "mousedown" <| Decode.succeed KnobClick ]
    in
    Html.div
        (backgroundListeners
            ++ [ styles.class .checkerboard
               , styles.class .dragContainer
               ]
        )
        [ Html.div
            (knobListeners
                ++ [ styles.class .knob
                   , Html.Attributes.style "top" knobTop
                   , Html.Attributes.style "left" knobLeft
                   , Html.Attributes.style "backgroundColor" knobBackground
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


decodeAbsolutePosition : Decode.Decoder Position
decodeAbsolutePosition =
    Decode.map2 Position
        (Decode.field "pageX" Decode.int)
        (Decode.field "pageY" Decode.int)


decodeRelativePosition : Decode.Decoder Position
decodeRelativePosition =
    Decode.map2 Position
        (Decode.field "offsetX" Decode.int)
        (Decode.field "offsetY" Decode.int)


decodeSize : Decode.Decoder Size
decodeSize =
    Decode.map2 Size
        (Decode.int |> Decode.at [ "currentTarget", "offsetWidth" ])
        (Decode.int |> Decode.at [ "currentTarget", "offsetHeight" ])