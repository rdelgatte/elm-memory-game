module Main exposing (Model, Msg(..), initialModel, main, update, view)

import Browser
import Element exposing (Element, padding, px, spacing, text)
import Element.Input as Input
import Html exposing (Html)
import Image exposing (Image, buildImage)
import Random
import String exposing (fromInt)



-- MODEL


type alias Model =
    { maybeImages : Maybe (List Image) }


initialModel : () -> ( Model, Cmd Msg )
initialModel _ =
    ( { maybeImages = Nothing }, generateValues )



-- MSG


type Msg
    = GenerateValues
    | Generated (List Int)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GenerateValues ->
            ( model, generateValues )

        Generated randomValues ->
            ( { maybeImages = Just (randomValues |> List.map (\id -> id |> buildImage)) }, Cmd.none )


generateValues : Cmd Msg
generateValues =
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
view { maybeImages } =
    let
        button : Element Msg
        button =
            { onPress = Just GenerateValues
            , label = text "Generate"
            }
                |> Input.button []
    in
    case maybeImages of
        Nothing ->
            [ text "No images were loaded"
            , button
            ]
                |> Element.row
                    [ spacing 10
                    , padding 10
                    ]
                |> Element.layout []

        Just images ->
            [ button ]
                |> List.append (images |> List.map (\image -> image |> renderImage))
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
