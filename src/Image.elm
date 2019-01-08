module Image exposing (Image, Status(..), buildCodes, buildImages, distinct, randomGenerator)

import Random
import Set exposing (Set)


type alias Image =
    { id : Int
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
    codes |> List.map (\code -> code |> buildImage)


buildImage : Int -> Image
buildImage id =
    { id = id
    , url = "https://picsum.photos/300/?image=" ++ String.fromInt id
    , description = String.fromInt id
    , status = Hidden
    }
