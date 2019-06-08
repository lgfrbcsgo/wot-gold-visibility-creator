module Slider exposing (Model, Msg, Position, init, update, view)

import Basics
import CssModules exposing (css)
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Json.Decode as Decode


styles =
    css "./Slider.css"
        { dragContainer = "drag-container"
        , thumb = "thumb"
        }



---- Model ----


type alias Size =
    { width : Float, height : Float }


type alias Position =
    { x : Float, y : Float }


type alias DragContext =
    { startSize : Size
    , startOffsetPosition : Position
    , startPagePosition : Position
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


update : Msg -> Position -> Model -> ( Position, Model )
update msg relativePosition model =
    case msg of
        ThumbClick ->
            ( relativePosition, ThumbClicked )

        DragStart dragContext ->
            let
                size =
                    dragContext.startSize

                offsetPosition =
                    case model of
                        ThumbClicked ->
                            relativeToOffsetPosition dragContext.startSize relativePosition

                        _ ->
                            dragContext.startOffsetPosition
            in
            ( offsetToRelativePosition size offsetPosition, Dragging { dragContext | startOffsetPosition = offsetPosition } )

        Drag pagePosition ->
            case model of
                Dragging dragContext ->
                    let
                        size =
                            dragContext.startSize

                        offsetPosition =
                            pageToOffsetPosition pagePosition dragContext
                    in
                    ( offsetToRelativePosition size offsetPosition, Dragging dragContext )

                _ ->
                    ( relativePosition, model )

        DragEnd ->
            ( relativePosition, Resting )


pageToOffsetPosition : Position -> DragContext -> Position
pageToOffsetPosition pagePosition dragContext =
    let
        { startPagePosition, startOffsetPosition } =
            dragContext

        xDiff =
            pagePosition.x - startPagePosition.x

        yDiff =
            pagePosition.y - startPagePosition.y

        x =
            xDiff + startOffsetPosition.x

        y =
            yDiff + startOffsetPosition.y
    in
    Position x y


offsetToRelativePosition : Size -> Position -> Position
offsetToRelativePosition size offsetPosition =
    Position (offsetPosition.x / size.width) (offsetPosition.y / size.height)
        |> clampPosition


relativeToOffsetPosition : Size -> Position -> Position
relativeToOffsetPosition size position =
    let
        { x, y } =
            clampPosition position
    in
    Position (size.width * x) (size.height * y)


clampPosition : Position -> Position
clampPosition position =
    Position (clamp 0 1 position.x) (clamp 0 1 position.y)


clamp : comparable -> comparable -> comparable -> comparable
clamp min max value =
    value |> Basics.min max |> Basics.max min



---- VIEW ----


view : Html msg -> Html msg -> (Msg -> msg) -> Position -> Model -> Html msg
view viewThumb viewBody toMsg relativePosition model =
    let
        { x, y } =
            clampPosition relativePosition

        thumbTop =
            String.fromFloat (y * 100) ++ "%"

        thumbLeft =
            String.fromFloat (x * 100) ++ "%"

        thumbListeners =
            case model of
                Dragging _ ->
                    []

                _ ->
                    [ Html.Events.on "pointerdown" <|
                        failIfNotPrimary <|
                            Decode.succeed (toMsg ThumbClick)
                    ]

        backgroundListeners =
            case model of
                Dragging _ ->
                    []

                _ ->
                    [ Html.Events.on "pointerdown" <|
                        failIfNotPrimary <|
                            Decode.map toMsg <|
                                Decode.map DragStart <|
                                    Decode.map3 DragContext decodeSize decodeOffsetPosition decodePagePosition
                    ]

        windowListeners =
            case model of
                Dragging _ ->
                    [ Html.Events.on "pointermove" <|
                        failIfNotPrimary <|
                            Decode.map toMsg <|
                                Decode.map Drag decodePagePosition
                    , Html.Events.on "pointerup" <|
                        failIfNotPrimary <|
                            Decode.succeed (toMsg DragEnd)
                    ]

                ThumbClicked ->
                    [ Html.Events.on "pointerup" <|
                        failIfNotPrimary <|
                            Decode.succeed (toMsg DragEnd)
                    ]

                Resting ->
                    []
    in
    Html.node "window-event-proxy"
        windowListeners
        [ Html.div
            (backgroundListeners
                ++ [ styles.class .dragContainer
                   ]
            )
            [ Html.div
                (thumbListeners
                    ++ [ styles.class .thumb
                       , Html.Attributes.style "top" thumbTop
                       , Html.Attributes.style "left" thumbLeft
                       ]
                )
                [ viewThumb
                ]
            , viewBody
            ]
        ]


failIfNotPrimary : Decode.Decoder a -> Decode.Decoder a
failIfNotPrimary decoder =
    Decode.field "isPrimary" Decode.bool
        |> Decode.andThen (failIfNotPrimaryHelper decoder)


failIfNotPrimaryHelper : Decode.Decoder a -> Bool -> Decode.Decoder a
failIfNotPrimaryHelper decoder bool =
    case bool of
        True ->
            decoder

        False ->
            Decode.fail "is not primary pointer"


decodePagePosition : Decode.Decoder Position
decodePagePosition =
    Decode.map2 Position
        (Decode.field "pageX" Decode.float)
        (Decode.field "pageY" Decode.float)


decodeOffsetPosition : Decode.Decoder Position
decodeOffsetPosition =
    Decode.map2 Position
        (Decode.field "offsetX" Decode.float)
        (Decode.field "offsetY" Decode.float)


decodeSize : Decode.Decoder Size
decodeSize =
    Decode.map2 Size
        (Decode.float |> Decode.at [ "currentTarget", "offsetWidth" ])
        (Decode.float |> Decode.at [ "currentTarget", "offsetHeight" ])
