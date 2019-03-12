module Main exposing (Model, Msg(..), initialModel, main, update, view)

import Browser
import Html as Input exposing (Attribute, Html, div, img, text)
import Html.Attributes exposing (src, style)
import Html.Events exposing (onClick)
import Random
import String exposing (fromInt)



-- MODEL


type alias Model =
    { value : Int }


initialModel : () -> ( Model, Cmd Msg )
initialModel _ =
    ( { value = 0 }, generateValue )



-- MSG


type Msg
    = Generate
    | Generated Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Generate ->
            ( model, generateValue )

        Generated randomValue ->
            ( { value = randomValue }, Cmd.none )


generateValue : Cmd Msg
generateValue =
    generate 1 100


generate : Int -> Int -> Cmd Msg
generate min max =
    max
        |> Random.int min
        |> Random.generate Generated



-- VIEW


view : Model -> Html Msg
view { value } =
    let
        randomValue : Html Msg
        randomValue =
            value
                |> fromInt
                |> String.append "Value = "
                |> text
    in
    [ randomValue
    , Input.button [ onClick Generate, style "margin" "5px" ] [ text "Generate" ]
    ]
        |> div []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


main : Program () Model Msg
main =
    Browser.element
        { init = initialModel
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
