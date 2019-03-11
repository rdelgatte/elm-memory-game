module Main exposing (Model, Msg(..), init, initialModel, main, subscriptions, update, view)

import Browser
import Configuration exposing (Configuration, cardsWidth, expectedCards, levelOptions)
import Element exposing (Element, centerX, column, layout, padding, px, row, spaceEvenly, spacing, text, width, wrappedRow)
import Element.Border as Border
import Element.Input as Input
import Html exposing (Html)
import Image exposing (Image, Status(..), buildImages, distinct, duplicateCodes, progressRendering, randomGenerator, render)
import Random
import Random.List exposing (shuffle)



-- MODEL


type alias Model =
    { configuration : Configuration
    , images : List Image
    }


initialModel : Model
initialModel =
    { configuration =
        { level = 1
        , cardsByLevel = 6
        , codes = []
        }
    , images = []
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel, generateCodes )



-- MSG


type Msg
    = Init
    | SelectLevel Int
    | ShuffleCodes (List Int)
    | LoadedRandomId (List Int)
    | Click Image



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        Init ->
            ( model, generateCodes )

        -- Selecting a level should update configuration and generate new images
        SelectLevel selectedLevel ->
            let
                configuration : Configuration
                configuration =
                    model.configuration
            in
            ( { model | configuration = { configuration | level = selectedLevel } }
            , generateCodes
            )

        -- From the generated codes, aggregate to build the images codes
        ShuffleCodes randomCodes ->
            let
                configuration : Configuration
                configuration =
                    model.configuration

                expectedNumberOfCards : Int
                expectedNumberOfCards =
                    expectedCards configuration

                distinctCodes : List Int
                distinctCodes =
                    configuration.codes
                        |> List.append randomCodes
                        |> distinct
                        |> List.take expectedNumberOfCards
            in
            ( { model | configuration = { configuration | codes = distinctCodes } }
            , case (distinctCodes |> List.length) < expectedNumberOfCards of
                True ->
                    generateCodes

                False ->
                    distinctCodes
                        |> duplicateCodes
                        |> shuffle
                        |> Random.generate LoadedRandomId
            )

        -- From the random generated codes, we build a list of images
        LoadedRandomId codes ->
            ( { model | images = codes |> buildImages }, Cmd.none )

        Click clickedImage ->
            let
                selectedImages : List Image
                selectedImages =
                    model.images
                        |> List.filter (\img -> img.status == Visible)

                updatedImages : List Image
                updatedImages =
                    case selectedImages |> List.length of
                        0 ->
                            model.images
                                |> List.map
                                    (\img ->
                                        case img.index == clickedImage.index of
                                            True ->
                                                { img | status = Visible }

                                            False ->
                                                img
                                    )

                        1 ->
                            case
                                selectedImages
                                    |> List.filter (\img -> img.id == clickedImage.id && img.index /= clickedImage.index)
                                    |> List.isEmpty
                            of
                                True ->
                                    model.images
                                        |> List.map
                                            (\img ->
                                                case img.index == clickedImage.index of
                                                    True ->
                                                        { img | status = Visible }

                                                    False ->
                                                        img
                                            )

                                False ->
                                    model.images
                                        |> List.map
                                            (\img ->
                                                case img.id == clickedImage.id of
                                                    True ->
                                                        { img | status = Found }

                                                    False ->
                                                        img
                                            )

                        2 ->
                            model.images
                                |> List.map
                                    (\img ->
                                        case img.status == Visible of
                                            True ->
                                                { img | status = Hidden }

                                            False ->
                                                img
                                    )
                                |> List.map
                                    (\img ->
                                        case img.index == clickedImage.index of
                                            True ->
                                                { img | status = Visible }

                                            False ->
                                                img
                                    )

                        _ ->
                            model.images
            in
            ( { model | images = updatedImages }
            , Cmd.none
            )


generateCodes : Cmd Msg
generateCodes =
    10
        |> randomGenerator 1 100
        |> Random.generate ShuffleCodes



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    let
        images : Element Msg
        images =
            model.images
                |> List.map
                    (\image ->
                        let
                            action : Maybe Msg
                            action =
                                case image.status of
                                    Hidden ->
                                        Just (Click image)

                                    _ ->
                                        Nothing
                        in
                        { onPress = action
                        , label = render image
                        }
                            |> Input.button []
                    )
                |> wrappedRow
                    [ spacing 5
                    , spaceEvenly
                    , model.configuration |> cardsWidth |> px |> width
                    ]

        screen : Element Msg
        screen =
            [ progressRendering model.images
            , images
            ]
                |> column
                    [ padding 10
                    , spacing 10
                    ]

        initButton =
            { onPress = Just Init
            , label = text "Restart"
            }
                |> Input.button
                    [ padding 10
                    , spacing 20
                    , Border.width 1
                    ]

        levelSelector : Element Msg
        levelSelector =
            { onChange = SelectLevel
            , selected = Just model.configuration.level
            , label =
                "Level"
                    |> text
                    |> Input.labelAbove []
            , options = levelOptions
            }
                |> Input.radio
                    [ padding 10
                    , spacing 10
                    ]

        configurationSideBar : Element Msg
        configurationSideBar =
            [ initButton ]
                |> List.append [ levelSelector ]
                |> column
                    [ centerX
                    , Element.alignTop
                    , padding 20
                    ]
    in
    [ configurationSideBar, screen ]
        |> row [ centerX ]
        |> layout []



-- MAIN


main : Program () Model Msg
main =
    Browser.element
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }
