module Image exposing (Image, Status(..), buildImages, distinct, duplicateCodes, imageUrl, imagesCount, progressRendering, randomGenerator, render)

import Element exposing (Attribute, Color, Element, centerX, el, fill, fillPortion, height, inFront, padding, px, rgb255, rgba255, row, spacing, text, width)
import Element.Background as Background
import Random
import Set exposing (Set)
import String exposing (fromInt)


type alias Image =
    { id : Int
    , index : Int
    , url : String
    , description : String
    , status : Status
    }


type Status
    = Hidden
    | Visible
    | Found


randomGenerator : Int -> Int -> Int -> Random.Generator (List Int)
randomGenerator min max size =
    Random.int min max
        |> Random.list size


distinct : List Int -> List Int
distinct codes =
    codes |> Set.fromList |> Set.toList


duplicateCodes : List Int -> List Int
duplicateCodes codes =
    codes |> List.append codes


buildImages : List Int -> List Image
buildImages codes =
    codes |> List.indexedMap (\index code -> code |> buildImage index)


imagesCount : List Image -> (Image -> Bool) -> Int
imagesCount images filter =
    images |> List.filter filter |> List.length


imageUrl : Image -> String
imageUrl image =
    case image.status of
        Hidden ->
            "card.png"

        _ ->
            image.url


imageStyle : Image -> List (Attribute msg)
imageStyle image =
    case image.status of
        Found ->
            let
                overlay : Element msg
                overlay =
                    Element.none
                        |> el
                            [ width fill
                            , height fill
                            , Background.color (rgba255 255 255 255 0.5)
                            ]
            in
            [ inFront overlay ]

        _ ->
            []


render : Image -> Element msg
render image =
    { src = image |> imageUrl
    , description = image.description
    }
        |> Element.image
            (imageStyle image
                |> List.append
                    [ width (px 200)
                    , height (px 300)
                    , spacing 5
                    ]
            )


progressRendering : List Image -> Element msg
progressRendering images =
    let
        foundCount : Int
        foundCount =
            (\img -> img.status == Found)
                |> imagesCount images

        remaining : Int
        remaining =
            (images |> List.length) - foundCount

        percent : Float
        percent =
            (foundCount |> toFloat) / ((images |> List.length) |> toFloat)

        roundedPercent : String
        roundedPercent =
            percent * 100 |> round |> fromInt

        completed : Element msg
        completed =
            case foundCount of
                0 ->
                    text "Find images to see your progress..."
                        |> el
                            [ width fill
                            , padding 10
                            ]

                _ ->
                    roundedPercent
                        ++ "% completed"
                        |> text
                        |> el
                            [ Background.color (rgb255 100 200 0)
                            , width (fillPortion foundCount)
                            , padding 20
                            ]
    in
    [ completed
    , Element.none |> el [ width (fillPortion remaining) ]
    ]
        |> row
            [ width fill
            , centerX
            , height (px 60)
            ]


buildImage : Int -> Int -> Image
buildImage index id =
    { id = id
    , index = index
    , url = "./src/assets/" ++ String.fromInt id ++ ".png"
    , description = String.fromInt id
    , status = Hidden
    }
