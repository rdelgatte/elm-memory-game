module Main exposing (Model, Msg(..), initialModel, main, update, view)

import Browser
import Element exposing (Element, padding, px, spacing, text)
import Element.Input as Input
import Html exposing (Html)
import Image exposing (Image, Status(..), buildImage)
import Random
import Set
import String exposing (fromInt)



-- MODEL


type alias Model =
    { maybeImages : Maybe (List Image)
    , length : Int
    }


initialModel : () -> ( Model, Cmd Msg )
initialModel _ =
    let
        initModel : Model
        initModel =
            { maybeImages = Nothing
            , length = 10
            }
    in
    ( initModel, generateValues initModel )



-- MSG


type Msg
    = GenerateValues
    | Generated (List Int)
    | Click Image


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GenerateValues ->
            ( model, generateValues model )

        Generated randomValues ->
            case (randomValues |> Set.fromList |> Set.size) == model.length of
                True ->
                    ( { model | maybeImages = Just (randomValues |> List.map (\id -> id |> buildImage)) }, Cmd.none )

                False ->
                    ( model, generateValues model )

        Click clickedImage ->
            ( { model | maybeImages = clickedImage |> updateImagesOnClick model.maybeImages }, Cmd.none )


updateImagesOnClick : Maybe (List Image) -> Image -> Maybe (List Image)
updateImagesOnClick maybeImages { id } =
    case maybeImages of
        Nothing ->
            Nothing

        Just images ->
            Just
                (images
                    |> List.map
                        (\image ->
                            case image.id == id of
                                False ->
                                    image

                                True ->
                                    visible image
                        )
                )


visible : Image -> Image
visible image =
    { image | status = Visible }


generateValues : Model -> Cmd Msg
generateValues { length } =
    generate 1 100 length


generate : Int -> Int -> Int -> Cmd Msg
generate min max length =
    max
        |> Random.int min
        |> Random.list length
        |> Random.generate Generated



-- VIEW


renderImage : Image -> Element Msg
renderImage { id, description, status } =
    let
        imageUrl : String
        imageUrl =
            case status of
                Hidden ->
                    "doc/card.png"

                _ ->
                    (id |> fromInt)
                        |> String.append "https://picsum.photos/200/200?image="
    in
    { src = imageUrl
    , description = description
    }
        |> Element.image [ Element.width (px 100) ]


renderClickableImage : Image -> Element Msg
renderClickableImage image =
    { onPress =
        case image.status of
            Hidden ->
                Just (Click image)

            _ ->
                Nothing
    , label = renderImage image
    }
        |> Input.button []


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
                |> List.append (images |> List.map (\image -> image |> renderClickableImage))
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
