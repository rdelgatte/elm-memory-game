module Main exposing (Model, Msg(..), initialModel, main, update, view)

import Browser
import Element exposing (Element, padding, px, spacing, text)
import Element.Input as Input
import Html exposing (Html)
import Image exposing (Image)
import Random
import String exposing (fromInt)



-- MODEL


type alias Model =
    { values : List Int }


initialModel : () -> ( Model, Cmd Msg )
initialModel _ =
    ( { values = [] }, generateValue )



-- MSG


type Msg
    = GenerateValues
    | Generated (List Int)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GenerateValues ->
            ( model, generateValue )

        Generated randomValues ->
            ( { values = randomValues }, Cmd.none )


generateValue : Cmd Msg
generateValue =
    generate 1 100


generate : Int -> Int -> Cmd Msg
generate min max =
    max
        |> Random.int min
        |> Random.list 5
        |> Random.generate Generated



-- VIEW


renderImage : Image -> Element Msg
renderImage { id, description } =
    let
        imageUrl : String
        imageUrl =
            (id |> fromInt)
                |> String.append "https://picsum.photos/200/200?image="
    in
    { src = imageUrl
    , description = description
    }
        |> Element.image [ Element.width (px 100) ]


view : Model -> Html Msg
view { values } =
    let
        button : Element Msg
        button =
            { onPress = Just GenerateValues
            , label = text "Generate"
            }
                |> Input.button []

        images : List (Element Msg)
        images =
            values
                |> List.map (\imageId -> imageId |> Image.buildImage)
                |> List.map (\image -> image |> renderImage)
    in
    [ button ]
        |> List.append images
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
