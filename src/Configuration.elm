module Configuration exposing (Configuration)


type alias Configuration =
    { level : Int
    , cardsByLevel : Int
    , codes : List Int
    }
