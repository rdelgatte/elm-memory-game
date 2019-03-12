module Main exposing (Model, Msg(..), initialModel, main, update, view)

import Browser
import Html as Input exposing (Attribute, Html, div, text)
import Html.Attributes exposing (style)
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
    = Roll
    | Rolled Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Roll ->
            ( model, generateValue )

        Rolled randomValue ->
            ( { value = randomValue }, Cmd.none )


generateValue : Cmd Msg
generateValue =
    generate 1 100


generate : Int -> Int -> Cmd Msg
generate min max =
    max
        |> Random.int min
        |> Random.generate Rolled



-- VIEW


view : Model -> Html Msg
view model =
    let
        diceValue : Html Msg
        diceValue =
            (model.value
                |> fromInt
            )
                |> String.append "Value = "
                |> text
    in
    [ diceValue
    , Input.button [ onClick Roll, style "margin" "5px" ] [ text "Generate" ]
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
