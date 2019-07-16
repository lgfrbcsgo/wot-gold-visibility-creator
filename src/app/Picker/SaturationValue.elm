module Picker.SaturationValue exposing (Model, Msg, init, subscriptions, update, view)

import Basics
import Color exposing (..)
import Html exposing (Attribute, Html, div)
import Html.Attributes exposing (height, style, width)
import Math.Vector2 exposing (Vec2, vec2)
import Math.Vector3 exposing (Vec3, vec3)
import Picker.Shared exposing (matrixInput, styles)
import Slider
import WebGL exposing (Mesh, Shader)



---- Model ----


type Model
    = Model Slider.Model


init : Model
init =
    Model Slider.init



---- UPDATE ----


type Msg
    = Slider Slider.Msg


update : Msg -> Model -> Hsva -> ( Hsva, Model )
update (Slider msg) (Model model) color =
    let
        relativePosition =
            colorToRelativePosition color

        ( updatedRelativePosition, updatedModel ) =
            Slider.update msg relativePosition model

        updatedColor =
            updateColor color updatedRelativePosition
    in
    ( updatedColor, Model updatedModel )


updateColor : Hsva -> Slider.Position -> Hsva
updateColor color relativePosition =
    let
        updatedSaturation =
            relativePosition.x

        updatedValue =
            1 - relativePosition.y
    in
    color
        |> mapSaturation updatedSaturation
        |> mapValue updatedValue


colorToRelativePosition : Hsva -> Slider.Position
colorToRelativePosition color =
    let
        { saturation, value } =
            color |> toHsva
    in
    Slider.Position saturation (1 - value)



---- SUBSCRIPTIONS ----


subscriptions : Model -> Sub Msg
subscriptions (Model model) =
    Slider.subscriptions model |> Sub.map Slider



---- VIEW ----


view : Model -> Hsva -> Html Msg
view (Model model) color =
    matrixInput Slider colorToRelativePosition viewThumb viewBackground model color


viewThumb : List (Attribute Slider.Msg) -> Hsva -> Html Slider.Msg
viewThumb extraAttributes color =
    let
        thumbBackgroundColor =
            color |> mapAlpha 1 |> toCss
    in
    div (extraAttributes ++ [ style "backgroundColor" thumbBackgroundColor ])
        []


viewBackground : List (Attribute Slider.Msg) -> Hsva -> Html Slider.Msg
viewBackground extraAttributes color =
    let
        baseColor =
            color
                |> mapSaturation 1
                |> mapValue 1
                |> toRgba
    in
    WebGL.toHtml (extraAttributes ++ [ width 100, height 100, styles.class .canvas ])
        [ WebGL.entity
            vertexShader
            fragmentShader
            mesh
            { baseColor =
                vec3
                    baseColor.red
                    baseColor.green
                    baseColor.blue
            }
        ]



---- MESH ---


mesh : Mesh { position : Vec2 }
mesh =
    WebGL.triangles
        [ ( { position = vec2 -1 1 }
          , { position = vec2 1 1 }
          , { position = vec2 -1 -1 }
          )
        , ( { position = vec2 -1 -1 }
          , { position = vec2 1 1 }
          , { position = vec2 1 -1 }
          )
        ]



---- SHADERS ----


vertexShader : Shader { position : Vec2 } { baseColor : Vec3 } { saturation : Float, value : Float }
vertexShader =
    [glsl|
        attribute vec2 position;
        varying float saturation;
        varying float value;

        void main () {
            vec2 normalizedPosition = (position + 1.0) / 2.0;
            saturation = normalizedPosition.x;
            value = normalizedPosition.y;
            gl_Position = vec4(position, 0.0, 1.0);
        }
    |]


fragmentShader : Shader {} { baseColor : Vec3 } { saturation : Float, value : Float }
fragmentShader =
    [glsl|
        precision mediump float;

        uniform vec3 baseColor;
        varying float saturation;
        varying float value;

        void main () {
            vec3 whiteOverlayed = baseColor * saturation + 1.0 - saturation;
            vec3 blackOverlayed = whiteOverlayed * value;
            gl_FragColor = vec4(blackOverlayed, 1.0);
        }
    |]
