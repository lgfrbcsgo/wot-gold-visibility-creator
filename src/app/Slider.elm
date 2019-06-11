module Slider exposing (Model, Msg, Position, init, subscriptions, update, view)

import Basics
import Browser.Events
import CssModules exposing (css)
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Json.Decode as Decode



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
    | NoOp


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

        NoOp ->
            ( relativePosition, model )


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



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        Dragging _ ->
            Sub.batch
                [ Browser.Events.onMouseMove <|
                    Decode.map Drag decodePagePosition
                , Browser.Events.onMouseUp <|
                    Decode.succeed DragEnd
                ]

        ThumbClicked ->
            Browser.Events.onMouseUp <|
                Decode.succeed DragEnd

        Resting ->
            Sub.none



---- STYLES ----


styles =
    css "./Slider.css"
        { dragContainer = "drag-container"
        , thumb = "thumb"
        }



---- VIEW ----


view : Html Msg -> Html Msg -> Position -> Model -> Html Msg
view viewThumb viewBody relativePosition model =
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
                    [ Html.Events.preventDefaultOn "dragstart" <|
                        Decode.map (\msg -> ( msg, True )) <|
                            Decode.succeed NoOp
                    ]

                _ ->
                    [ Html.Events.onMouseDown ThumbClick ]

        backgroundListeners =
            case model of
                Dragging _ ->
                    []

                _ ->
                    [ Html.Events.on "mousedown" <|
                        Decode.map DragStart <|
                            Decode.map3 DragContext decodeSize decodeOffsetPosition decodePagePosition
                    ]
    in
    Html.div
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
            [ Html.map (always DragEnd) viewThumb
            ]
        , Html.map (always DragEnd) viewBody
        ]


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
