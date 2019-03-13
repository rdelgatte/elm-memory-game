module Image exposing (Image, Status(..), buildImage)


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
