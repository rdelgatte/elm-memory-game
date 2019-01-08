module Main exposing (Model, Msg(..), init, initialModel, main, subscriptions, update, view)

import Browser
import Element exposing (Element, centerX, column, fill, layout, maximum, padding, px, row, spaceEvenly, spacing, width, wrappedRow)
import Element.Input as Input
import Html exposing (Html)
import Image exposing (Image, Status(..), buildCodes, buildImages, distinct, randomGenerator)
import Random
import Random.List exposing (shuffle)



-- MODEL


type alias Model =
    { level : Int
    , cardsByLevel : Int
    , codes : List Int
    , images : List Image
    }


initialModel : Model
initialModel =
    { level = 1
    , cardsByLevel = 6
    , codes = []
    , images = []
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( initialModel
    , 10 |> randomGenerator 1 1000 |> Random.generate ShuffleCodes
    )



-- MSG


type Msg
    = Init
    | SelectLevel Int
    | LoadedRandomId (List Int)
    | ShuffleCodes (List Int)



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update message model =
    case message of
        Init ->
            ( model
            , 100 |> randomGenerator 1 1000 |> Random.generate ShuffleCodes
            )

        SelectLevel selectedLevel ->
            ( { model
                | level = selectedLevel
              }
            , 100 |> randomGenerator 1 1000 |> Random.generate ShuffleCodes
            )

        LoadedRandomId codes ->
            ( { model
                | images = codes |> buildImages
              }
            , Cmd.none
            )

        ShuffleCodes newCodes ->
            let
                cards : Int
                cards =
                    model.level * model.cardsByLevel

                distinctCodes : List Int
                distinctCodes =
                    model.codes
                        |> List.append newCodes
                        |> distinct
                        |> List.take cards
            in
            ( { model | codes = distinctCodes }
            , case (distinctCodes |> List.length) < cards of
                True ->
                    10 |> randomGenerator 1 1000 |> Random.generate ShuffleCodes

                False ->
                    distinctCodes
                        |> buildCodes
                        |> shuffle
                        |> Random.generate LoadedRandomId
            )



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
            model.cardsByLevel * 105

        images : Element Msg
        images =
            model.images
                |> List.map
                    (\image ->
                        { src = image.url
                        , description = image.description
                        }
                            |> Element.image [ width (px 100) ]
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
                    [ centerX
                    , width (fill |> maximum 800)
                    ]

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
            , selected = Just model.level
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

        optionsSideBar : Element Msg
        optionsSideBar =
            [ generateButton ]
                |> List.append [ selector ]
                |> column
                    [ width (px 150)
                    , centerX
                    , Element.alignTop
                    ]
    in
    [ optionsSideBar, screen ]
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
