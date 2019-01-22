module Image exposing (Image, Status(..), buildCodes, buildImages, distinct, randomGenerator, render, url)

import Element exposing (Attribute, Color, Element, px, rgb, width)
import Element.Border as Border
import Random
import Set exposing (Set)


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
    Random.list size (Random.int min max)


distinct : List Int -> List Int
distinct codes =
    codes |> Set.fromList |> Set.toList


buildCodes : List Int -> List Int
buildCodes codes =
    codes
        |> List.append codes


buildImages : List Int -> List Image
buildImages codes =
    codes |> List.indexedMap (\index code -> code |> buildImage index)


url : Image -> String
url image =
    case image.status of
        Hidden ->
            "card.jpg"

        Visible ->
            image.url

        Found ->
            image.url


imageStyle : Image -> List (Attribute msg)
imageStyle image =
    case image.status of
        Hidden ->
            []

        Visible ->
            [ Border.width 1 ]

        Found ->
            [ Border.color (rgb 0 255 0) ]


render : Image -> Element msg
render image =
    { src = image |> url
    , description = image.description
    }
        |> Element.image
            (imageStyle image
                |> List.append [ width (px 200) ]
            )


buildImage : Int -> Int -> Image
buildImage index id =
    { id = id
    , index = index
    , url = "https://picsum.photos/300/?image=" ++ String.fromInt id
    , description = String.fromInt id
    , status = Hidden
    }
