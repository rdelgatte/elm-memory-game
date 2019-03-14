module Main exposing (Model, Msg(..), initialModel, main, update, view)

import Browser
import Element exposing (Attribute, Element, centerX, padding, px, spacing, text, width)
import Element.Input as Input
import Html exposing (Html)
import Image exposing (Image, Status(..), buildImage, refreshImagesStatus, renderImage, visible)
import Random
import Random.List
import Set



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
    | DuplicatedAndMixed (List Int)
    | Click Int


duplicateAndMixValues : List Int -> Cmd Msg
duplicateAndMixValues values =
    values
        |> List.append values
        |> Random.List.shuffle
        |> Random.generate DuplicatedAndMixed


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GenerateValues ->
            ( model, generateValues model )

        Generated randomValues ->
            case (randomValues |> Set.fromList |> Set.size) == model.length of
                True ->
                    ( { model | maybeImages = Nothing }, randomValues |> duplicateAndMixValues )

                False ->
                    ( model, generateValues model )

        Click index ->
            ( { model | maybeImages = index |> updateImagesOnClick model.maybeImages }, Cmd.none )

        DuplicatedAndMixed mixedCodes ->
            ( { model | maybeImages = Just (mixedCodes |> List.map (\id -> id |> buildImage)) }, Cmd.none )


updateImagesOnClick : Maybe (List Image) -> Int -> Maybe (List Image)
updateImagesOnClick maybeImages clickedIndex =
    case maybeImages of
        Nothing ->
            Nothing

        Just images ->
            Just
                (images
                    |> List.indexedMap
                        (\index image ->
                            case index == clickedIndex of
                                False ->
                                    image

                                True ->
                                    visible image
                        )
                )


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


renderClickableImage : Image -> Int -> Element Msg
renderClickableImage image index =
    { onPress =
        case image.status of
            Hidden ->
                Just (Click index)

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
                |> List.append (images |> List.indexedMap (\index image -> index |> renderClickableImage image))
                |> Element.wrappedRow
                    [ spacing 10
                    , padding 10
                    , width (px 600)
                    , centerX
                    ]
                |> Element.layout []



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none


main : Program () Model Msg
main =
    Browser.element
        { init = initialModel
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
