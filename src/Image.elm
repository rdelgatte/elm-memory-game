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
    case status of
        Found ->
            [ width (px 100)
            , none
                |> el
                    [ Element.Background.color (rgba255 255 255 255 0.5)
                    , width fill
                    , height fill
                    ]
                |> inFront
            ]

        _ ->
            [ width (px 100) ]


renderImage : Image -> Element msg
renderImage image =
    { src = image |> imageUrl
    , description = image.description
    }
        |> Element.image (image |> imageStyle)


isImageFound : List Image -> Image -> Bool
isImageFound images image =
    let
        size =
            images
                |> List.filter (\img -> img.id == image.id)
                |> List.filter (\img -> img.status == Visible)
                |> List.length
    in
    size > 1


refreshImagesStatus : Maybe (List Image) -> Maybe (List Image)
refreshImagesStatus maybeImages =
    case maybeImages of
        Nothing ->
            Nothing

        Just images ->
            let
                updated : List Image
                updated =
                    images
                        |> List.map
                            (\image ->
                                case image |> isImageFound images of
                                    True ->
                                        image |> found

                                    False ->
                                        image
                            )
            in
            Just updated
