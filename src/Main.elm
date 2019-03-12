module Main exposing (Model, Msg(..), initialModel, main, update, view)

import Browser
import Element exposing (Element, padding, px, spacing, text)
import Element.Input as Input
import Html exposing (Html)
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


renderImage : Int -> Element Msg
renderImage imageId =
    let
        imageUrl : String
        imageUrl =
            (imageId |> fromInt)
                |> String.append "https://picsum.photos/200/200?image="
    in
    { src = imageUrl
    , description = "Randomly generated image"
    }
        |> Element.image [ Element.width (px 100) ]


view : Model -> Html Msg
view { value } =
    let
        button : Element Msg
        button =
            { onPress = Just Generate
            , label = text "Generate"
            }
                |> Input.button []
    in
    [ value |> renderImage, button ]
        |> Element.row
            [ spacing 10
            , padding 10
            ]
        |> Element.layout []



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
