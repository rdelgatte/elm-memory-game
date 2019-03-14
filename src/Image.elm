module Image exposing (Image, Status(..), buildImage, refreshImagesStatus, renderImage, visible)

import Element exposing (Attribute, Element, el, fill, height, inFront, none, px, rgba255, width)
import Element.Background
import String exposing (fromInt)


type alias Image =
    { id : Int
    , description : String
    , status : Status
    }


type Status
    = Hidden
    | Visible
    | Found


buildImage : Int -> Image
buildImage imageId =
    let
        description : String
        description =
            imageId
                |> String.fromInt
                |> String.append "Random image "
    in
    Image imageId description Hidden


visible : Image -> Image
visible image =
    Visible |> imageStatus image


found : Image -> Image
found image =
    Found |> imageStatus image


imageStatus : Image -> Status -> Image
imageStatus image newStatus =
    { image | status = newStatus }


imageUrl : Image -> String
imageUrl { id, status } =
    case status of
        Hidden ->
            "doc/card.png"

        _ ->
            (id |> fromInt)
                |> String.append "https://picsum.photos/200/300?image="


imageStyle : Image -> List (Attribute msg)
imageStyle { status } =
    [ width (px 100) ]


renderImage : Image -> Element msg
renderImage image =
    { src = image |> imageUrl
    , description = image.description
    }
        |> Element.image (image |> imageStyle)


refreshImagesStatus : Maybe (List Image) -> Maybe (List Image)
refreshImagesStatus maybeImages =
    maybeImages
