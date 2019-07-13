module Picker.SaturationValue exposing (Model, Msg, init, subscriptions, update, view)

import Basics
import Color exposing (..)
import Html exposing (Html, div)
import Html.Attributes exposing (height, style, width)
import Math.Vector2 exposing (Vec2)
import Math.Vector3 exposing (Vec3, vec3)
import Picker.Shared exposing (matrixInput)
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


update : Msg -> Hsva -> Model -> ( Hsva, Model )
update (Slider msg) color (Model model) =
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


view : Hsva -> Model -> Html Msg
view color (Model model) =
    let
        relativePosition =
            colorToRelativePosition color

        thumbBackgroundColor =
            color |> mapAlpha 1 |> toCss

        viewThumb =
            div [ style "backgroundColor" thumbBackgroundColor ]
                []

        viewBackground =
            WebGL.toHtml
                [ width 1000
                , height 1000
                ]
                [ WebGL.entity
                    vertexShader
                    fragmentShader
                    mesh
                    { hue = color |> toHsva |> .hue
                    }
                ]
    in
    matrixInput Slider viewThumb viewBackground relativePosition model



---- MESH ---


mesh : Mesh { position : Vec3 }
mesh =
    WebGL.triangles
        [ ( { position = vec3 -1 1 0 }
          , { position = vec3 1 1 0 }
          , { position = vec3 -1 -1 0 }
          )
        , ( { position = vec3 -1 -1 0 }
          , { position = vec3 1 1 0 }
          , { position = vec3 1 -1 0 }
          )
        ]



---- SHADERS ----


vertexShader : Shader { position : Vec3 } { hue : Float } { saturationValue : Vec2 }
vertexShader =
    [glsl|
        attribute vec3 position;
        varying vec2 saturationValue;

        void main () {
            gl_Position = vec4(position, 1.0);
            saturationValue = (position.xy + 1.0) / 2.0;
        }
    |]


fragmentShader : Shader {} { hue : Float } { saturationValue : Vec2 }
fragmentShader =
    [glsl|
        precision mediump float;

        uniform float hue;
        varying vec2 saturationValue;

        // Source: http://lolengine.net/blog/2013/07/27/rgb-to-hsv-in-glsl
        vec3 hsv2rgb(vec3 c)
        {
            vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
            vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
            return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
        }

        void main () {
            vec3 hsv = vec3(hue, saturationValue);
            gl_FragColor = vec4(hsv2rgb(hsv), 1.0);
        }
    |]
