module Main exposing (Model, Msg(..), init, initialModel, main, subscriptions, update, view)

import Browser
import Configuration exposing (Configuration)
import Element exposing (Element, centerX, column, fill, height, layout, maximum, padding, px, row, spaceEvenly, spacing, width, wrappedRow)
import Element.Input as Input
import Html exposing (Html)
import Image exposing (Image, Status(..), buildCodes, buildImages, distinct, randomGenerator, render, url)
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
    | LoadedRandomId (List Int)
    | ShuffleCodes (List Int)
    | Click Image



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        Init ->
            ( model, generateCodes )

        SelectLevel selectedLevel ->
            let
                configuration : Configuration
                configuration =
                    model.configuration
            in
            ( { model | configuration = { configuration | level = selectedLevel } }
            , generateCodes
            )

        LoadedRandomId codes ->
            ( { model
                | images = codes |> buildImages
              }
            , Cmd.none
            )

        ShuffleCodes newCodes ->
            let
                configuration : Configuration
                configuration =
                    model.configuration

                cards : Int
                cards =
                    configuration.level * configuration.cardsByLevel

                distinctCodes : List Int
                distinctCodes =
                    configuration.codes
                        |> List.append newCodes
                        |> distinct
                        |> List.take cards
            in
            ( { model | configuration = { configuration | codes = distinctCodes } }
            , case (distinctCodes |> List.length) < cards of
                True ->
                    10 |> randomGenerator 1 1000 |> Random.generate ShuffleCodes

                False ->
                    distinctCodes
                        |> buildCodes
                        |> shuffle
                        |> Random.generate LoadedRandomId
            )

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
        |> randomGenerator 1 1000
        |> Random.generate ShuffleCodes



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.none



-- VIEW


view : Model -> Html Msg
view model =
    let
        cardsWidth : Int
        cardsWidth =
            model.configuration.cardsByLevel * 205

        images : Element Msg
        images =
            model.images
                |> List.map
                    (\image ->
                        { onPress = Just (Click image)
                        , label = render image
                        }
                            |> Input.button []
                    )
                |> wrappedRow
                    [ spacing 5
                    , spaceEvenly
                    , width (px cardsWidth)
                    ]

        screen : Element Msg
        screen =
            [ images ]
                |> column
                    [ centerX ]

        generateButton =
            { onPress = Just Init
            , label = Element.text "Init"
            }
                |> Input.button
                    [ padding 10
                    , spacing 10
                    ]

        levelOptions : List (Input.Option Int msg)
        levelOptions =
            [ 1, 2, 3, 4, 5 ]
                |> List.map
                    (\level ->
                        level
                            |> String.fromInt
                            |> Element.text
                            |> Input.option level
                    )

        selector : Element Msg
        selector =
            { onChange = SelectLevel
            , selected = Just model.configuration.level
            , label =
                "Select level"
                    |> Element.text
                    |> Input.labelAbove []
            , options = levelOptions
            }
                |> Input.radio
                    [ padding 5
                    , spacing 5
                    ]

        configurationSideBar : Element Msg
        configurationSideBar =
            [ generateButton ]
                |> List.append [ selector ]
                |> column
                    [ width (px 150)
                    , centerX
                    , Element.alignTop
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
